@echo off
setlocal

:: 1. Search known installation paths for pwsh.exe
set "PWSH_EXE="

if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" (
    set "PWSH_EXE=%ProgramFiles%\PowerShell\7\pwsh.exe"
) else if exist "%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" (
    set "PWSH_EXE=%ProgramFiles(x86)%\PowerShell\7\pwsh.exe"
) else if exist "%LOCALAPPDATA%\Programs\PowerShell\7\pwsh.exe" (
    set "PWSH_EXE=%LOCALAPPDATA%\Programs\PowerShell\7\pwsh.exe"
) else if exist "%LOCALAPPDATA%\Microsoft\WindowsApps\Microsoft.PowerShell_8wekyb3d8bbwe\pwsh.exe" (
    set "PWSH_EXE=%LOCALAPPDATA%\Microsoft\WindowsApps\Microsoft.PowerShell_8wekyb3d8bbwe\pwsh.exe"
) else (
    where pwsh >nul 2>nul
    if not errorlevel 1 set "PWSH_EXE=pwsh"
)

:: 2. Launch in PowerShell 7 if available, otherwise launch in Windows PowerShell 5.1
if defined PWSH_EXE (
    "%PWSH_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0Main.ps1"
) else (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Main.ps1"
)
pause
