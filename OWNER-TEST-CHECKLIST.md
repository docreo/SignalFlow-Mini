# SignalFlow Mini V1 RD2 Owner-Test Checklist

Candidate: `SIGNALFLOW-MINI-V1-RD2-OVERLAY-2026-09-03`

## Startup
- [ ] Build/install completes on Windows.
- [ ] SignalFlow Mini starts without opening a normal foreground control window.
- [ ] SignalFlow Mini remains visible in the Windows taskbar.
- [ ] Starting it does not steal the caret.

## Push to talk
- [ ] Click a text field.
- [ ] Hold F8.
- [ ] Listening overlay appears on the correct screen.
- [ ] Overlay does not steal focus or accept clicks.
- [ ] Speak and release F8.
- [ ] Overlay changes to `Transcribing locally`.
- [ ] Text is returned to the original field when safe.
- [ ] If target/focus changes, automatic paste is refused and transcript remains on clipboard.
- [ ] No duplicate paste occurs.

## Outcome
- [ ] PASS — designate this exact SignalFlow Mini candidate as owner-accepted.
- [ ] FAIL — preserve evidence and correct forward under a new build identity.
