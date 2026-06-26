@echo off
REM crpr launcher for the classic Windows command prompt (cmd.exe).
REM Prefers PowerShell 7+ (pwsh); falls back to Windows PowerShell.
where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0crpr.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0crpr.ps1" %*
)
