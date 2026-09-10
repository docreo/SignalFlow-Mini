from pathlib import Path
import gzip, re, sys
ROOT=Path(__file__).resolve().parents[1]
checks=[]
def check(name, cond):
    ok=bool(cond); checks.append((name,ok)); print(('PASS' if ok else 'FAIL')+' - '+name)
def text(p): return (ROOT/p).read_text(encoding='utf-8')
def program_source():
    plain=ROOT/'src/Program.cs'
    if plain.is_file():
        return plain.read_text(encoding='utf-8')
    gz=ROOT/'src/Program.cs.gz'
    if not gz.is_file():
        return ''
    with gzip.open(gz,'rt',encoding='utf-8') as fh:
        return fh.read()
required=['src/Program.cs.gz','build.ps1','install.ps1','uninstall.ps1','SignalFlow-Mini.ps1','INSTALL-SIGNALFLOW-MINI.cmd','BUILD-AND-INSTALL.cmd','README.md','VERSION','LICENSE','NOTICE','THIRD-PARTY-NOTICES.md','docs/ORIGIN-AND-LINEAGE.md','docs/TESTING.md','docs/SOURCE.md','ROADMAP.md','CHANGELOG.md','CONTRIBUTING.md','SECURITY.md','assets/Signalproof.ico','tools/ModernVoiceOverlay.cs.txt','tools/Apply-ModernVoiceOverlay.ps1']
program=program_source(); installer=text('install.ps1'); build=text('build.ps1'); readme=text('README.md'); overlay=text('tools/ModernVoiceOverlay.cs.txt'); applicator=text('tools/Apply-ModernVoiceOverlay.ps1')
check('01 required public package files', all((ROOT/p).is_file() for p in required))
check('02 public version identity', text('VERSION').strip()=='SIGNALFLOW-MINI-V1-RD3-PUBLIC')
check('03 public UI rebranded', 'SignalFlow Mini - Ready' in program and 'ReoFlow - Ready' not in program)
check('04 executable rebranded', 'SignalFlow-Mini.exe' in build and 'SignalFlow-Mini.exe' in installer)
check('05 selectable install path', 'FolderBrowserDialog' in installer and '[string]$InstallPath' in installer)
check('06 no fixed owner drive paths', not re.search(r"['\"](?:[A-Z]):\\", installer))
check('07 F8 global hook preserved', 'VK_F8 = 0x77' in program and 'WH_KEYBOARD_LL' in program)
check('08 microphone capture preserved', 'MemoryStream _pcm' in program and 'waveInOpen' in program)
check('09 PCM 16k mono 16-bit preserved', 'nSamplesPerSec = 16000' in program and 'wBitsPerSample = 16' in program)
check('10 500 ms pre-roll preserved', 'PreRollMilliseconds = 500' in program and 'CopyPreRollTo(_pcm)' in program)
check('11 650 ms post-roll preserved', 'PostRollMilliseconds = 650' in program and 'Task.Delay(PostRollMilliseconds)' in program)
check('12 local whisper preserved', 'whisper-cli.exe' in program and '-l en -nt -np' in program)
check('13 clipboard recovery preserved', 'Clipboard.SetText(text)' in program)
check('14 guarded browser paste preserved', 'SendInput' in program and 'GetForegroundWindow() != _targetWindow' in program)
check('15 classic paste timeout preserved', 'SendMessageTimeout' in program and '2000' in program)
check('16 focus guard preserved', 'CapturePasteTarget' in program and 'focusedNow != _targetControl' in program)
check('17 public mutex identity', 'Local\\SignalFlow-Mini-v1' in program and 'OwnerTest' not in program)
check('18 quick tap guard preserved', 'held.TotalMilliseconds < 220' in program)
check('19 temp WAV lifecycle preserved', 'File.WriteAllBytes(wavPath' in program and 'File.Delete(wavPath)' in program)
check('20 listening overlay state', '_overlay.ShowListening(_targetWindow)' in program)
check('21 processing overlay state', '_overlay.ShowProcessing(_targetWindow)' in program)
check('22 overlay auto hide', '_autoHideTick' in program and 'HideOverlay()' in program)
check('23 pinned model hash', 'c6138d6d58ecc8322097e0f987c32f1be8bb0a18532a3f88f734d1bbf9c41e5d' in installer)
check('24 pinned whisper archive hash', 'b07ea0b1b4115a38e1a7b07debf581f0b77d999925f8acb8f39d322b0ba0a822' in installer)
check('25 atomic stage/rollback retained', '.SignalFlow-Mini-stage-' in installer and '.SignalFlow-Mini-backup-' in installer and 'Move-Item -LiteralPath $backup' in installer)
check('26 Apache 2.0 present', 'Apache License' in text('LICENSE') and 'Version 2.0' in text('LICENSE'))
check('27 ReoSpeak lineage documented', 'ReoSpeak' in text('docs/ORIGIN-AND-LINEAGE.md') and 'ReoFlow' in text('docs/ORIGIN-AND-LINEAGE.md'))
check('28 giveaway language present', 'free, open-source' in readme and 'giveaway' in readme)
check('29 Clarity Core CTA present', 'https://signalproof.com/cccore' in readme)
check('30 RD3 modern oval overlay template', all(marker in overlay for marker in ['CreatePillPath','DrawRoundBar','LineCap.Round','barCount = 11','Listening','Transcribing locally']))
check('31 RD3 build applies sanitized public overlay', "-ProductName 'SignalFlow Mini'" in build and 'SIGNALFLOW-MINI-MODERN-VOICE-OVERLAY-V1-RD3' in build)
check('32 RD3 applicator protects speech path', all(marker in applicator for marker in ['VK_F8 = 0x77','WH_KEYBOARD_LL','MemoryStream _pcm','whisper-cli.exe','Clipboard.SetText(text)','_overlay.ShowListening(_targetWindow)','_overlay.ShowProcessing(_targetWindow)']))
joined='\n'.join(text(p) for p in required if (ROOT/p).suffix.lower() in {'.ps1','.md','.cmd','.json','.txt'})
secrets=re.findall(r'(?i)(api[_-]?key|secret|token)\s*[=:]\s*["\'][^"\']{8,}',joined)
check('33 no embedded secret assignments', not secrets)
check('34 no internal public-control files', all(not (ROOT/p).exists() for p in ['AGENTS.md','SOUL.md','LOCK.json','evidence.json','OWNER-TEST-CHECKLIST.md','verification.txt']))
failed=[n for n,ok in checks if not ok]
print(f'\nRESULT: {len(checks)-len(failed)}/{len(checks)} checks passed')
if failed:
    print('FAILED: '+', '.join(failed)); sys.exit(1)
