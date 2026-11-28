#Requires -Version 5.1
& (Join-Path $PSScriptRoot 'aiup.ps1') @args
exit $LASTEXITCODE
