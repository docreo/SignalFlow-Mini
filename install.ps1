param(
  [switch]$SkipBuild,
  [switch]$NoLaunch,
  [string]$InstallPath
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$metadataRoot = Join-Path $env:LOCALAPPDATA 'Signalproof\SignalFlow-Mini'
$locationFile = Join-Path $metadataRoot 'install-location.txt'

$whisperUrl = 'https://github.com/ggml-org/whisper.cpp/releases/download/v1.8.6/whisper-bin-x64.zip'
$whisperSha256 = 'b07ea0b1b4115a38e1a7b07debf581f0b77d999925f8acb8f39d322b0ba0a822'
$modelUrl = 'https://huggingface.co/ggerganov/whisper.cpp/resolve/80da2d8bfee42b0e836fc3a9890373e5defc00a6/ggml-small.en.bin'
$modelSha256 = 'c6138d6d58ecc8322097e0f987c32f1be8bb0a18532a3f88f734d1bbf9c41e5d'

function Assert-Hash([string]$Path,[string]$Expected) {
  if (!(Test-Path -LiteralPath $Path)) { throw "Missing file: $Path" }
  $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $Expected.ToLowerInvariant()) { throw "SHA-256 mismatch for $Path`nExpected $Expected`nActual   $actual" }
}

function Resolve-InstallRoot([string]$RequestedPath) {
  if ($RequestedPath) {
    return [System.IO.Path]::GetFullPath($RequestedPath.Trim().Trim('"'))
  }

  Add-Type -AssemblyName System.Windows.Forms
  $defaultParent = Join-Path $env:LOCALAPPDATA 'Programs'
  New-Item -ItemType Directory -Force $defaultParent | Out-Null
  $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
  $dialog.Description = 'Choose the parent folder for SignalFlow Mini. A SignalFlow-Mini folder will be created inside it.'
  $dialog.SelectedPath = $defaultParent
  $dialog.ShowNewFolderButton = $true
  $result = $dialog.ShowDialog()
  if ($result -ne [System.Windows.Forms.DialogResult]::OK) { throw 'Installation cancelled by user.' }
  return [System.IO.Path]::GetFullPath((Join-Path $dialog.SelectedPath 'SignalFlow-Mini'))
}

function Assert-SafeInstallRoot([string]$Path) {
  if ([string]::IsNullOrWhiteSpace($Path)) { throw 'Install path is empty.' }
  $full = [System.IO.Path]::GetFullPath($Path)
  $rootPath = [System.IO.Path]::GetPathRoot($full)
  if ($full.TrimEnd('\') -eq $rootPath.TrimEnd('\')) { throw 'Refusing to install directly into a drive root.' }
  if ([System.IO.Path]::GetFileName($full.TrimEnd('\')) -ne 'SignalFlow-Mini') {
    throw 'Install path must end in SignalFlow-Mini.'
  }
  return $full
}

function Get-PreviousInstallRoot {
  if (Test-Path -LiteralPath $locationFile) {
    $value = (Get-Content -LiteralPath $locationFile -Raw).Trim()
    if ($value) { return $value }
  }
  return $null
}

$installRoot = Assert-SafeInstallRoot (Resolve-InstallRoot $InstallPath)
$parentRoot = Split-Path -Parent $installRoot
New-Item -ItemType Directory -Force $parentRoot | Out-Null
$stage = Join-Path $parentRoot ('.SignalFlow-Mini-stage-' + [guid]::NewGuid().ToString('N'))
$backup = Join-Path $parentRoot ('.SignalFlow-Mini-backup-' + (Get-Date -Format 'yyyyMMddHHmmss'))
$previousInstall = Get-PreviousInstallRoot

function Find-VerifiedModel {
  $candidates = @()
  if ($previousInstall) { $candidates += (Join-Path $previousInstall 'models\ggml-small.en.bin') }
  $candidates += (Join-Path $installRoot 'models\ggml-small.en.bin')
  foreach ($candidate in $candidates | Select-Object -Unique) {
    if ($candidate -and (Test-Path -LiteralPath $candidate)) {
      try {
        Assert-Hash $candidate $modelSha256
        return $candidate
      } catch {
        Write-Warning "Ignoring corrupt or unrecognized model: $candidate"
      }
    }
  }
  return $null
}

try {
  Get-Process SignalFlow-Mini -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

  if (!$SkipBuild) { & (Join-Path $root 'build.ps1') }
  $builtExe = Join-Path $root 'dist\SignalFlow-Mini.exe'
  if (!(Test-Path $builtExe)) { throw 'dist\SignalFlow-Mini.exe is missing. Run BUILD-AND-INSTALL.cmd.' }

  if ((Test-Path -LiteralPath $installRoot) -and -not (Test-Path -LiteralPath (Join-Path $installRoot 'VERSION')) -and -not (Test-Path -LiteralPath (Join-Path $installRoot 'SignalFlow-Mini.exe'))) {
    throw "Refusing to replace an unrecognized directory: $installRoot"
  }

  New-Item -ItemType Directory -Force $stage | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $stage 'runtime\whisper') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $stage 'models') | Out-Null
  New-Item -ItemType Directory -Force (Join-Path $stage 'assets') | Out-Null
  Copy-Item $builtExe (Join-Path $stage 'SignalFlow-Mini.exe') -Force
  foreach ($file in @('VERSION','README.md','LICENSE','NOTICE','THIRD-PARTY-NOTICES.md')) {
    Copy-Item (Join-Path $root $file) (Join-Path $stage $file) -Force
  }
  Copy-Item (Join-Path $root 'uninstall.ps1') (Join-Path $stage 'uninstall.ps1') -Force
  Copy-Item (Join-Path $root 'assets\Signalproof.ico') (Join-Path $stage 'assets\Signalproof.ico') -Force

  $model = Find-VerifiedModel
  if ($model) {
    Write-Host "Reusing verified small.en model: $model"
    Copy-Item -LiteralPath $model -Destination (Join-Path $stage 'models\ggml-small.en.bin') -Force
  } else {
    $modelTmp = Join-Path $stage 'ggml-small.en.download'
    Write-Host 'Downloading pinned Whisper small.en model...'
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

  if (Test-Path -LiteralPath $installRoot) { Move-Item -LiteralPath $installRoot -Destination $backup }
  try {
    Move-Item -LiteralPath $stage -Destination $installRoot
  } catch {
    if (Test-Path -LiteralPath $backup) { Move-Item -LiteralPath $backup -Destination $installRoot }
    throw
  }
  if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }

  New-Item -ItemType Directory -Force $metadataRoot | Out-Null
  Set-Content -LiteralPath $locationFile -Value $installRoot -Encoding UTF8

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
  if ($previousInstall -and ([System.IO.Path]::GetFullPath($previousInstall) -ne $installRoot) -and (Test-Path -LiteralPath $previousInstall)) {
    Write-Warning "A previous installation remains at $previousInstall. Remove it manually after confirming the new installation works."
  }
  if (!$NoLaunch) { Start-Process (Join-Path $installRoot 'SignalFlow-Mini.exe') }
}
catch {
  if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue }
  if (!(Test-Path -LiteralPath $installRoot) -and (Test-Path -LiteralPath $backup)) { Move-Item -LiteralPath $backup -Destination $installRoot -ErrorAction SilentlyContinue }
  throw
}
