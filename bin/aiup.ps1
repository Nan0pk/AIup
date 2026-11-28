#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$aiupScript = Join-Path $PSScriptRoot 'aiup'
if (-not (Test-Path -LiteralPath $aiupScript)) {
  [Console]::Error.WriteLine("[ERROR] Missing aiup engine at '$aiupScript'")
  exit 1
}

function Find-GitBash {
  if ($env:AIUP_BASH -and (Test-Path -LiteralPath $env:AIUP_BASH)) {
    return $env:AIUP_BASH
  }

  $candidates = @(
    (Join-Path $env:ProgramFiles 'Git\bin\bash.exe'),
    (Join-Path $env:ProgramFiles 'Git\usr\bin\bash.exe'),
    $(if (${env:ProgramFiles(x86)}) { Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe' }),
    $(if ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe' }),
    'C:\msys64\usr\bin\bash.exe'
  ) | Where-Object { $_ }

  foreach ($cand in $candidates) {
    if (Test-Path -LiteralPath $cand) {
      return $cand
    }
  }

  $gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
  if ($gitCmd) {
    $gitBash = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $gitCmd.Source -Parent) '..\bin\bash.exe'))
    if (Test-Path -LiteralPath $gitBash) {
      return $gitBash
    }
  }

  $bashCmds = Get-Command bash.exe -All -ErrorAction SilentlyContinue | Where-Object {
    $_.Source -and ($_.Source -notmatch '\\System32\\bash\.exe$')
  }
  if ($bashCmds) {
    return ($bashCmds | Select-Object -First 1 -ExpandProperty Source)
  }

  return $null
}

$bashExe = Find-GitBash
if (-not $bashExe) {
  [Console]::Error.WriteLine('[ERROR] Git Bash / MSYS2 bash.exe was not found.')
  [Console]::Error.WriteLine('Install Git for Windows: winget install Git.Git')
  exit 1
}

$prevOutEnc = [Console]::OutputEncoding
$prevInEnc = [Console]::InputEncoding
try {
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [Console]::OutputEncoding = $utf8NoBom
  [Console]::InputEncoding = $utf8NoBom
} catch {}

# Flatten PowerShell comma-parsed arguments (e.g., `aiup -o claude,zcode`)
$flatArgs = New-Object System.Collections.Generic.List[string]
foreach ($a in $args) {
  if ($a -is [System.Array]) {
    $flatArgs.Add(($a -join ','))
  } else {
    $flatArgs.Add([string]$a)
  }
}

try {
  & $bashExe $aiupScript @flatArgs
  $rc = $LASTEXITCODE
} finally {
  try {
    [Console]::OutputEncoding = $prevOutEnc
    [Console]::InputEncoding = $prevInEnc
  } catch {}
}

exit $rc
