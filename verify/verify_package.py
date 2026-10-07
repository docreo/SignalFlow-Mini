from pathlib import Path
import gzip, re, sys, hashlib

ROOT=Path(__file__).resolve().parents[1]
checks=[]

def check(name, cond):
    ok=bool(cond)
    checks.append((name,ok))
    print(('PASS' if ok else 'FAIL')+' - '+name)

def text(p):
    return (ROOT/p).read_text(encoding='utf-8')

def base_program_source():
    gz=ROOT/'src/Program.cs.gz'
    if not gz.is_file():
        return ''
    with gzip.open(gz,'rt',encoding='utf-8') as fh:
        return fh.read()

required=[
    'src/Program.cs.gz','build.ps1','install.ps1','uninstall.ps1',
    'SignalFlow-Mini.ps1','INSTALL-SIGNALFLOW-MINI.cmd','BUILD-AND-INSTALL.cmd',
    'README.md','VERSION','LICENSE','NOTICE','THIRD-PARTY-NOTICES.md',
    'docs/ORIGIN-AND-LINEAGE.md','docs/TESTING.md','docs/SOURCE.md',
    'ROADMAP.md','CHANGELOG.md','CONTRIBUTING.md','SECURITY.md',
    'assets/Signalproof.ico',
    'tools/SignalFlowMiniOverlay.cs.txt',
    'tools/Apply-SignalFlowMiniOverlay.ps1',
    'tools/Apply-WhisperPipeDrainFix.ps1'
]

base=base_program_source()
installer=text('install.ps1')
build=text('build.ps1')
readme=text('README.md')
overlay=text('tools/SignalFlowMiniOverlay.cs.txt')
overlay_patch=text('tools/Apply-SignalFlowMiniOverlay.ps1')
pipe_patch=text('tools/Apply-WhisperPipeDrainFix.ps1')
version=text('VERSION').strip()

check('01 required public package files', all((ROOT/p).is_file() for p in required))
check('02 public candidate version identity', version=='SIGNALFLOW-MINI-V1-RD3-PUBLIC-CANDIDATE')
check('03 base runtime uses SignalFlow Mini identity', 'SignalFlow Mini - Ready' in base and 'ReoFlow - Ready' not in base)
check('04 executable identity retained', 'SignalFlow-Mini.exe' in build and 'SignalFlow-Mini.exe' in installer)
check('05 selectable install path', 'FolderBrowserDialog' in installer and '[string]$InstallPath' in installer)
check('06 no fixed owner drive paths', not re.search(r"['\"](?:[A-Z]):\\", installer))
check('07 F8 global hook preserved', 'VK_F8 = 0x77' in base and 'WH_KEYBOARD_LL' in base)
check('08 microphone capture preserved', 'MemoryStream _pcm' in base and 'waveInOpen' in base)
check('09 PCM 16k mono 16-bit preserved', 'nSamplesPerSec = 16000' in base and 'wBitsPerSample = 16' in base)
check('10 500 ms pre-roll preserved', 'PreRollMilliseconds = 500' in base and 'CopyPreRollTo(_pcm)' in base)
check('11 650 ms post-roll preserved', 'PostRollMilliseconds = 650' in base and 'Task.Delay(PostRollMilliseconds)' in base)
check('12 local whisper invocation preserved', 'whisper-cli.exe' in base and '-l en -nt -np' in base)
check('13 clipboard recovery preserved', 'Clipboard.SetText(text)' in base)
check('14 guarded browser paste preserved', 'SendInput' in base and 'GetForegroundWindow() != _targetWindow' in base)
check('15 classic paste timeout preserved', 'SendMessageTimeout' in base and '2000' in base)
check('16 focus guard preserved', 'CapturePasteTarget' in base and 'focusedNow != _targetControl' in base)
check('17 public mutex identity', r'Local\\SignalFlow-Mini-v1' in base and 'OwnerTest' not in base)
check('18 quick tap guard preserved', 'held.TotalMilliseconds < 220' in base)
check('19 temp WAV lifecycle preserved', 'File.WriteAllBytes(wavPath' in base and 'File.Delete(wavPath)' in base)
check('20 listening/processing hooks preserved', '_overlay.ShowListening(_targetWindow)' in base and '_overlay.ShowProcessing(_targetWindow)' in base)
check('21 overlay template public identity', '"SIGNALFLOW MINI"' in overlay and '"REOFLOW"' not in overlay)
check('22 overlay exposes only requested visible activity labels', '"LISTENING"' in overlay and '"TRANSCRIBING"' in overlay and '"THINKING"' not in overlay and '"RESPONDING"' not in overlay)
check('23 red/gold swirl visual contract', 'DrawSwirl' in overlay and 'FromArgb(224, 24, 42)' in overlay and 'FromArgb(255, 199, 74)' in overlay)
check('24 overlay patch is bounded to AudioOverlayForm', 'AudioOverlayForm' in overlay_patch and 'protected behavior marker' in overlay_patch)
check('25 whisper pipe-drain fix marker', 'SIGNALFLOW-MINI-WHISPER-PIPE-DRAIN-V1-RD3' in pipe_patch)
check('26 concurrent stdout/stderr drain', pipe_patch.count('ReadToEndAsync()') >= 2 and 'stdoutTask.GetAwaiter().GetResult()' in pipe_patch and 'stderrTask.GetAwaiter().GetResult()' in pipe_patch)
check('27 old sequential pipe reads rejected by patch', 'sequential redirected-pipe reads remain after patch' in pipe_patch)
check('28 build applies both public RD3 patches', 'Apply-SignalFlowMiniOverlay.ps1' in build and 'Apply-WhisperPipeDrainFix.ps1' in build)
check('29 build regenerates generated source', "Remove-Item -LiteralPath $src -Force" in build and 'GzipStream' in build)
check('30 pinned model hash', 'c6138d6d58ecc8322097e0f987c32f1be8bb0a18532a3f88f734d1bbf9c41e5d' in installer)
check('31 pinned whisper archive hash', 'b07ea0b1b4115a38e1a7b07debf581f0b77d999925f8acb8f39d322b0ba0a822' in installer)
check('32 atomic stage/rollback retained', '.SignalFlow-Mini-stage-' in installer and '.SignalFlow-Mini-backup-' in installer and 'Move-Item -LiteralPath $backup' in installer)
check('33 Apache 2.0 present', 'Apache License' in text('LICENSE') and 'Version 2.0' in text('LICENSE'))
check('34 lineage remains documentation-only', 'ReoSpeak' in text('docs/ORIGIN-AND-LINEAGE.md') and 'ReoFlow' in text('docs/ORIGIN-AND-LINEAGE.md'))
check('35 giveaway language present', 'free, open-source' in readme and 'giveaway' in readme)
check('36 Clarity Core CTA present', 'https://signalproof.com/cccore' in readme)
check('37 RD3 refinement documented', 'V1/RD3' in readme and 'red-and-gold' in readme)

generated=ROOT/'src/Program.cs'
if generated.is_file():
    final=generated.read_text(encoding='utf-8')
    check('38 generated source has public overlay marker', 'SIGNALFLOW-MINI-RED-GOLD-OVERLAY-V1-RD3' in final)
    check('39 generated source has pipe-drain marker', 'SIGNALFLOW-MINI-WHISPER-PIPE-DRAIN-V1-RD3' in final)
    check('40 generated source has public display identity', '"SIGNALFLOW MINI"' in final and '"REOFLOW"' not in final)
    check('41 generated source removed sequential pipe reads', 'string stdout = p.StandardOutput.ReadToEnd();' not in final and 'string stderr = p.StandardError.ReadToEnd();' not in final)
else:
    check('38 generated source optional before build', True)
    check('39 generated source optional before build', True)
    check('40 generated source optional before build', True)
    check('41 generated source optional before build', True)

exe=ROOT/'dist/SignalFlow-Mini.exe'
sha_file=ROOT/'dist/SignalFlow-Mini.exe.sha256'
if exe.is_file() and sha_file.is_file():
    expected=sha_file.read_text(encoding='ascii').strip().split()[0].lower()
    actual=hashlib.sha256(exe.read_bytes()).hexdigest()
    check('42 built executable hash file matches', actual==expected)
else:
    check('42 built executable hash optional before build', True)

joined='\n'.join(text(p) for p in required if (ROOT/p).suffix.lower() in {'.ps1','.md','.cmd','.json','.txt'})
secrets=re.findall(r'(?i)(api[_-]?key|secret|token)\s*[=:]\s*["\'][^"\']{8,}',joined)
check('43 no embedded secret assignments', not secrets)
check('44 no internal public-control files', all(not (ROOT/p).exists() for p in ['AGENTS.md','SOUL.md','LOCK.json','evidence.json','OWNER-TEST-CHECKLIST.md','verification.txt']))
check('45 public patch files contain no private machine drive roots', not re.search(r"(?i)[A-Z]:\\", overlay_patch+'\n'+pipe_patch))

failed=[n for n,ok in checks if not ok]
print(f'\nRESULT: {len(checks)-len(failed)}/{len(checks)} checks passed')
if failed:
    print('FAILED: '+', '.join(failed))
    sys.exit(1)
