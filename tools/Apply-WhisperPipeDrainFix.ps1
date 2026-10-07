param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Stop-Patch {
    param([string]$Message)
    throw ('SignalFlow Mini V1/RD3 transcription patch stopped: ' + $Message)
}

if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
    Stop-Patch ('source file not found: ' + $SourcePath)
}

$sourceFullPath = [System.IO.Path]::GetFullPath($SourcePath)
$sourceText = [System.IO.File]::ReadAllText($sourceFullPath)
$marker = 'SIGNALFLOW-MINI-WHISPER-PIPE-DRAIN-V1-RD3'

$old = @'
                using (var p = Process.Start(psi))
                {
                    string stdout = p.StandardOutput.ReadToEnd();
                    string stderr = p.StandardError.ReadToEnd();
                    if (!p.WaitForExit(120000))
                    {
                        try { p.Kill(); } catch { }
                        throw new TimeoutException("Local recognizer exceeded 120 seconds.");
                    }
                    if (p.ExitCode != 0)
                    {
                        string detail = (stderr ?? "").Trim();
                        if (detail.Length > 240) detail = detail.Substring(detail.Length - 240);
                        throw new InvalidOperationException("whisper-cli failed (" + p.ExitCode + "): " + detail);
                    }
                    return NormalizeTranscript(stdout);
                }
'@

$new = @'
                using (var p = Process.Start(psi))
                {
                    // SIGNALFLOW-MINI-WHISPER-PIPE-DRAIN-V1-RD3
                    // Drain stdout and stderr concurrently. Sequential ReadToEnd calls can
                    // deadlock when whisper.cpp fills stderr before stdout reaches EOF.
                    Task<string> stdoutTask = p.StandardOutput.ReadToEndAsync();
                    Task<string> stderrTask = p.StandardError.ReadToEndAsync();

                    if (!p.WaitForExit(120000))
                    {
                        try { p.Kill(); } catch { }
                        try { p.WaitForExit(5000); } catch { }
                        throw new TimeoutException("Local recognizer exceeded 120 seconds.");
                    }

                    string stdout = stdoutTask.GetAwaiter().GetResult();
                    string stderr = stderrTask.GetAwaiter().GetResult();

                    if (p.ExitCode != 0)
                    {
                        string detail = (stderr ?? "").Trim();
                        if (detail.Length > 240) detail = detail.Substring(detail.Length - 240);
                        throw new InvalidOperationException("whisper-cli failed (" + p.ExitCode + "): " + detail);
                    }
                    return NormalizeTranscript(stdout);
                }
'@

if ($sourceText.IndexOf($marker, [System.StringComparison]::Ordinal) -ge 0) {
    Write-Host ('SignalFlow Mini whisper pipe-drain fix already present: ' + $marker)
    return
}

if ($sourceText.IndexOf($old, [System.StringComparison]::Ordinal) -lt 0) {
    Stop-Patch 'expected sequential whisper stdout/stderr block was not found'
}

$patched = $sourceText.Replace($old, $new)

foreach ($required in @(
    $marker,
    'ReadToEndAsync()',
    'stdoutTask.GetAwaiter().GetResult()',
    'stderrTask.GetAwaiter().GetResult()',
    'WaitForExit(120000)',
    'NormalizeTranscript(stdout)'
)) {
    if ($patched.IndexOf($required, [System.StringComparison]::Ordinal) -lt 0) {
        Stop-Patch ('required transcription marker missing after patch: ' + $required)
    }
}

if ($patched.IndexOf('string stdout = p.StandardOutput.ReadToEnd();', [System.StringComparison]::Ordinal) -ge 0 -or
    $patched.IndexOf('string stderr = p.StandardError.ReadToEnd();', [System.StringComparison]::Ordinal) -ge 0) {
    Stop-Patch 'sequential redirected-pipe reads remain after patch'
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($sourceFullPath, $patched, $utf8NoBom)
Write-Host 'Applied SignalFlow Mini V1/RD3 concurrent whisper stdout/stderr drain fix.'
