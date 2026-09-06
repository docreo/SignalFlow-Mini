$ErrorActionPreference = 'Stop'
$exe = Join-Path $env:LOCALAPPDATA 'SignalFlow-Mini\SignalFlow-Mini.exe'
if (!(Test-Path $exe)) { throw 'SignalFlow Mini is not installed. Run INSTALL-SIGNALFLOW-MINI.cmd.' }
Start-Process $exe
