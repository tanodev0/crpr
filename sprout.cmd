@echo off
REM sprout launcher for the classic Windows command prompt (cmd.exe).
REM Prefers PowerShell 7+ (pwsh); falls back to Windows PowerShell.
where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0sprout.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sprout.ps1" %*
)
