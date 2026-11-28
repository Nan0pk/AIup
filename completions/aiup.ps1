# PowerShell argument completion for aiup / uai

$script:_aiupOptions = @(
  '-h', '--help',
  '-v', '--version',
  '-l', '--list',
  '-c', '--check',
  '-C', '--clean', '--debloat',
  '--no-clean',
  '-S', '--sudo',
  '--no-sudo',
  '--cli',
  '--desktop',
  '-o', '--only',
  '-s', '--skip',
  '--json',
  '--force-git',
  '--no-color'
)

$script:_aiupTargets = @(
  'agy', 'claude', 'codex', 'hermes', 'opencode', 'mimo', 'kilo', 'goose',
  'uv-tools', 'pip-ai', 'npm-globals', 'ollama', 'lms',
  'chatgpt', 'opencode-desktop', 'aionui', 'antigravity-desktop', 'zcode',
  'copilot', 'claude-desktop', 'codex-desktop', 'cowork-os', 'orkas', 'hermes-desktop',
  'clean-uv', 'clean-npm', 'clean-pip', 'clean-installers', 'clean-git',
  'clean-electron', 'clean-dnf', 'clean-dumps'
)

$script:_aiupCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)
  $tokens = $commandAst.CommandElements
  $prev = if ($tokens.Count -ge 2) { $tokens[$tokens.Count - 2].ToString() } else { '' }

  if ($prev -in @('-o', '--only', '-s', '--skip')) {
    $prefix = ''
    $needle = $wordToComplete
    if ($wordToComplete -match '^(.*,)([^,]*)$') {
      $prefix = $Matches[1]
      $needle = $Matches[2]
    }
    return $script:_aiupTargets |
      Where-Object { $_ -like "$needle*" } |
      ForEach-Object { [System.Management.Automation.CompletionResult]::new("$prefix$_", $_, 'ParameterValue', $_) }
  }

  $pool = if ($wordToComplete -like '-*') { $script:_aiupOptions } else { $script:_aiupTargets }
  return $pool |
    Where-Object { $_ -like "$wordToComplete*" } |
    ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}

foreach ($cmdName in @('aiup', 'aiup.ps1', 'aiup.cmd', 'uai', 'uai.ps1', 'uai.cmd', 'update-ai-harnesses')) {
  Register-ArgumentCompleter -CommandName $cmdName -ScriptBlock $script:_aiupCompleter
}
