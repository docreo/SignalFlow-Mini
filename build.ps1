param(
  [string]$Configuration = "Release"
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src = Join-Path $root 'src\Program.cs'
$srcGz = Join-Path $root 'src\Program.cs.gz'
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $out | Out-Null

# GitHub transport note: the canonical C# source may be stored as Program.cs.gz.
# Expand it locally before compilation so the checked-out repository remains buildable.
if (!(Test-Path -LiteralPath $src)) {
  if (!(Test-Path -LiteralPath $srcGz)) { throw 'Neither src\Program.cs nor src\Program.cs.gz exists.' }
  $input = [System.IO.File]::OpenRead($srcGz)
  try {
    $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.CompressionMode]::Decompress)
    try {
      $output = [System.IO.File]::Create($src)
      try { $gzip.CopyTo($output) } finally { $output.Dispose() }
    } finally { $gzip.Dispose() }
  } finally { $input.Dispose() }
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

if ($addType.Parameters.ContainsKey('CompilerOptions')) {
  $compile['CompilerOptions'] = '/optimize+'
  Write-Host 'Building SignalFlow Mini with Add-Type optimization enabled...'
} else {
  Write-Host 'Building SignalFlow Mini with compatibility Add-Type path...'
}

Add-Type @compile
if (!(Test-Path $exe)) { throw 'SignalFlow-Mini.exe was not produced.' }
$hash = (Get-FileHash $exe -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  SignalFlow-Mini.exe" | Set-Content -Encoding ascii (Join-Path $out 'SignalFlow-Mini.exe.sha256')
Write-Host "Built $exe"
Write-Host "SHA-256 $hash"
