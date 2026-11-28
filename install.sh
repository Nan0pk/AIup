#!/usr/bin/env bash
# ==============================================================================
# aiup Installer (Linux, macOS, and Windows Git Bash)
# Repository: https://github.com/Nan0pk/AIup
# Usage:
#   ./install.sh
#   curl -fsSL https://raw.githubusercontent.com/Nan0pk/AIup/main/install.sh | bash
#   Windows PowerShell: .\install.ps1
# ==============================================================================

set -euo pipefail

REPO_RAW_URL="https://raw.githubusercontent.com/Nan0pk/AIup/main"
INSTALL_DIR="${HOME}/.local/bin"
BASH_COMP_DIR="${HOME}/.local/share/bash-completion/completions"
ZSH_COMP_DIR="${HOME}/.local/share/zsh/site-functions"
PS_COMP_DIR="${HOME}/.local/share/aiup/completions"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

IS_WINDOWS=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
esac

if [[ -t 1 ]]; then
  BOLD="\033[1m"
  GREEN="\033[1;32m"
  CYAN="\033[1;36m"
  RESET="\033[0m"
else
  BOLD=""
  GREEN=""
  CYAN=""
  RESET=""
fi

install_asset() {
  local rel_path="$1"
  local dest="$2"
  if [[ -f "${SCRIPT_DIR}/${rel_path}" ]]; then
    cp -f "${SCRIPT_DIR}/${rel_path}" "$dest"
  elif command -v curl &>/dev/null; then
    curl -fsSL "${REPO_RAW_URL}/${rel_path}" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -qO "$dest" "${REPO_RAW_URL}/${rel_path}"
  else
    echo "Error: Neither curl nor wget is installed." >&2
    return 1
  fi
}

echo -e "\n${BOLD}${CYAN}⚡ Installing aiup (Universal AI Harness & Desktop Updater)...${RESET}"

mkdir -p "$INSTALL_DIR"
install_asset "bin/aiup" "${INSTALL_DIR}/aiup"
chmod +x "${INSTALL_DIR}/aiup"

if [[ $IS_WINDOWS -eq 1 ]]; then
  # On Windows Git Bash, avoid creating NTFS symlink duplicates that cmd/PowerShell cannot invoke;
  # install native .cmd/.ps1 shims alongside POSIX uai copy.
  cp -f "${INSTALL_DIR}/aiup" "${INSTALL_DIR}/uai"
  chmod +x "${INSTALL_DIR}/uai"
  for shim in aiup.cmd uai.cmd aiup.ps1 uai.ps1; do
    install_asset "bin/${shim}" "${INSTALL_DIR}/${shim}" 2>/dev/null || true
  done
  mkdir -p "$PS_COMP_DIR" 2>/dev/null || true
  install_asset "completions/aiup.ps1" "${PS_COMP_DIR}/aiup.ps1" 2>/dev/null || true
else
  ln -sf "${INSTALL_DIR}/aiup" "${INSTALL_DIR}/uai"
fi

# Install Bash completion
mkdir -p "$BASH_COMP_DIR" 2>/dev/null || true
if [[ -d "$BASH_COMP_DIR" ]]; then
  install_asset "completions/aiup.bash" "${BASH_COMP_DIR}/aiup" 2>/dev/null || true
  if [[ $IS_WINDOWS -eq 1 ]]; then
    cp -f "${BASH_COMP_DIR}/aiup" "${BASH_COMP_DIR}/uai" 2>/dev/null || true
  else
    ln -sf "${BASH_COMP_DIR}/aiup" "${BASH_COMP_DIR}/uai" 2>/dev/null || true
  fi
fi

# Install Zsh completion if zsh is present, active shell is zsh, or site-functions exists
if command -v zsh &>/dev/null || [[ "$(basename "${SHELL:-}")" == "zsh" || -d "$ZSH_COMP_DIR" ]]; then
  mkdir -p "$ZSH_COMP_DIR" 2>/dev/null || true
  if [[ -d "$ZSH_COMP_DIR" ]]; then
    install_asset "completions/aiup.zsh" "${ZSH_COMP_DIR}/_aiup" 2>/dev/null || true
  fi
fi

# Idempotent PATH setup if ~/.local/bin is missing from PATH
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
  SHELL_NAME="$(basename "${SHELL:-bash}")"
  case "$SHELL_NAME" in
    zsh)  RC_FILE="${HOME}/.zshrc" ;;
    bash) RC_FILE="${HOME}/.bashrc" ;;
    *)    RC_FILE="${HOME}/.profile" ;;
  esac

  if ! grep -q "# Added by aiup installer" "$RC_FILE" 2>/dev/null; then
    {
      echo ""
      echo "# Added by aiup installer"
      echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >> "$RC_FILE"
    echo -e "  ${CYAN}↳ Added ${INSTALL_DIR} to PATH in ${RC_FILE}${RESET}"
  fi
fi

# On real Windows user install (not sandboxed tests), also ensure User PATH includes ~/.local/bin
if [[ $IS_WINDOWS -eq 1 && -n "${USERPROFILE:-}" ]] && command -v cygpath &>/dev/null; then
  _win_home_posix="$(cygpath -u "$USERPROFILE" 2>/dev/null || true)"
  if [[ "$_win_home_posix" == "$HOME" ]] && command -v powershell.exe &>/dev/null; then
    _win_install_dir="$(cygpath -w "$INSTALL_DIR" 2>/dev/null || true)"
    if [[ -n "$_win_install_dir" ]]; then
      powershell.exe -NoProfile -NonInteractive -Command "
        \$d = '$_win_install_dir'.TrimEnd('\\')
        \$up = [Environment]::GetEnvironmentVariable('Path', 'User')
        \$parts = if (\$up) { \$up -split ';' | Where-Object { \$_ } } else { @() }
        if ((\$parts | ForEach-Object { \$_.TrimEnd('\\') }) -notcontains \$d) {
          [Environment]::SetEnvironmentVariable('Path', ((@(\$d) + \$parts) -join ';'), 'User')
        }
      " >/dev/null 2>&1 || true
    fi
  fi
fi

echo -e "${GREEN}✔ aiup installed to ${INSTALL_DIR}/aiup (alias: uai)${RESET}"
echo -e "  Run ${BOLD}aiup -l${RESET} or ${BOLD}uai -l${RESET} to inspect your installed AI harnesses and desktop apps.\n"
