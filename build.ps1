param(
  [string]$Configuration = "Release"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $root 'src\Program.cs'
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $out | Out-Null
$exe = Join-Path $out 'SignalFlow-Mini.exe'
if (Test-Path $exe) { Remove-Item -Force $exe }

if (!(Test-Path -LiteralPath $src)) { throw 'src\Program.cs is missing.' }

$refs = @('System.dll','System.Core.dll','System.Drawing.dll','System.Windows.Forms.dll')
$addType = Get-Command Add-Type -ErrorAction Stop
$compile = @{
  Path = $src
  ReferencedAssemblies = $refs
  OutputAssembly = $exe
  OutputType = 'WindowsApplication'
}

if ($addType.Parameters.ContainsKey('CompilerOptions')) {
  $compile['CompilerOptions'] = '/optimize+'
  Write-Host 'Building SignalFlow Mini with optimization enabled...'
} else {
  Write-Host 'Building SignalFlow Mini with compatibility Add-Type path...'
}

Add-Type @compile
if (!(Test-Path $exe)) { throw 'SignalFlow-Mini.exe was not produced.' }
$hash = (Get-FileHash $exe -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  SignalFlow-Mini.exe" | Set-Content -Encoding ascii (Join-Path $out 'SignalFlow-Mini.exe.sha256')
Write-Host "Built $exe"
Write-Host "SHA-256 $hash"
