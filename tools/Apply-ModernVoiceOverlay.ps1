param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$ProductName,

    [string]$Marker = 'SIGNALPROOF-MODERN-VOICE-OVERLAY-RD3'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Stop-OverlayPatch {
    param([string]$Message)
    throw ('Modern voice overlay patch stopped: ' + $Message)
}

if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    Stop-OverlayPatch ('source file not found: ' + $SourcePath)
}
if ([string]::IsNullOrWhiteSpace($ProductName)) {
    Stop-OverlayPatch 'product name is empty'
}

$templatePath = Join-Path $PSScriptRoot 'ModernVoiceOverlay.cs.txt'
if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
    Stop-OverlayPatch ('overlay template not found: ' + $templatePath)
}

$sourceFullPath = [System.IO.Path]::GetFullPath($SourcePath)
$sourceText = [System.IO.File]::ReadAllText($sourceFullPath)
if ([string]::IsNullOrWhiteSpace($sourceText)) {
    Stop-OverlayPatch 'source file is empty'
}

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

if ($sourceText.IndexOf($Marker, [System.StringComparison]::Ordinal) -ge 0) {
    Write-Host ('Modern voice overlay already present: ' + $Marker)
    return
}

$classAnchor = 'internal sealed class AudioOverlayForm : Form'
if ($sourceText.IndexOf($classAnchor, [System.StringComparison]::Ordinal) -lt 0) {
    Stop-OverlayPatch 'AudioOverlayForm class was not found'
}

$templateText = [System.IO.File]::ReadAllText($templatePath)
if ($templateText.IndexOf('__PRODUCT_NAME__', [System.StringComparison]::Ordinal) -lt 0 -or
    $templateText.IndexOf('__MARKER__', [System.StringComparison]::Ordinal) -lt 0) {
    Stop-OverlayPatch 'overlay template placeholders are incomplete'
}

$replacement = $templateText.Replace('__PRODUCT_NAME__', $ProductName).Replace('__MARKER__', $Marker)
$pattern = '(?s)    internal sealed class AudioOverlayForm : Form\s*\{.*?(?=    internal sealed class [A-Za-z0-9_]+HostForm : Form)'
$overlayRegex = New-Object System.Text.RegularExpressions.Regex($pattern)
$overlayMatches = $overlayRegex.Matches($sourceText)
if ($overlayMatches.Count -ne 1) {
    Stop-OverlayPatch ('expected exactly one AudioOverlayForm block; found ' + $overlayMatches.Count)
}

$patchedText = $overlayRegex.Replace(
    $sourceText,
    [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement + [Environment]::NewLine },
    1
)

if ([string]::Equals($patchedText, $sourceText, [System.StringComparison]::Ordinal)) {
    Stop-OverlayPatch 'patch produced no source change'
}
if ($patchedText.IndexOf($Marker, [System.StringComparison]::Ordinal) -lt 0) {
    Stop-OverlayPatch 'modern overlay marker missing after patch'
}
foreach ($protectedMarker in $protectedMarkers) {
    if ($patchedText.IndexOf($protectedMarker, [System.StringComparison]::Ordinal) -lt 0) {
        Stop-OverlayPatch ('protected behavior marker was lost by patch: ' + $protectedMarker)
    }
}
foreach ($requiredVisual in @(
    'CreatePillPath',
    'DrawRoundBar',
    'Transcribing locally',
    'LineCap.Round',
    'barCount = 11'
)) {
    if ($patchedText.IndexOf($requiredVisual, [System.StringComparison]::Ordinal) -lt 0) {
        Stop-OverlayPatch ('modern overlay visual marker missing: ' + $requiredVisual)
    }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($sourceFullPath, $patchedText, $utf8NoBom)
Write-Host ('Applied modern oval voice overlay: ' + $Marker)
Write-Host ('Product label: ' + $ProductName)
