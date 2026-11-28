@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
set "AIUP_SCRIPT=%SCRIPT_DIR%aiup"

if not exist "%AIUP_SCRIPT%" (
  echo [ERROR] Missing aiup engine at "%AIUP_SCRIPT%" >&2
  exit /b 1
)

call :find_bash
if not defined AIUP_BASH_EXE (
  echo [ERROR] Git Bash / MSYS2 bash.exe was not found. >&2
  echo Install Git for Windows: winget install Git.Git >&2
  exit /b 1
)

chcp 65001 >nul 2>&1
"%AIUP_BASH_EXE%" "%AIUP_SCRIPT%" %*
exit /b %ERRORLEVEL%

:find_bash
if defined AIUP_BASH if exist "%AIUP_BASH%" (
  set "AIUP_BASH_EXE=%AIUP_BASH%"
  exit /b 0
)

for %%P in (
  "%ProgramFiles%\Git\bin\bash.exe"
  "%ProgramFiles%\Git\usr\bin\bash.exe"
  "%ProgramFiles(x86)%\Git\bin\bash.exe"
  "%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
  "C:\msys64\usr\bin\bash.exe"
) do (
  if exist "%%~P" (
    set "AIUP_BASH_EXE=%%~P"
    exit /b 0
  )
)

for /f "delims=" %%G in ('where git.exe 2^>nul') do (
  for %%D in ("%%~dpG..\bin\bash.exe") do (
    if exist "%%~fD" (
      set "AIUP_BASH_EXE=%%~fD"
      exit /b 0
    )
  )
)

for /f "delims=" %%B in ('where bash.exe 2^>nul') do (
  echo "%%~B" | findstr /I /C:"\System32\bash.exe" >nul
  if errorlevel 1 (
    set "AIUP_BASH_EXE=%%~B"
    exit /b 0
  )
)
exit /b 1
