# ⚡ aiup (Universal AI Harness & Desktop App Updater)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Fedora%20%7C%20Linux-lightgrey.svg)]()
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25.svg)]()

> Unified CLI + desktop updater and post-sync cache debloat utility tailored for local AI runtimes on Linux (primarily Fedora / DNF / RPM, with read-only inventory & cross-platform helpers).

```text
╭──────────────────────────────────────────────────────────────╮
│  🚀 [UPDATE MODE] Syncing AI Harnesses & Desktop Apps...     │
╰──────────────────────────────────────────────────────────────╯

◈ [SECTION 1] CLI HARNESSES & CORE AGENTS

┌── ◈ [CLI] Claude Code (claude)
  │   ↳ Connecting to Anthropic update manifest...
  └── ✔ [UP-TO-DATE] Current (2.1.331) [1.1s]

❖ [SECTION 2] DESKTOP AI APPS & WORKSPACES

┌── ❖ [DESKTOP] ChatGPT Desktop App (chatgpt)
  │   ↳ Checking official DNF repository (chatgpt.repo)...
  └── ✔ [UP-TO-DATE] Version 26.1120.41243 is current [0.5s]

┌── ❖ [DESKTOP] OpenCode Desktop App (opencode-desktop)
  │   ↳ Querying OpenCode release manifest (latest-linux.yml)...
  │   ↳ SHA-512 digest verified against latest-linux.yml
  └── ✔ [UPDATED] Installed v1.19.6 [12.4s]

🧹 [SECTION 3] HOUSEKEEPING & SYSTEM DEBLOAT

┌── 🧹 [CLEANUP] Python uv Cache & Environments
  └── ✔ [CLEANED] Pruned 449 files, 165.1MiB [0.1s]

╭────────────────────────────────────────────────────────────────────────────────────────╮
│  📊 Sync Summary Dashboard                                                            │
├─────────────────────┬────────────┬────────────────────┬────────────────────────┬───────┤
│ Target              │ Scope      │ Status             │ Details                │ Time  │
├─────────────────────┼────────────┼────────────────────┼────────────────────────┼───────┤
│ claude              │ CLI        │ ✔ UP-TO-DATE       │ 2.1.331                │ 1.1s  │
│ chatgpt             │ DESKTOP    │ ✔ UP-TO-DATE       │ v26.1120.41243         │ 0.5s  │
│ opencode-desktop    │ DESKTOP    │ ✔ UPDATED          │ v1.19.6                │ 12.4s │
│ clean-uv            │ CLEAN      │ ✔ CLEANED          │ 449 files, 165.1MiB    │ 0.1s  │
╰─────────────────────┴────────────┴────────────────────┴────────────────────────┴───────╯
  Total: 4 items  │  2 up-to-date  │  1 updated  │  1 cleaned
```

---

## ⚡ Quick Install

From a local clone:

```bash
./install.sh
```

Or remotely once published to GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/Nan0pk/aiup/main/install.sh | bash
```

Installs `aiup` and `uai` into `~/.local/bin/` along with Bash and Zsh autocompletion.

---

## 🎯 Supported Engines & Applications

### ◈ CLI Harnesses & Agents
| Harness | Target ID | Behavior |
| :--- | :--- | :--- |
| **Google Antigravity** | `agy` | Runs `agy update` (skips under `-c`, no native `--check`) |
| **Claude Code** | `claude` | Runs `claude update` (skips under `-c`, no native `--check`) |
| **OpenAI Codex** | `codex` | Runs `codex update`, diffs pre/post version (skips under `-c`) |
| **OpenCode CLI** | `opencode` | Runs `opencode upgrade` (skips under `-c`) |
| **Xiaomi Mimocode** | `mimo` | Runs `mimo upgrade` (skips under `-c`) |
| **Kilo Agent** | `kilo` | Runs `kilo upgrade` (skips under `-c`) |
| **Goose CLI** | `goose` | Runs `goose update` (skips under `-c`) |
| **Hermes Agent** | `hermes` | Supports native `--check` (`hermes update --check`) and `--yes --no-gateway-restart` |
| **Python uv Tools** | `uv-tools` | Checks PyPI JSON under `-c`; runs `uv tool upgrade --all` in update mode |
| **NPM AI Globals** | `npm-globals` | Checks `npm view <pkg> version`, upgrades outdated non-symlinked globals (`command-code`, `@qwen-code/qwen-code`, `cline`) |

### ❖ Desktop AI Apps & Workspaces
| Application | Target ID | Behavior |
| :--- | :--- | :--- |
| **ChatGPT Desktop** | `chatgpt` | Checks `dnf check-update chatgpt` and upgrades via `sudo dnf` / `pkexec` (Fedora/DNF) |
| **OpenCode Desktop** | `opencode-desktop` | Queries `latest-linux.yml`, verifies SHA-512 + `rpm -K --nosignature`, installs `x86_64` RPM via `sudo`/`pkexec` |
| **AionUi Workspace** | `aionui` | Compares local `app.asar` vs GitHub releases and alerts on newer versions (`manual` download) |
| **Antigravity IDE** | `antigravity-desktop` | Inspects local IDE shell version (`self-managed` internally) |
| **CoWork-OS Desktop** | `cowork-os` | Protects dirty trees (optional `--force-git` stash/pop), pulls `origin/main`, runs `npm install && npm run build` |
| **Orkas Desktop** | `orkas` | Protects dirty trees (optional `--force-git` stash/pop), pulls upstream, syncs `npm install` |
| **Hermes Desktop UI** | `hermes-desktop` | Tracks availability alongside core `hermes` |

### 🧹 Housekeeping & System Debloat
| Module | Target ID | Action |
| :--- | :--- | :--- |
| **Python uv Cache** | `clean-uv` | Prunes dangling wheels/venvs (`uv cache prune`); reports `UP TO DATE` when 0 removed |
| **NPM Cache & Logs** | `clean-npm` | Purges `~/.npm/_logs/*`; runs `npm cache verify` after npm installs, purged logs, or `-C` |
| **Python Pip Cache** | `clean-pip` | Runs `pip cache purge` when files > 0 exist |
| **Installer Packages** | `clean-installers` | Removes cached OpenCode desktop RPM once installed version >= cached version |
| **Git Housekeeping** | `clean-git` | Runs `git gc --auto` on local checkouts (`~/CoWork-OS`, `~/Orkas`), reporting only when objects pack |
| **Electron Archives** | `clean-electron` | Prunes `~/.cache/electron/*.zip` older than 7 days |
| **DNF Package Cache** | `clean-dnf` | Runs `sudo dnf clean packages` if sudo session is active (`SKIPPED` without root) |
| **Crashpad Dumps** | `clean-dumps` | Deletes `*.dmp` files older than 7 days in `~/.config` and `~/.cache` |

---

## 🛠️ CLI Usage

```bash
# Update everything (CLI + Desktop apps) followed by housekeeping
aiup
uai

# Non-mutating check (scans versions, PyPI/npm/DNF/GitHub, and cache sizes without changes)
aiup -c

# Housekeeping & cache debloat only
aiup -C
aiup -c -C             # Dry-run housekeeping scan (safe regardless of flag order)

# Fast update skipping housekeeping
aiup --no-clean

# Sudo handling
aiup -S                # Pre-authenticate sudo upfront (if safe) for unattended sync
aiup --no-sudo         # Never prompt for sudo/pkexec (caches pending RPMs)

# Inventory & targeted execution
aiup -l                # Dashboard of detected versions
aiup -l --json         # JSON inventory
aiup --desktop         # Desktop targets only
aiup -o chatgpt,claude # Run specific targets only
aiup -s cowork-os      # Skip specific targets
aiup --force-git       # Stash uncommitted git changes, pull/build, then pop stash
```

---

## 🛡️ Safety & Architecture

- **Non-Mutating Dry-Run (`-c`)**: Self-updater CLIs lacking `--check` are explicitly skipped during `-c` rather than run silently; git workspaces use read-only `ls-remote`; npm/PyPI/DNF/GitHub checks never modify files.
- **Cryptographic Package Verification**: Downloads for OpenCode Desktop verify SHA-512 against upstream `latest-linux.yml` plus `rpm -K --nosignature` before elevating to `rpm -U`.
- **Just-in-Time or Upfront Sudo**: Prompts for `sudo` only when a verified update needs root (`-S` opts into safe startup pre-auth with keep-alive cleanup). Uses `pkexec` automatically when invoked headless under Wayland/X11.
- **Honest Failure & Time Reporting**: Drains piped output cleanly (no `SIGPIPE` aborts), checks real exit codes, records elapsed durations after actual downloads/builds finish, and exits `1` when any step reports `FAILED`.

---

## 🧪 Tests

```bash
./tests/smoke.sh
```

---

## 📄 License

MIT © [Nan0pk](https://github.com/Nan0pk) — see [`LICENSE`](LICENSE).
