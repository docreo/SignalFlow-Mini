param(
  [string]$InstallPath
)
$ErrorActionPreference = 'Stop'
$metadataRoot = Join-Path $env:LOCALAPPDATA 'Signalproof\SignalFlow-Mini'
$locationFile = Join-Path $metadataRoot 'install-location.txt'

if ($InstallPath) {
  $installRoot = [System.IO.Path]::GetFullPath($InstallPath.Trim().Trim('"'))
} elseif (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'SignalFlow-Mini.exe')) {
  $installRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
} elseif (Test-Path -LiteralPath $locationFile) {
  $installRoot = [System.IO.Path]::GetFullPath((Get-Content -LiteralPath $locationFile -Raw).Trim())
} else {
  throw 'SignalFlow Mini install location could not be determined.'
}

$rootPath = [System.IO.Path]::GetPathRoot($installRoot)
if ($installRoot.TrimEnd('\') -eq $rootPath.TrimEnd('\')) { throw 'Refusing to uninstall from a drive root.' }
if ([System.IO.Path]::GetFileName($installRoot.TrimEnd('\')) -ne 'SignalFlow-Mini') { throw 'Refusing to remove a directory not named SignalFlow-Mini.' }
if (!(Test-Path -LiteralPath (Join-Path $installRoot 'VERSION')) -and !(Test-Path -LiteralPath (Join-Path $installRoot 'SignalFlow-Mini.exe'))) {
  throw "Refusing to remove an unrecognized directory: $installRoot"
}

Get-Process SignalFlow-Mini -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
$desktop = [Environment]::GetFolderPath('Desktop')
$shortcut = Join-Path $desktop 'SignalFlow Mini.lnk'
if (Test-Path -LiteralPath $shortcut) { Remove-Item -LiteralPath $shortcut -Force }
if (Test-Path -LiteralPath $installRoot) { Remove-Item -LiteralPath $installRoot -Recurse -Force }
if (Test-Path -LiteralPath $locationFile) { Remove-Item -LiteralPath $locationFile -Force }
if ((Test-Path -LiteralPath $metadataRoot) -and -not (Get-ChildItem -LiteralPath $metadataRoot -Force | Select-Object -First 1)) { Remove-Item -LiteralPath $metadataRoot -Force }
Write-Host 'SignalFlow Mini removed.'
