#compdef aiup uai update-ai-harnesses

_aiup() {
  local -a opts

  opts=(
    '(-h --help)'{-h,--help}'[Show help documentation]'
    '(-v --version)'{-v,--version}'[Show version number]'
    '(-l --list)'{-l,--list}'[List detected AI apps and installed versions]'
    '(-c --check)'{-c,--check}'[Dry-run check for available updates]'
    '(-C --clean)'{-C,--clean}'[Perform housekeeping, cache purge & system debloat only]'
    '--no-clean[Skip post-update housekeeping and cache debloat]'
    '(-S --sudo)'{-S,--sudo}'[Pre-authenticate sudo upfront at startup]'
    '--no-sudo[Disable all elevation prompts (skip/cache privileged updates)]'
    '--cli[Only target CLI harnesses and agent runtimes]'
    '--desktop[Only target Desktop AI apps and UI workspaces]'
    '(-o --only)'{-o,--only}'[Only update specified target(s)]:target:_aiup_targets'
    '(-s --skip)'{-s,--skip}'[Skip specified target(s)]:target:_aiup_targets'
    '--json[Output results in JSON format]'
    '--force-git[Stash and update git repos even if tree is dirty]'
    '--no-color[Disable colored terminal output]'
  )

  _arguments -s $opts
}

_aiup_targets() {
  local -a targets
  targets=(
    'agy:Google Antigravity CLI'
    'claude:Anthropic Claude Code CLI'
    'codex:OpenAI Codex CLI'
    'hermes:NousResearch Hermes Agent'
    'opencode:OpenCode CLI'
    'mimo:Xiaomi Mimocode CLI'
    'kilo:Kilo Agent CLI'
    'goose:Block Goose CLI'
    'uv-tools:Python uv managed tools'
    'pip-ai:Python pip AI packages and CLIs'
    'npm-globals:Global npm AI packages'
    'ollama:Ollama local LLM runtime'
    'lms:LM Studio CLI and runtime'
    'chatgpt:ChatGPT Desktop App'
    'opencode-desktop:OpenCode Desktop App'
    'aionui:AionUi Desktop Workspace'
    'antigravity-desktop:Google Antigravity IDE'
    'zcode:ZhipuAI ZCode Desktop'
    'copilot:Microsoft Copilot Desktop / gh-copilot'
    'claude-desktop:Anthropic Claude Desktop App'
    'codex-desktop:OpenAI Codex Desktop App'
    'cowork-os:CoWork-OS Desktop and repo'
    'orkas:Orkas Desktop Client'
    'hermes-desktop:Hermes Desktop UI'
    'clean-uv:Prune Python uv cache & environments'
    'clean-npm:Verify npm cache & purge debug logs'
    'clean-pip:Purge Python pip wheel cache'
    'clean-installers:Clean installed desktop updater packages'
    'clean-git:Optimize and pack local AI git repositories'
    'clean-electron:Prune stale cached electron archives'
    'clean-dnf:Prune system package manager cache'
    'clean-dumps:Purge stale crash minidumps'
  )
  _describe 'target' targets
}

_aiup "$@"
