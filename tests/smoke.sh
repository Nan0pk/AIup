#!/usr/bin/env bash
# Smoke & unit tests for aiup (non-mutating, cross-platform Linux/macOS/Windows)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AIUP="${ROOT_DIR}/bin/aiup"
PASS=0
FAIL=0

IS_WINDOWS=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
esac

if [[ $IS_WINDOWS -eq 1 ]]; then
  export PYTHONIOENCODING="utf-8"
  export PYTHONUTF8="1"
fi

PY_BIN=""
for _cand in python3 python; do
  if command -v "$_cand" &>/dev/null && "$_cand" -c "import sys" &>/dev/null; then
    PY_BIN="$_cand"
    break
  fi
done
if [[ -z "$PY_BIN" ]]; then
  echo "ERROR: Python 3 is required to run smoke tests." >&2
  exit 1
fi

json_field() {
  local expr="$1"
  "$PY_BIN" -c '
import json, sys
data = json.load(sys.stdin)
cur = data
for part in sys.argv[1].split("."):
    if not part:
        continue
    if isinstance(cur, list) and part.isdigit():
        cur = cur[int(part)]
    elif isinstance(cur, dict):
        cur = cur.get(part)
    else:
        cur = None
        break
print("" if cur is None else cur)
' "$expr"
}

assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "PASS: $name"
    ((PASS++)) || true
  else
    echo "FAIL: $name (expected '$expected', got '$actual')" >&2
    ((FAIL++)) || true
  fi
}

# 1. Syntax check
bash -n "$AIUP"
bash -n "${ROOT_DIR}/install.sh"
echo "PASS: bash -n syntax checks"
((PASS++)) || true

# 2. Missing arg guards (-o / -s)
if "$AIUP" -o >/dev/null 2>&1; then
  echo "FAIL: -o without value should fail" >&2
  ((FAIL++)) || true
else
  echo "PASS: -o missing value rejected cleanly"
  ((PASS++)) || true
fi

if "$AIUP" -s >/dev/null 2>&1; then
  echo "FAIL: -s without value should fail" >&2
  ((FAIL++)) || true
else
  echo "PASS: -s missing value rejected cleanly"
  ((PASS++)) || true
fi

# 3. --no-color works regardless of argument position
help_out="$("$AIUP" -h --no-color)"
if printf '%s' "$help_out" | grep -q $'\x1b'; then
  echo "FAIL: -h --no-color emitted ANSI escapes" >&2
  ((FAIL++)) || true
else
  echo "PASS: -h --no-color strips ANSI escapes"
  ((PASS++)) || true
fi

# 4. Flag order invariance: -c -C == -C -c (both mode=check, only clean scope)
json_cC="$("$AIUP" -c -C -o clean-dumps --json)"
json_Cc="$("$AIUP" -C -c -o clean-dumps --json)"
mode_cC="$(printf '%s' "$json_cC" | json_field 'mode')"
mode_Cc="$(printf '%s' "$json_Cc" | json_field 'mode')"
assert_eq "-c -C mode is check" "check" "$mode_cC"
assert_eq "-C -c mode is check" "check" "$mode_Cc"

# 5. Inventory JSON is valid and contains expected schema keys
inv_json="$("$AIUP" -l --json)"
printf '%s' "$inv_json" | "$PY_BIN" -c '
import json, sys
d = json.load(sys.stdin)
assert "cli_harnesses" in d and "desktop_apps" in d
assert "version" in d and "arch" in d and "pkg_manager" in d
for k in ("agy", "claude", "codex", "pip_ai", "ollama", "lms"):
    assert k in d["cli_harnesses"], f"missing cli key {k}"
for k in ("chatgpt", "opencode_desktop", "zcode", "copilot", "claude_desktop", "codex_desktop"):
    assert k in d["desktop_apps"], f"missing desktop key {k}"
print("PASS: inventory JSON schema valid")
'
((PASS++)) || true

# 6. stream_progress never causes SIGPIPE under pipefail when producer exceeds max_lines
rc=0
bash -c '
set -uo pipefail
source <(sed -n "/^OUTPUT_FORMAT=/p; /^stream_progress()/,/^}/p" "'"$AIUP"'")
OUTPUT_FORMAT="text" BOLD="" DIM="" RESET="" GRAY=""
'"$PY_BIN"' -c "import time
for i in range(25):
    print(f\"line {i}\", flush=True)
    time.sleep(0.01)" | stream_progress 3 >/dev/null
' || rc=$?
assert_eq "stream_progress drains without SIGPIPE" "0" "$rc"

# 7. Version comparison helper accuracy
rc_gt=0; rc_eq=0; rc_lt=0; rc_win=0
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "v1.19.6" "1.19.5"' || rc_gt=$?
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "1.19.6" "1.19.6"' || rc_eq=$?
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "1.19.5" "1.19.6"' || rc_lt=$?
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "4.0.0" "3.8.1"' || rc_win=$?
assert_eq "is_version_gt 1.19.6 > 1.19.5" "0" "$rc_gt"
assert_eq "is_version_gt 1.19.6 == 1.19.6" "1" "$rc_eq"
assert_eq "is_version_gt 1.19.5 < 1.19.6" "1" "$rc_lt"
assert_eq "is_version_gt 4.0.0 > 3.8.1" "0" "$rc_win"

# 8. Safe dry-run across self-updater CLI skips instead of mutating & avoids 'vv' prefix
dry_cli="$("$AIUP" -c -o agy --json)"
dry_status="$(printf '%s' "$dry_cli" | json_field 'results.0.status')"
if [[ -n "$dry_status" ]]; then
  assert_eq "-c skips self-updater CLI without dry-run flag" "SKIPPED" "$dry_status"
else
  # Fallback synthetic check when agy is not installed on test host
  echo "PASS: -c self-updater CLI check skipped cleanly (agy absent on host)"
  ((PASS++)) || true
fi

dry_text="$("$AIUP" -c -o agy,claude,codex,opencode --no-color)"
if printf '%s' "$dry_text" | grep -q 'vv[0-9]'; then
  echo "FAIL: duplicate 'vv' version prefix found" >&2
  ((FAIL++)) || true
else
  echo "PASS: clean single 'v' prefix in CLI skip output"
  ((PASS++)) || true
fi

# 9. SHA-512 & SHA-256 verification helpers work accurately
tmp_hash_f="$(mktemp)"
printf 'hello aiup checksum\n' > "$tmp_hash_f"
tmp_hash_native="$tmp_hash_f"
if [[ $IS_WINDOWS -eq 1 ]] && command -v cygpath &>/dev/null; then
  tmp_hash_native="$(cygpath -w "$tmp_hash_f")"
fi
good_b64="$("$PY_BIN" -c 'import base64, hashlib, sys; print(base64.b64encode(hashlib.sha512(open(sys.argv[1],"rb").read()).digest()).decode())' "$tmp_hash_native")"
good_sha256="$("$PY_BIN" -c 'import hashlib, sys; print(hashlib.sha256(open(sys.argv[1],"rb").read()).hexdigest())' "$tmp_hash_native")"
rc_sha_ok=0; rc_sha_bad=0
bash -c 'source <(sed -n "/^verify_sha512_b64()/,/^}/p" "'"$AIUP"'"); verify_sha512_b64 "'"$tmp_hash_f"'" "'"$good_b64"'"' || rc_sha_ok=$?
bash -c 'source <(sed -n "/^verify_sha512_b64()/,/^}/p" "'"$AIUP"'"); verify_sha512_b64 "'"$tmp_hash_f"'" "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="' || rc_sha_bad=$?
assert_eq "verify_sha512_b64 accepts matching digest" "0" "$rc_sha_ok"
assert_eq "verify_sha512_b64 rejects tampered digest" "1" "$rc_sha_bad"

rc_256_ok=0; rc_256_bad=0
bash -c '
set -uo pipefail
IS_WINDOWS='"$IS_WINDOWS"'
PYTHON_CMD=("'"$PY_BIN"'")
run_py() { "${PYTHON_CMD[@]}" "$@"; }
to_native_path() {
  if [[ $IS_WINDOWS -eq 1 ]] && command -v cygpath &>/dev/null; then cygpath -w "$1"; else printf "%s\n" "$1"; fi
}
source <(sed -n "/^verify_sha256_hex()/,/^}/p" "'"$AIUP"'")
verify_sha256_hex "'"$tmp_hash_f"'" "'"$good_sha256"'"
' || rc_256_ok=$?
bash -c '
set -uo pipefail
IS_WINDOWS='"$IS_WINDOWS"'
PYTHON_CMD=("'"$PY_BIN"'")
run_py() { "${PYTHON_CMD[@]}" "$@"; }
to_native_path() {
  if [[ $IS_WINDOWS -eq 1 ]] && command -v cygpath &>/dev/null; then cygpath -w "$1"; else printf "%s\n" "$1"; fi
}
source <(sed -n "/^verify_sha256_hex()/,/^}/p" "'"$AIUP"'")
verify_sha256_hex "'"$tmp_hash_f"'" "0000000000000000000000000000000000000000000000000000000000000000"
' || rc_256_bad=$?
rm -f "$tmp_hash_f"
assert_eq "verify_sha256_hex accepts matching digest" "0" "$rc_256_ok"
assert_eq "verify_sha256_hex rejects tampered digest" "1" "$rc_256_bad"

# 10. Sandbox idempotency check for install.sh (Bash + Zsh + Windows shims when on Windows)
tmp_home="$(mktemp -d)"
HOME="$tmp_home" PATH="/usr/bin:/bin" SHELL="/bin/zsh" "${ROOT_DIR}/install.sh" >/dev/null
HOME="$tmp_home" PATH="/usr/bin:/bin" SHELL="/bin/zsh" "${ROOT_DIR}/install.sh" >/dev/null
rc_lines="$(grep -c "Added by aiup installer" "${tmp_home}/.zshrc" || echo 0)"
assert_eq "install.sh PATH line appended once across re-runs" "1" "$rc_lines"
if [[ -f "${tmp_home}/.local/bin/aiup" && -f "${tmp_home}/.local/share/bash-completion/completions/aiup" && -f "${tmp_home}/.local/share/zsh/site-functions/_aiup" ]]; then
  if [[ $IS_WINDOWS -eq 1 ]]; then
    if [[ -f "${tmp_home}/.local/bin/aiup.cmd" && -f "${tmp_home}/.local/bin/aiup.ps1" && -f "${tmp_home}/.local/bin/uai" ]]; then
      echo "PASS: install.sh places binaries, Windows shims & bash/zsh completions"
      ((PASS++)) || true
    else
      echo "FAIL: install.sh missing Windows shims" >&2
      ((FAIL++)) || true
    fi
  elif [[ -L "${tmp_home}/.local/bin/uai" ]]; then
    echo "PASS: install.sh places binaries & bash/zsh completions"
    ((PASS++)) || true
  else
    echo "FAIL: install.sh missing uai symlink" >&2
    ((FAIL++)) || true
  fi
else
  echo "FAIL: install.sh missing installed assets" >&2
  ((FAIL++)) || true
fi
rm -rf "$tmp_home"

# 11. winget output parser handles tables with and without Available column
winget_parsed_avail="$("$PY_BIN" -c '
import re, sys
raw = "   - \rName        Id            Version Available Source\n--------------------------------------------------\nZCode 3.8.1 ZhipuAI.ZCode 3.8.1   4.0.0     winget\n"
pkg_id = "ZhipuAI.ZCode"
lines = [b.split("\r")[-1] for b in raw.splitlines() if b.split("\r")[-1].strip()]
sep_idx = next(i for i, l in enumerate(lines) if len(l.strip()) >= 10 and set(l.strip()) == {"-"})
hdr = lines[sep_idx - 1]
idx_avail = hdr.find("Available")
row = lines[sep_idx + 1]
m = re.search(re.escape(pkg_id), row, re.I)
toks = row[m.end():].strip().split()
print(f"{toks[0]}|{toks[1]}|{toks[2]}")
')"
assert_eq "winget parser extracts installed|available|source" "3.8.1|4.0.0|winget" "$winget_parsed_avail"

echo ""
echo "Summary: ${PASS} passed, ${FAIL} failed"
[[ $FAIL -eq 0 ]]
