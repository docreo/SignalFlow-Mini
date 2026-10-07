param(
  [string]$Configuration = "Release"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $root 'src\Program.cs'
$srcGz = Join-Path $root 'src\Program.cs.gz'
$out = Join-Path $root 'dist'
$tools = Join-Path $root 'tools'
New-Item -ItemType Directory -Force $out | Out-Null

if (!(Test-Path -LiteralPath $srcGz)) {
  throw 'src\Program.cs.gz is missing.'
}

# Always regenerate the build source from the immutable public base archive.
# This prevents a stale generated Program.cs from bypassing or duplicating RD3 patches.
if (Test-Path -LiteralPath $src) { Remove-Item -LiteralPath $src -Force }
$input = [System.IO.File]::OpenRead($srcGz)
try {
  $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.CompressionMode]::Decompress)
  try {
    $output = [System.IO.File]::Create($src)
    try { $gzip.CopyTo($output) } finally { $output.Dispose() }
  } finally { $gzip.Dispose() }
} finally { $input.Dispose() }

$overlayPatch = Join-Path $tools 'Apply-SignalFlowMiniOverlay.ps1'
$pipePatch = Join-Path $tools 'Apply-WhisperPipeDrainFix.ps1'
foreach ($requiredPatch in @($overlayPatch,$pipePatch)) {
  if (!(Test-Path -LiteralPath $requiredPatch)) {
    throw "Required public RD3 patch is missing: $requiredPatch"
  }
}

& $overlayPatch -SourcePath $src
& $pipePatch -SourcePath $src

$patched = [System.IO.File]::ReadAllText($src)
foreach ($required in @(
  'SIGNALFLOW-MINI-RED-GOLD-OVERLAY-V1-RD3',
  'SIGNALFLOW-MINI-WHISPER-PIPE-DRAIN-V1-RD3',
  '"SIGNALFLOW MINI"',
  '"LISTENING"',
  '"TRANSCRIBING"',
  'ReadToEndAsync()',
  'Clipboard.SetText(text)',
  '_overlay.ShowListening(_targetWindow)',
  '_overlay.ShowProcessing(_targetWindow)'
)) {
  if ($patched.IndexOf($required, [System.StringComparison]::Ordinal) -lt 0) {
    throw "SignalFlow Mini RD3 patched source is missing required marker: $required"
  }
}
if ($patched.IndexOf('"REOFLOW"', [System.StringComparison]::Ordinal) -ge 0) {
  throw 'Private ReoFlow display identity leaked into public build source.'
}

$exe = Join-Path $out 'SignalFlow-Mini.exe'
if (Test-Path $exe) { Remove-Item -Force $exe }
$refs = @('System.dll','System.Core.dll','System.Drawing.dll','System.Windows.Forms.dll')
$addType = Get-Command Add-Type -ErrorAction Stop
$compile = @{
  Path = $src
  ReferencedAssemblies = $refs
  OutputAssembly = $exe
  OutputType = 'WindowsApplication'
}
if ($addType.Parameters.ContainsKey('CompilerOptions')) { $compile['CompilerOptions'] = '/optimize+' }
Add-Type @compile
if (!(Test-Path $exe)) { throw 'SignalFlow-Mini.exe was not produced.' }
$hash = (Get-FileHash $exe -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  SignalFlow-Mini.exe" | Set-Content -Encoding ascii (Join-Path $out 'SignalFlow-Mini.exe.sha256')
Write-Host "Built $exe"
Write-Host "SHA-256 $hash"
Write-Host 'SignalFlow Mini V1/RD3 visual states: LISTENING -> TRANSCRIBING'
