param(
  [string]$Configuration = "Release"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $root 'src\Program.cs'
$srcGz = Join-Path $root 'src\Program.cs.gz'
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $out | Out-Null

if (!(Test-Path -LiteralPath $src)) {
  if (!(Test-Path -LiteralPath $srcGz)) { throw 'Neither src\Program.cs nor src\Program.cs.gz exists.' }
  $inputStream = [System.IO.File]::OpenRead($srcGz)
  try {
    $gzipStream = New-Object System.IO.Compression.GzipStream($inputStream, [System.IO.Compression.CompressionMode]::Decompress)
    try {
      $outputStream = [System.IO.File]::Create($src)
      try { $gzipStream.CopyTo($outputStream) } finally { $outputStream.Dispose() }
    } finally { $gzipStream.Dispose() }
  } finally { $inputStream.Dispose() }
}

$overlayApplicator = Join-Path $root 'tools\Apply-ModernVoiceOverlay.ps1'
if (!(Test-Path -LiteralPath $overlayApplicator)) { throw 'Modern voice overlay applicator is missing.' }
& $overlayApplicator -SourcePath $src -ProductName 'SignalFlow Mini' -Marker 'SIGNALFLOW-MINI-MODERN-VOICE-OVERLAY-V1-RD3'

$exe = Join-Path $out 'SignalFlow-Mini.exe'
if (Test-Path $exe) { Remove-Item -Force $exe }
$refs = @('System.dll','System.Core.dll','System.Drawing.dll','System.Windows.Forms.dll')
$addTypeCommand = Get-Command Add-Type -ErrorAction Stop
$compile = @{
  Path = $src
  ReferencedAssemblies = $refs
  OutputAssembly = $exe
  OutputType = 'WindowsApplication'
}
if ($addTypeCommand.Parameters.ContainsKey('CompilerOptions')) { $compile['CompilerOptions'] = '/optimize+' }
Add-Type @compile
if (!(Test-Path $exe)) { throw 'SignalFlow-Mini.exe was not produced.' }
$hash = (Get-FileHash $exe -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  SignalFlow-Mini.exe" | Set-Content -Encoding ascii (Join-Path $out 'SignalFlow-Mini.exe.sha256')
Write-Host "Built $exe"
Write-Host "SHA-256 $hash"
