#!/usr/bin/env bash
# ==============================================================================
# aiup Installer
# Repository: https://github.com/Nan0pk/aiup
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Nan0pk/aiup/main/install.sh | bash
# ==============================================================================

set -euo pipefail

REPO_RAW_URL="https://raw.githubusercontent.com/Nan0pk/aiup/main"
INSTALL_DIR="${HOME}/.local/bin"
COMPLETIONS_DIR="${HOME}/.local/share/bash-completion/completions"

# Styling
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

echo -e "\n${BOLD}${CYAN}⚡ Installing aiup (Universal AI Harness & Desktop Updater)...${RESET}"

mkdir -p "$INSTALL_DIR"

# Download binary
if command -v curl &>/dev/null; then
  curl -fsSL "${REPO_RAW_URL}/bin/aiup" -o "${INSTALL_DIR}/aiup"
elif command -v wget &>/dev/null; then
  wget -qO "${INSTALL_DIR}/aiup" "${REPO_RAW_URL}/bin/aiup"
else
  echo "Error: Neither curl nor wget is installed." >&2
  exit 1
fi

chmod +x "${INSTALL_DIR}/aiup"
ln -sf "${INSTALL_DIR}/aiup" "${INSTALL_DIR}/uai"

# Install Bash autocompletions if possible
mkdir -p "$COMPLETIONS_DIR" 2>/dev/null || true
if [[ -d "$COMPLETIONS_DIR" ]]; then
  curl -fsSL "${REPO_RAW_URL}/completions/aiup.bash" -o "${COMPLETIONS_DIR}/aiup" 2>/dev/null || true
  ln -sf "${COMPLETIONS_DIR}/aiup" "${COMPLETIONS_DIR}/uai" 2>/dev/null || true
fi

# Ensure ~/.local/bin is in PATH
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
  SHELL_NAME="$(basename "${SHELL:-bash}")"
  case "$SHELL_NAME" in
    zsh)  RC_FILE="${HOME}/.zshrc" ;;
    bash) RC_FILE="${HOME}/.bashrc" ;;
    *)    RC_FILE="${HOME}/.profile" ;;
  esac

  echo "" >> "$RC_FILE"
  echo "# Added by aiup installer" >> "$RC_FILE"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$RC_FILE"
  echo -e "  ${CYAN}↳ Added ${INSTALL_DIR} to PATH in ${RC_FILE}${RESET}"
fi

echo -e "${GREEN}✔ aiup successfully installed to ${INSTALL_DIR}/aiup${RESET}"
echo -e "  Run ${BOLD}aiup -l${RESET} or ${BOLD}uai -l${RESET} to inspect your installed AI harnesses and desktop apps.\n"
