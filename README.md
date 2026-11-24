# ⚡ aiup (Universal AI Harness & Desktop App Updater)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)]()
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20zsh-4EAA25.svg)]()

> One unified command to detect, monitor, and synchronize all your AI CLIs, autonomous agents, and desktop AI workspaces.

```text
╭──────────────────────────────────────────────────────────────╮
│  🚀 [UPDATE MODE] Syncing All AI Harnesses & Desktop Apps... │
╰──────────────────────────────────────────────────────────────╯

◈ [SECTION 1] CLI HARNESSES & CORE AGENTS

┌── ◈ [CLI] Claude Code (claude)
  │   ↳ Connecting to Anthropic update manifest...
  │   ↳ Current version: 2.1.331
  │   ↳ Checking for updates to latest version…
  └── ✔ [UP-TO-DATE] Manifest verified [1.1s]

❖ [SECTION 2] DESKTOP AI APPS & WORKSPACES

┌── ❖ [DESKTOP] ChatGPT Desktop App (chatgpt)
  │   ↳ Checking official DNF repository (https://persistent.oaistatic.com/...)...
  └── ✔ [UP-TO-DATE] Version 26.1120.41243 is current [0.5s]

┌── ❖ [DESKTOP] OpenCode Desktop App (opencode-desktop)
  │   ↳ Inspecting local RPM package (v1.19.5)...
  │   ↳ Querying GitHub releases (anomalyco/opencode)...
  │   ↳ Found new release: v1.19.6 (local: v1.19.5)
  └── ★ [UPDATE AVAILABLE] v1.19.5 → v1.19.6 [0.5s]

╭────────────────────────────────────────────────────────────────────────────────────────╮
│  📊 Update Summary Dashboard                                                          │
├─────────────────────┬────────────┬────────────────────┬────────────────────────┬───────┤
│ Target              │ Scope      │ Status             │ Details                │ Time  │
├─────────────────────┼────────────┼────────────────────┼────────────────────────┼───────┤
│ claude              │ CLI        │ ✔ UP-TO-DATE       │ Verified               │ 1.1s  │
│ codex               │ CLI        │ ✔ UP-TO-DATE       │ v0.172.0               │ 2.4s  │
│ chatgpt             │ DESKTOP    │ ✔ UP-TO-DATE       │ v26.1120.41243         │ 0.5s  │
│ opencode-desktop    │ DESKTOP    │ ★ AVAILABLE        │ v1.19.6                │ 0.5s  │
│ cowork-os           │ DESKTOP    │ ▲ DIRTY TREE       │ 4 edits                │ 0.0s  │
╰─────────────────────┴────────────┴────────────────────┴────────────────────────┴───────╯
  Total: 5 items  │  3 up-to-date  │  0 updated  │  1 available  │  1 skipped
```

---

## ⚡ Quick Install

Install `aiup` with a single command (no root privileges required):

```bash
curl -fsSL https://raw.githubusercontent.com/Nan0pk/aiup/main/install.sh | bash
```

This installs `aiup` and the short alias `uai` to `~/.local/bin/` with automatic shell autocompletion.

---

## 🎯 Supported Engines & Applications

### ◈ CLI Harnesses & Agents
| Harness | Command | Engine / Source |
| :--- | :--- | :--- |
| **Google Antigravity** | `agy` | Native Google Antigravity release channels |
| **Claude Code** | `claude` | Anthropic binary updater manifest |
| **OpenAI Codex** | `codex` | Standalone binary distribution via ChatGPT |
| **Hermes Agent** | `hermes` | NousResearch git distribution & Python venv sync |
| **OpenCode CLI** | `opencode` | Upstream OpenCode release packages |
| **Xiaomi Mimocode** | `mimo` | Xiaomi Mimocode release endpoint |
| **Kilo Agent** | `kilo` | Kilo agent distribution channels |
| **Goose CLI** | `goose` | Block Goose CLI release binary |
| **Python uv Tools** | `uv tool` | All `uv`-managed tools (e.g. `mistral-vibe`) |
| **NPM Global AI Packages** | `npm` | `command-code`, `@qwen-code/qwen-code`, `cline` |

### ❖ Desktop AI Apps & Workspaces
| Application | Platform / Package | Description |
| :--- | :--- | :--- |
| **ChatGPT Desktop** | RPM / DNF / macOS | Official OpenAI desktop application |
| **OpenCode Desktop** | RPM / AppImage | OpenCode AI Desktop environment |
| **AionUi Workspace** | Electron (`~/.local/opt`) | AionUi multi-agent AI workspace |
| **Antigravity IDE** | Electron (`~/.local/share`) | Google Antigravity AI-first development IDE |
| **CoWork-OS Desktop** | Electron (`~/CoWork-OS`) | Local AI super-app (with automatic rebuilds) |
| **Orkas Desktop** | Electron (`~/Orkas`) | Multi-agent AI team desktop client |
| **Hermes Desktop UI** | UI (`hermes desktop`) | Hermes desktop frontend |

---

## 🛠️ CLI Usage

```bash
# Update everything (CLI engines + Desktop apps)
aiup

# Fast alias
uai

# Pre-authenticate sudo upfront at startup for an uninterrupted batch
aiup -S

# Disable all sudo prompts (leaves privileged updates cached for later)
aiup --no-sudo

# Dry-run check for updates without modifying files
aiup -c

# Clean visual inventory of all installed versions
aiup -l

# Only update desktop AI applications
aiup --desktop

# Only update CLI harnesses
aiup --cli

# Update specific targets only
aiup -o chatgpt,claude,codex

# Skip specific targets
aiup -s cowork-os

# Stash and update git checkouts even if working tree is dirty
aiup --force-git

# Output structured JSON for automation / CI scripts
aiup -c --json
```

---

## 🛡️ Safety & Architecture

- **Intelligent Privilege Elevation**: Sudo authentication can occur upfront at the start of a run (if privileged desktop apps are scheduled) or just-in-time when an update requires root (`rpm -U`, `dnf upgrade`). An active keep-alive prevents credential timeouts during long downloads. In dry-run (`-c`), inventory list (`-l`), or CLI-only scopes, root authorization is never requested.
- **Working Tree Preservation**: Detects uncommitted changes in local git checkouts (`~/CoWork-OS`, `~/Orkas`) and skips auto-pulls by default to protect in-flight development work.
- **NPM Symlink Protection**: Updates global packages individually without breaking local `npm link` references (such as symlinked local AI repos).
- **Graceful Failure Isolation**: Each harness runs in an isolated sub-process. Upstream network failures or temporary auth challenges in one tool never block updating the rest of your stack.
- **Desktop Notifications**: Dispatches native notifications (`notify-send` on Linux, `osascript` on macOS) when synchronization completes.

---

## 📄 License

MIT © [Nan0pk](https://github.com/Nan0pk)
