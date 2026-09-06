param(
  [switch]$SkipBuild,
  [switch]$NoLaunch
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$installRoot = Join-Path $env:LOCALAPPDATA 'SignalFlow-Mini'
$stage = Join-Path $env:LOCALAPPDATA ('.SignalFlow-Mini-stage-' + [guid]::NewGuid().ToString('N'))
$backup = Join-Path $env:LOCALAPPDATA ('.SignalFlow-Mini-backup-' + (Get-Date -Format 'yyyyMMddHHmmss'))

$whisperUrl = 'https://github.com/ggml-org/whisper.cpp/releases/download/v1.8.6/whisper-bin-x64.zip'
$whisperSha256 = 'b07ea0b1b4115a38e1a7b07debf581f0b77d999925f8acb8f39d322b0ba0a822'
$modelUrl = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/80da2d8bfee42b0e836fc3a9890373e5defc00a6/ggml-small.en.bin'
$modelSha256 = 'c6138d6d58ecc8322097e0f987c32f1be8bb0a18532a3f88f734d1bbf9c41e5d'

function Assert-Hash([string]$Path,[string]$Expected) {
  if (!(Test-Path -LiteralPath $Path)) { throw "Missing file: $Path" }
  $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $Expected.ToLowerInvariant()) { throw "SHA-256 mismatch for $Path`nExpected $Expected`nActual   $actual" }
}

function Find-VerifiedModel {
  $candidates = @(
    'F:\ggml-small.en.bin',
    'F:\Models\ggml-small.en.bin',
    'F:\Whisper\ggml-small.en.bin',
    'F:\AI\Models\Whisper\ggml-small.en.bin',
    'F:\SignalFlow-Mini\models\ggml-small.en.bin',
    'F:\ReoFlow\models\ggml-small.en.bin',
    'F:\ReoSpeak\models\ggml-small.en.bin',
    (Join-Path $installRoot 'models\ggml-small.en.bin')
  )
  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
      try {
        Assert-Hash $candidate $modelSha256
        return $candidate
      } catch {
        Write-Warning "Ignoring corrupt/unrecognized model: $candidate"
      }
    }
  }
  return $null
}

try {
  if (!$SkipBuild) { & (Join-Path $root 'build.ps1') }
  $builtExe = Join-Path $root 'dist\SignalFlow-Mini.exe'
  if (!(Test-Path $builtExe)) { throw 'dist\SignalFlow-Mini.exe is missing. Run BUILD-AND-INSTALL.cmd.' }

  New-Item -ItemType Directory -Force $stage | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $stage 'runtime\whisper') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $stage 'models') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $stage 'assets') | Out-Null
  Copy-Item $builtExe (Join-Path $stage 'SignalFlow-Mini.exe') -Force
  Copy-Item (Join-Path $root 'VERSION') (Join-Path $stage 'VERSION') -Force
  Copy-Item (Join-Path $root 'README.md') (Join-Path $stage 'README.md') -Force
  Copy-Item (Join-Path $root 'OWNER-TEST-CHECKLIST.md') (Join-Path $stage 'OWNER-TEST-CHECKLIST.md') -Force
  Copy-Item (Join-Path $root 'uninstall.ps1') (Join-Path $stage 'uninstall.ps1') -Force
  Copy-Item (Join-Path $root 'assets\Signalproof.ico') (Join-Path $stage 'assets\Signalproof.ico') -Force

  $model = Find-VerifiedModel
  if ($model) {
    Write-Host "Reusing verified small.en model: $model"
    Copy-Item -LiteralPath $model -Destination (Join-Path $stage 'models\ggml-small.en.bin') -Force
  } else {
    $modelTmp = Join-Path $stage 'ggml-small.en.download'
    Write-Host 'Downloading pinned Whisper small.en model once...'
    Invoke-WebRequest -UseBasicParsing -Uri $modelUrl -OutFile $modelTmp
    Assert-Hash $modelTmp $modelSha256
    Move-Item $modelTmp (Join-Path $stage 'models\ggml-small.en.bin') -Force
  }

  $whisperZip = Join-Path $stage 'whisper-bin-x64.zip'
  $whisperExtract = Join-Path $stage 'whisper-extract'
  Write-Host 'Downloading pinned whisper.cpp Windows x64 runtime...'
  Invoke-WebRequest -UseBasicParsing -Uri $whisperUrl -OutFile $whisperZip
  Assert-Hash $whisperZip $whisperSha256
  Expand-Archive -LiteralPath $whisperZip -DestinationPath $whisperExtract -Force
  $cli = Get-ChildItem $whisperExtract -Filter whisper-cli.exe -File -Recurse | Select-Object -First 1
  if (!$cli) { throw 'Pinned whisper.cpp archive did not contain whisper-cli.exe.' }
  $runtimeDir = $cli.Directory.FullName
  Get-ChildItem $runtimeDir -File | ForEach-Object { Copy-Item $_.FullName (Join-Path $stage 'runtime\whisper') -Force }
  Remove-Item $whisperZip -Force
  Remove-Item $whisperExtract -Recurse -Force

  Assert-Hash (Join-Path $stage 'models\ggml-small.en.bin') $modelSha256
  if (!(Test-Path (Join-Path $stage 'runtime\whisper\whisper-cli.exe'))) { throw 'whisper-cli staging failed.' }

  if (Test-Path $installRoot) { Move-Item $installRoot $backup }
  try {
    Move-Item $stage $installRoot
  } catch {
    if (Test-Path $backup) { Move-Item $backup $installRoot }
    throw
  }
  if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }

  $desktop = [Environment]::GetFolderPath('Desktop')
  $shortcutPath = Join-Path $desktop 'SignalFlow Mini.lnk'
  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($shortcutPath)
  $shortcut.TargetPath = Join-Path $installRoot 'SignalFlow-Mini.exe'
  $shortcut.WorkingDirectory = $installRoot
  $shortcut.Description = 'SignalFlow Mini local push-to-talk speech-to-text'
  $shortcut.IconLocation = (Join-Path $installRoot 'assets\Signalproof.ico') + ',0'
  $shortcut.Save()

  Write-Host "SignalFlow Mini installed to $installRoot"
  if (!$NoLaunch) { Start-Process (Join-Path $installRoot 'SignalFlow-Mini.exe') }
}
catch {
  if (Test-Path $stage) { Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue }
  if (!(Test-Path $installRoot) -and (Test-Path $backup)) { Move-Item $backup $installRoot -ErrorAction SilentlyContinue }
  throw
}
