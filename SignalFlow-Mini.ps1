$ErrorActionPreference = 'Stop'
$metadataRoot = Join-Path $env:LOCALAPPDATA 'Signalproof\SignalFlow-Mini'
$locationFile = Join-Path $metadataRoot 'install-location.txt'
if (!(Test-Path -LiteralPath $locationFile)) { throw 'SignalFlow Mini install location is not registered. Run BUILD-AND-INSTALL.cmd.' }
$installRoot = (Get-Content -LiteralPath $locationFile -Raw).Trim()
$exe = Join-Path $installRoot 'SignalFlow-Mini.exe'
if (!(Test-Path -LiteralPath $exe)) { throw "SignalFlow Mini executable was not found at $exe" }
Start-Process $exe
