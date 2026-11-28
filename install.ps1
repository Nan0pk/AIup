#Requires -Version 5.1
<#
.SYNOPSIS
  aiup Windows Installer
  Repository: https://github.com/Nan0pk/AIup
.EXAMPLE
  .\install.ps1
  irm https://raw.githubusercontent.com/Nan0pk/AIup/main/install.ps1 | iex
#>
$ErrorActionPreference = 'Stop'

$RepoRawUrl = 'https://raw.githubusercontent.com/Nan0pk/AIup/main'
$UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$InstallDir = Join-Path $UserHome '.local\bin'
$CompDir = Join-Path $UserHome '.local\share\aiup\completions'
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { '' }

function Install-AiupAsset {
  param(
    [Parameter(Mandatory = $true)][string]$RelPath,
    [Parameter(Mandatory = $true)][string]$DestPath,
    [switch]$ForceLf
  )
  $parent = Split-Path $DestPath -Parent
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  $localSrc = if ($ScriptDir) { Join-Path $ScriptDir $RelPath } else { '' }
  if ($localSrc -and (Test-Path -LiteralPath $localSrc)) {
    $bytes = [System.IO.File]::ReadAllBytes($localSrc)
  } else {
    $resp = Invoke-WebRequest -Uri "$RepoRawUrl/$RelPath" -UseBasicParsing
    $bytes = if ($resp.Content -is [byte[]]) { $resp.Content } else { [System.Text.Encoding]::UTF8.GetBytes($resp.Content) }
  }

  if ($ForceLf) {
    $text = [System.Text.Encoding]::UTF8.GetString($bytes) -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($DestPath, $text, (New-Object System.Text.UTF8Encoding($false)))
  } else {
    [System.IO.File]::WriteAllBytes($DestPath, $bytes)
  }
}

Write-Host "`n⚡ Installing aiup (Universal AI Harness & Desktop Updater)..." -ForegroundColor Cyan

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
New-Item -ItemType Directory -Path $CompDir -Force | Out-Null

Install-AiupAsset -RelPath 'bin/aiup'     -DestPath (Join-Path $InstallDir 'aiup') -ForceLf
Install-AiupAsset -RelPath 'bin/aiup.cmd' -DestPath (Join-Path $InstallDir 'aiup.cmd')
Install-AiupAsset -RelPath 'bin/uai.cmd'  -DestPath (Join-Path $InstallDir 'uai.cmd')
Install-AiupAsset -RelPath 'bin/aiup.ps1' -DestPath (Join-Path $InstallDir 'aiup.ps1')
Install-AiupAsset -RelPath 'bin/uai.ps1'  -DestPath (Join-Path $InstallDir 'uai.ps1')
Install-AiupAsset -RelPath 'completions/aiup.ps1' -DestPath (Join-Path $CompDir 'aiup.ps1') -ForceLf

# Idempotent User PATH registration
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathEntries = @()
if ($userPath) {
  $pathEntries = $userPath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' }
}
$normInstall = $InstallDir.TrimEnd('\')
$alreadyInUserPath = $pathEntries | Where-Object { $_.TrimEnd('\') -ieq $normInstall }
if (-not $alreadyInUserPath) {
  $newUserPath = (@($InstallDir) + $pathEntries) -join ';'
  [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
  Write-Host "  ↳ Added $InstallDir to User PATH" -ForegroundColor Cyan
}
if (($env:Path -split ';' | ForEach-Object { $_.TrimEnd('\') }) -notcontains $normInstall) {
  $env:Path = "$InstallDir;$env:Path"
}

# Idempotent PowerShell completion hook
$compScript = Join-Path $CompDir 'aiup.ps1'
if ($PROFILE) {
  $profileDir = Split-Path $PROFILE -Parent
  if ($profileDir -and -not (Test-Path -LiteralPath $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
  }
  $existingProfile = if (Test-Path -LiteralPath $PROFILE) { Get-Content -LiteralPath $PROFILE -Raw -ErrorAction SilentlyContinue } else { '' }
  if (-not $existingProfile -or $existingProfile -notmatch [regex]::Escape('# Added by aiup installer')) {
    $snippet = "`n# Added by aiup installer`nif (Test-Path -LiteralPath '$compScript') { . '$compScript' }`n"
    Add-Content -LiteralPath $PROFILE -Value $snippet -Encoding UTF8
    Write-Host "  ↳ Enabled PowerShell tab completion in $PROFILE" -ForegroundColor Cyan
  }
}

# Runtime sanity check
$hasGitBash = @(
  (Join-Path $env:ProgramFiles 'Git\bin\bash.exe'),
  $(if (${env:ProgramFiles(x86)}) { Join-Path ${env:ProgramFiles(x86)} 'Git\bin\bash.exe' }),
  (Join-Path $env:LOCALAPPDATA 'Programs\Git\bin\bash.exe')
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

if (-not $hasGitBash) {
  Write-Warning 'Git Bash was not detected. Install Git for Windows (winget install Git.Git) to run aiup.'
}
if (-not (Get-Command python -ErrorAction SilentlyContinue) -and -not (Get-Command python3 -ErrorAction SilentlyContinue)) {
  Write-Warning 'Python 3 was not detected on PATH. Some checks (JSON, version comparisons) require Python 3.'
}

Write-Host "✔ aiup installed to $InstallDir (commands: aiup, uai)" -ForegroundColor Green
Write-Host "  Run 'aiup -l' or 'uai -l' to inspect your installed AI harnesses and desktop apps.`n"
