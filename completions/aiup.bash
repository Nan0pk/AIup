# bash completion for aiup / uai

_aiup_completions() {
  local cur prev opts targets
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  opts="-h --help -v --version -l --list -c --check -C --clean --debloat --no-clean -S --sudo --no-sudo --cli --desktop -o --only -s --skip --json --force-git --no-color"
  targets="agy claude codex hermes opencode mimo kilo goose uv-tools npm-globals chatgpt opencode-desktop aionui antigravity-desktop cowork-os orkas hermes-desktop clean-uv clean-npm clean-pip clean-installers clean-git clean-electron clean-dnf clean-dumps"

  case "$prev" in
    -o|--only|-s|--skip)
      COMPREPLY=( $(compgen -W "${targets}" -- "${cur}") )
      return 0
      ;;
  esac

  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
  else
    COMPREPLY=( $(compgen -W "${targets}" -- "${cur}") )
  fi
}

complete -F _aiup_completions aiup
complete -F _aiup_completions uai
complete -F _aiup_completions update-ai-harnesses
