param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Stop-OverlayPatch {
    param([string]$Message)
    throw ('SignalFlow Mini V1/RD3 overlay patch stopped: ' + $Message)
}

if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    Stop-OverlayPatch ('source file not found: ' + $SourcePath)
}

$templatePath = Join-Path $PSScriptRoot 'SignalFlowMiniOverlay.cs.txt'
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    Stop-OverlayPatch ('overlay template not found: ' + $templatePath)
}

$sourceFullPath = [System.IO.Path]::GetFullPath($SourcePath)
$sourceText = [System.IO.File]::ReadAllText($sourceFullPath)
$marker = 'SIGNALFLOW-MINI-RED-GOLD-OVERLAY-V1-RD3'

$protectedMarkers = @(
    'VK_F8 = 0x77',
    'WH_KEYBOARD_LL',
    'MemoryStream _pcm',
    'whisper-cli.exe',
    'Clipboard.SetText(text)',
    '_overlay.ShowListening(_targetWindow)',
    '_overlay.ShowProcessing(_targetWindow)'
)
foreach ($protectedMarker in $protectedMarkers) {
    if ($sourceText.IndexOf($protectedMarker, [System.StringComparison]::Ordinal) -lt 0) {
        Stop-OverlayPatch ('protected behavior marker missing before patch: ' + $protectedMarker)
    }
}

if ($sourceText.IndexOf($marker, [System.StringComparison]::Ordinal) -ge 0) {
    Write-Host ('SignalFlow Mini overlay already present: ' + $marker)
    return
}

$templateText = [System.IO.File]::ReadAllText($templatePath)
if ($templateText.IndexOf($marker, [System.StringComparison]::Ordinal) -lt 0) {
    Stop-OverlayPatch 'overlay template marker is missing'
}

$pattern = '(?s)    internal sealed class AudioOverlayForm : Form\s*\{.*?(?=    internal sealed class [A-Za-z0-9_]+HostForm : Form)'
$overlayRegex = New-Object System.Text.RegularExpressions.Regex($pattern)
$matches = $overlayRegex.Matches($sourceText)
if ($matches.Count -ne 1) {
    Stop-OverlayPatch ('expected exactly one AudioOverlayForm block; found ' + $matches.Count)
}

$patched = $overlayRegex.Replace(
    $sourceText,
    [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $templateText + [Environment]::NewLine },
    1
)

foreach ($required in @(
    $marker,
    'DrawSwirl',
    '"SIGNALFLOW MINI"',
    '"LISTENING"',
    '"TRANSCRIBING"',
    'System.Drawing.Color.FromArgb(224, 24, 42)',
    'System.Drawing.Color.FromArgb(255, 199, 74)'
)) {
    if ($patched.IndexOf($required, [System.StringComparison]::Ordinal) -lt 0) {
        Stop-OverlayPatch ('required visual marker missing after patch: ' + $required)
    }
}

if ($patched.IndexOf('"REOFLOW"', [System.StringComparison]::Ordinal) -ge 0) {
    Stop-OverlayPatch 'private ReoFlow display identity leaked into public overlay'
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($sourceFullPath, $patched, $utf8NoBom)
Write-Host 'Applied SignalFlow Mini V1/RD3 red/gold activity overlay.'
