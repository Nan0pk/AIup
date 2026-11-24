#!/usr/bin/env bash
# Smoke & unit tests for aiup (non-mutating)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AIUP="${ROOT_DIR}/bin/aiup"
PASS=0
FAIL=0

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
mode_cC="$(printf '%s' "$json_cC" | jq -r '.mode')"
mode_Cc="$(printf '%s' "$json_Cc" | jq -r '.mode')"
assert_eq "-c -C mode is check" "check" "$mode_cC"
assert_eq "-C -c mode is check" "check" "$mode_Cc"

# 5. Inventory JSON is valid and contains expected schema keys
inv_json="$("$AIUP" -l --json)"
printf '%s' "$inv_json" | python3 -c '
import json, sys
d = json.load(sys.stdin)
assert "cli_harnesses" in d and "desktop_apps" in d
assert "version" in d and "arch" in d
print("PASS: inventory JSON schema valid")
'
((PASS++)) || true

# 6. stream_progress never causes SIGPIPE under pipefail when producer exceeds max_lines
rc=0
bash -c '
set -uo pipefail
source <(sed -n "/^OUTPUT_FORMAT=/p; /^stream_progress()/,/^}/p" "'"$AIUP"'")
OUTPUT_FORMAT="text" BOLD="" DIM="" RESET="" GRAY=""
python3 -c "import time
for i in range(25):
    print(f\"line {i}\", flush=True)
    time.sleep(0.01)" | stream_progress 3 >/dev/null
' || rc=$?
assert_eq "stream_progress drains without SIGPIPE" "0" "$rc"

# 7. Version comparison helper accuracy
rc_gt=0; rc_eq=0; rc_lt=0
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "v1.19.6" "1.19.5"' || rc_gt=$?
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "1.19.6" "1.19.6"' || rc_eq=$?
bash -c 'source <(sed -n "/^is_version_gt()/,/^}/p" "'"$AIUP"'"); is_version_gt "1.19.5" "1.19.6"' || rc_lt=$?
assert_eq "is_version_gt 1.19.6 > 1.19.5" "0" "$rc_gt"
assert_eq "is_version_gt 1.19.6 == 1.19.6" "1" "$rc_eq"
assert_eq "is_version_gt 1.19.5 < 1.19.6" "1" "$rc_lt"

# 8. Safe dry-run across self-updater CLI skips instead of mutating & avoids 'vv' prefix
dry_cli="$("$AIUP" -c -o opencode --json)"
dry_status="$(printf '%s' "$dry_cli" | jq -r '.results[0].status')"
assert_eq "-c skips self-updater CLI without dry-run flag" "SKIPPED" "$dry_status"
dry_text="$("$AIUP" -c -o opencode --no-color)"
if printf '%s' "$dry_text" | grep -q 'vv[0-9]'; then
  echo "FAIL: duplicate 'vv' version prefix found" >&2
  ((FAIL++)) || true
else
  echo "PASS: clean single 'v' prefix in CLI skip output"
  ((PASS++)) || true
fi

# 9. SHA-512 verification helper works accurately
tmp_hash_f="$(mktemp)"
printf 'hello aiup checksum\n' > "$tmp_hash_f"
good_b64="$(python3 -c 'import base64, hashlib, sys; print(base64.b64encode(hashlib.sha512(open(sys.argv[1],"rb").read()).digest()).decode())' "$tmp_hash_f")"
rc_sha_ok=0; rc_sha_bad=0
bash -c 'source <(sed -n "/^verify_sha512_b64()/,/^}/p" "'"$AIUP"'"); verify_sha512_b64 "'"$tmp_hash_f"'" "'"$good_b64"'"' || rc_sha_ok=$?
bash -c 'source <(sed -n "/^verify_sha512_b64()/,/^}/p" "'"$AIUP"'"); verify_sha512_b64 "'"$tmp_hash_f"'" "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="' || rc_sha_bad=$?
rm -f "$tmp_hash_f"
assert_eq "verify_sha512_b64 accepts matching digest" "0" "$rc_sha_ok"
assert_eq "verify_sha512_b64 rejects tampered digest" "1" "$rc_sha_bad"

# 10. Sandbox idempotency check for install.sh (Bash + Zsh completions, PATH dedup)
tmp_home="$(mktemp -d)"
HOME="$tmp_home" PATH="/usr/bin:/bin" SHELL="/bin/zsh" "${ROOT_DIR}/install.sh" >/dev/null
HOME="$tmp_home" PATH="/usr/bin:/bin" SHELL="/bin/zsh" "${ROOT_DIR}/install.sh" >/dev/null
rc_lines="$(grep -c "Added by aiup installer" "${tmp_home}/.zshrc" || echo 0)"
assert_eq "install.sh PATH line appended once across re-runs" "1" "$rc_lines"
if [[ -x "${tmp_home}/.local/bin/aiup" && -L "${tmp_home}/.local/bin/uai" && -f "${tmp_home}/.local/share/bash-completion/completions/aiup" && -f "${tmp_home}/.local/share/zsh/site-functions/_aiup" ]]; then
  echo "PASS: install.sh places binaries & bash/zsh completions"
  ((PASS++)) || true
else
  echo "FAIL: install.sh missing installed assets" >&2
  ((FAIL++)) || true
fi
rm -rf "$tmp_home"

echo ""
echo "Summary: ${PASS} passed, ${FAIL} failed"
[[ $FAIL -eq 0 ]]
