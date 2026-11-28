#Requires -Version 5.1
# Windows PowerShell smoke test for aiup / uai wrappers (non-mutating)
$ErrorActionPreference = 'Stop'

$RootDir = Split-Path $PSScriptRoot -Parent
$AiupPs1 = Join-Path $RootDir 'bin\aiup.ps1'
$UaiPs1  = Join-Path $RootDir 'bin\uai.ps1'
$AiupCmd = Join-Path $RootDir 'bin\aiup.cmd'
$UaiCmd  = Join-Path $RootDir 'bin\uai.cmd'

$pass = 0
$fail = 0

function Assert-True {
  param([string]$Name, [bool]$Condition)
  if ($Condition) {
    Write-Host "PASS: $Name"
    $script:pass++
  } else {
    Write-Host "FAIL: $Name" -ForegroundColor Red
    $script:fail++
  }
}

# 1. PowerShell launcher help + version
$verOut = & $AiupPs1 -v
Assert-True 'aiup.ps1 -v succeeds' ($LASTEXITCODE -eq 0 -and $verOut -match 'aiup version')

$uaiVer = & $UaiPs1 -v
Assert-True 'uai.ps1 -v succeeds' ($LASTEXITCODE -eq 0 -and $uaiVer -match 'aiup version')

# 2. CMD launcher help + version
$cmdVer = & $AiupCmd -v
Assert-True 'aiup.cmd -v succeeds' ($LASTEXITCODE -eq 0 -and $cmdVer -match 'aiup version')

$uaiCmdVer = & $UaiCmd -v
Assert-True 'uai.cmd -v succeeds' ($LASTEXITCODE -eq 0 -and $uaiCmdVer -match 'aiup version')

# 3. Inventory JSON via PowerShell wrapper
$invJson = & $AiupPs1 -l --json | Out-String
$invObj = $invJson | ConvertFrom-Json
Assert-True 'aiup.ps1 -l --json parses cleanly' ($LASTEXITCODE -eq 0 -and $null -ne $invObj.cli_harnesses -and $null -ne $invObj.desktop_apps)

# 4. Unquoted comma-separated targets via PowerShell wrapper (-o clean-dumps,clean-electron)
$chkJson = & $AiupPs1 -c -C -o clean-dumps,clean-electron --json | Out-String
$chkObj = $chkJson | ConvertFrom-Json
Assert-True 'aiup.ps1 handles comma-separated targets' ($LASTEXITCODE -eq 0 -and $chkObj.mode -eq 'check' -and $chkObj.results.Count -ge 1)

Write-Host "`nPowerShell Summary: $pass passed, $fail failed"
if ($fail -gt 0) { exit 1 }
