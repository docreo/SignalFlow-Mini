$ErrorActionPreference = 'Stop'
$installRoot = Join-Path $env:LOCALAPPDATA 'SignalFlow-Mini'
Get-Process SignalFlow-Mini -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$desktop = [Environment]::GetFolderPath('Desktop')
$shortcut = Join-Path $desktop 'SignalFlow Mini.lnk'
if (Test-Path $shortcut) { Remove-Item $shortcut -Force }
if (Test-Path $installRoot) { Remove-Item $installRoot -Recurse -Force }
Write-Host 'SignalFlow Mini removed.'
