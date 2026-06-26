<#
.SYNOPSIS
    Installer for crpr on Windows (PowerShell).

.DESCRIPTION
    Copies crpr.ps1 and crpr.cmd into a per-user programs directory and adds it
    to your user PATH so `crpr` works from PowerShell and the classic command
    prompt (cmd.exe).

.EXAMPLE
    ./install.ps1
#>
[CmdletBinding()]
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\crpr')
)

$ErrorActionPreference = 'Stop'
$srcDir = Split-Path -Parent $MyInvocation.MyCommand.Path

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

foreach ($file in 'crpr.ps1', 'crpr.cmd') {
    Copy-Item -Path (Join-Path $srcDir $file) -Destination $InstallDir -Force
}
Write-Host "Installed crpr to: $InstallDir"

# Add to user PATH if missing.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $InstallDir) {
    $newPath = if ([string]::IsNullOrEmpty($userPath)) { $InstallDir }
               else { "$userPath;$InstallDir" }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "Added '$InstallDir' to your user PATH."
    Write-Host "Open a NEW terminal, then run: crpr --help"
} else {
    Write-Host "'$InstallDir' is already on your PATH. Try: crpr --help"
}
