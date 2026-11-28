# ⚡ Aiup (Universal AI Harness & Desktop App Updater)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey.svg)]()
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20PowerShell-4EAA25.svg)]()

> Unified CLI + desktop updater and post-sync cache debloat utility tailored for local AI runtimes across **Windows** (PowerShell / CMD / Git Bash + `winget` / `pip` / `npm` / `uv`), **Linux** (`dnf` / `apt` / `pacman` / AppImage), and **macOS**.

```text
╭──────────────────────────────────────────────────────────────╮
│  🚀 [UPDATE MODE] Syncing AI Harnesses & Desktop Apps...     │
╰──────────────────────────────────────────────────────────────╯

◈ [SECTION 1] CLI HARNESSES & CORE AGENTS

┌── ◈ [CLI] Claude Code (claude)
  │   ↳ Connecting to Anthropic update manifest...
  └── ✔ [UP-TO-DATE] Current (2.1.258) [1.1s]

❖ [SECTION 2] DESKTOP AI APPS & WORKSPACES

┌── ❖ [DESKTOP] ZhipuAI ZCode Desktop (zcode)
  │   ↳ Querying winget manifest (ZhipuAI.ZCode)...
  │   ↳ Found newer version: 4.0.0 (installed: 3.8.1)
  └── ★ [UPDATE AVAILABLE] 3.8.1 → 4.0.0 [1.4s]

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
│ claude              │ CLI        │ ✔ UP-TO-DATE       │ 2.1.258                │ 1.1s  │
│ zcode               │ DESKTOP    │ ★ AVAILABLE        │ 4.0.0                  │ 1.4s  │
│ opencode-desktop    │ DESKTOP    │ ✔ UPDATED          │ v1.19.6                │ 12.4s │
│ clean-uv            │ CLEAN      │ ✔ CLEANED          │ 449 files, 165.1MiB    │ 0.1s  │
╰─────────────────────┴────────────┴────────────────────┴────────────────────────┴───────╯
  Total: 4 items  │  1 up-to-date  │  1 updated  │  1 cleaned  │  1 available
```

---

## ⚡ Quick Install

### Windows (PowerShell)

From a local clone:

```powershell
.\install.ps1
```

Or install remotely from GitHub:

```powershell
irm https://raw.githubusercontent.com/Nan0pk/AIup/main/install.ps1 | iex
```

Installs `aiup` and `uai` (`.ps1`, `.cmd`, and POSIX core) into `%USERPROFILE%\.local\bin`, adds it to your User `PATH`, and configures PowerShell tab completion. Requires [Git for Windows](https://gitforwindows.org/) (Git Bash) and Python 3.

### Linux / macOS / Git Bash

From a local clone:

```bash
./install.sh
```

Or install remotely from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/Nan0pk/AIup/main/install.sh | bash
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
| **Python pip AI Tools** | `pip-ai` | Checks PyPI JSON for installed tracked AI tools (`graphifyy`, `headroom`, `honcho-ai`, `aider-chat`, `open-webui`, `llm`, `huggingface-hub`, `litellm`, `browser-use`, `mcp`, `pydantic-ai`, `claude-agent-sdk`, `openai-agents`, `crewai`, `smolagents`) and upgrades via `pip` |
| **NPM AI Globals** | `npm-globals` | Checks `npm view <pkg> version`, upgrades outdated non-symlinked globals (`command-code`, `@qwen-code/qwen-code`, `cline`, `@google/gemini-cli`, `@github/copilot`, `@openai/codex`, `@anthropic-ai/claude-code`, `opencode-ai`, `@kilocode/cli`, `@mariozechner/pi-coding-agent`) |
| **Ollama Runtime** | `ollama` | Checks `winget` (`Ollama.Ollama`) on Windows, Homebrew on macOS, or `ollama/ollama` GitHub releases on Linux |
| **LM Studio CLI** | `lms` | Inspects `lms` / LM Studio (`ElementLabs.LMStudio` via `winget` on Windows; self-managed on Linux) |

### ❖ Desktop AI Apps & Workspaces
| Application | Target ID | Behavior |
| :--- | :--- | :--- |
| **ChatGPT Desktop** | `chatgpt` | Windows: `winget` (`OpenAI.ChatGPT`) / Store MSIX • Linux: `dnf` / `apt` / Flatpak • macOS: `ChatGPT.app` |
| **OpenCode Desktop** | `opencode-desktop` | Windows: `winget` or `latest.yml` + SHA-512 NSIS `/S` • Linux: SHA-512 verified `.rpm`, `.deb`, or `.AppImage` |
| **AionUi Workspace** | `aionui` | Windows: `winget` (`iOfficeAI.AionUi`) or `app.asar` vs GitHub • Linux: `app.asar` / pkg vs `iOfficeAI/AionUi` releases |
| **Antigravity IDE** | `antigravity-desktop` | Inspects local `app.asar` or upgrades via `winget` / `dnf` / `apt` when package-managed |
| **ZCode Desktop** | `zcode` | Windows: `winget` (`ZhipuAI.ZCode`) or `zai-org/ZCode` check • Linux: `dnf` / `apt` / `app.asar` / AppImage vs `zai-org/ZCode` |
| **Microsoft Copilot** | `copilot` | Windows: `winget` (`Microsoft.365Copilot` / `Microsoft.Copilot`) & MSIX • Linux: `gh extension upgrade gh-copilot` |
| **Claude Desktop** | `claude-desktop` | Windows: `winget` (`Anthropic.Claude`) • Linux: `dnf` / `apt` / `app.asar` |
| **Codex Desktop** | `codex-desktop` | Windows/Linux/macOS desktop app detection (`OpenAI.Codex` MSIX / `app.asar` / `dnf` / `apt`) |
| **CoWork-OS Desktop** | `cowork-os` | Protects dirty trees (optional `--force-git` stash/pop), pulls `origin/main`, runs `npm install && npm run build` |
| **Orkas Desktop** | `orkas` | Protects dirty trees (optional `--force-git` stash/pop), pulls upstream, syncs `npm install` |
| **Hermes Desktop UI** | `hermes-desktop` | Tracks availability alongside `hermes` CLI and Windows Hermes MSIX |

### 🧹 Housekeeping & System Debloat
| Module | Target ID | Action |
| :--- | :--- | :--- |
| **Python uv Cache** | `clean-uv` | Prunes dangling wheels/venvs (`uv cache prune`); scans `~/.cache/uv` or `%LOCALAPPDATA%\uv\cache` |
| **NPM Cache & Logs** | `clean-npm` | Resolves `npm config get cache`, purges `_logs/*`, and runs `npm cache verify` |
| **Python Pip Cache** | `clean-pip` | Runs `pip cache info` under `-c` and `pip cache purge` in clean/update mode |
| **Installer Packages** | `clean-installers` | Removes cached OpenCode (`.rpm`/`.deb`/Windows pending) and ZCode (`@zcodedesktop-updater/installer.exe`) installers once installed version >= cached version |
| **Git Housekeeping** | `clean-git` | Runs `git gc --auto` on local checkouts (`~/CoWork-OS`, `~/Orkas`), reporting only when objects pack |
| **Electron Archives** | `clean-electron` | Prunes `~/.cache/electron` or `%LOCALAPPDATA%\electron\Cache` `*.zip` archives older than 7 days |
| **DNF / APT Cache** | `clean-dnf` | Runs `sudo dnf clean packages` or `sudo apt-get autoclean` if sudo session is active (`SKIPPED` without root) |
| **Crashpad Dumps** | `clean-dumps` | Deletes `*.dmp` files older than 7 days in `~/.config`/`~/.cache` (Linux) or `CrashDumps`, `Crashpad`, `~/.zcode/v2/crash`, `~/.gemini/antigravity-cli/crashes` (Windows) |

---

## 🛠️ CLI Usage

```bash
# Update everything (CLI + Desktop apps) followed by housekeeping
aiup
uai

# Non-mutating check (scans versions, PyPI/npm/winget/DNF/APT/GitHub, and cache sizes without changes)
aiup -c

# Housekeeping & cache debloat only
aiup -C
aiup -c -C             # Dry-run housekeeping scan (safe regardless of flag order)

# Fast update skipping housekeeping
aiup --no-clean

# Sudo handling (Linux/macOS)
aiup -S                # Pre-authenticate sudo upfront (if safe) for unattended sync
aiup --no-sudo         # Never prompt for elevation

# Inventory & targeted execution
aiup -l                # Dashboard of detected versions
aiup -l --json         # JSON inventory
aiup --desktop         # Desktop targets only
aiup -o zcode,claude   # Run specific targets only
aiup -s cowork-os      # Skip specific targets
aiup --force-git       # Stash uncommitted git changes, pull/build, then pop stash
```

---

## 🛡️ Safety & Architecture

- **Non-Mutating Dry-Run (`-c`)**: Self-updater CLIs lacking `--check` are explicitly skipped during `-c` rather than run silently; git workspaces use read-only `ls-remote`; PyPI/npm/`winget`/DNF/APT/GitHub checks never modify files.
- **Cryptographic Package Verification**: Downloads for OpenCode Desktop verify SHA-512 against upstream `latest-linux.yml` / `latest.yml` (plus `rpm -K --nosignature` on RPM).
- **Zero External JSON Dependency**: Uses `jq` when present and falls back cleanly to Python's standard library `json` module across Windows, Linux, and macOS.
- **Honest Failure & Time Reporting**: Drains piped output cleanly (no `SIGPIPE` aborts), checks real exit codes, records elapsed durations after actual downloads/builds finish, and exits `1` when any step reports `FAILED`.

---

## 🧪 Tests

Linux / macOS / Git Bash:

```bash
./tests/smoke.sh
```

Windows PowerShell:

```powershell
.\tests\smoke.ps1
```

---

## 📄 License

MIT © [Nan0pk](https://github.com/Nan0pk) — see [`LICENSE`](LICENSE).
