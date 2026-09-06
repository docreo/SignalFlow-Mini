# SignalFlow Mini

**SignalFlow Mini** is the small, local push-to-talk speech-to-text member of the Signal Flow family.

Hold **F8**, speak, release **F8**, and SignalFlow Mini transcribes locally and returns the text to the application you were using. A compact bottom-center activity overlay shows when it is listening and when local transcription is running without taking focus from the target field.

## What it does

1. Hold **F8** to begin capture.
2. The non-activating visual overlay appears and indicates that SignalFlow Mini is listening.
3. Release **F8** to finish capture.
4. The overlay changes to **Transcribing locally**.
5. The transcript is placed on the clipboard and, when the original target is still safe, pasted back into that field.
6. If safe automatic paste cannot be proven, the transcript remains on the clipboard instead of being typed into the wrong place.

## Local-first speech path

```text
F8 hold
  ↓
Microphone capture
  ↓
local whisper.cpp + small.en
  ↓
Transcript
  ↓
Clipboard
  ↓
Guarded paste into the originally captured target
```

The current runtime does **not** send speech audio to a cloud speech service.

## Listening visual aid

SignalFlow Mini uses a small bottom-center animated activity overlay. It is intentionally an **activity visualization**, not a calibrated audio-level meter. The overlay is always-on-top, click-through, `NOACTIVATE`, and excluded from the taskbar so it can show listening/transcribing state without stealing the caret.

## Install on Windows

1. Close any running ReoFlow/ReoSpeak legacy build or SignalFlow Mini instance.
2. Clone or download this repository.
3. Run `BUILD-AND-INSTALL.cmd`.
4. Click into a text field.
5. Hold **F8**, speak, and release.

`INSTALL-SIGNALFLOW-MINI.cmd` installs an already-built local candidate when appropriate.

## Preserved behavior from the ReoFlow prototype

SignalFlow Mini is a rebrand/productization of the working **ReoFlow V1 RD2 Overlay Owner Test** prototype supplied by the owner on 2026-09-05. The speech and safe-paste design is intentionally preserved:

- global hold-F8/release workflow
- 500 ms rolling in-memory pre-roll
- 650 ms post-roll
- 16 kHz mono PCM16 microphone capture
- local whisper.cpp `small.en` recognition
- short-lived local temporary WAV deleted in `finally`
- transcript placed on clipboard before paste attempt
- target/focus verification before automatic paste
- guarded Ctrl+V for Chromium/Electron fields
- bounded `WM_PASTE` for classic Edit/RichEdit controls
- shared legacy ReoSpeak/ReoFlow mutex retained for compatibility so two F8 engines do not run together
- atomic installer staging/rollback
- pinned dependency hashes

See `docs/ORIGIN-AND-LINEAGE.md` for the historical rename and the boundary between SignalFlow Mini and the larger Signal Flow system.

## Relationship to Signal Flow

SignalFlow Mini is **not** the full Signal Flow production system. It is the baby brother: the compact push-to-talk voice-input component. The larger Signal Flow architecture inside Signalproof Media Studio expands into recording, voice production, voice assets, performance direction, QA, and additional media workflows.

An experimental next-stage model is being preserved separately in the private Signalproof Build Ledger and is not part of this repository.

## License

SignalFlow Mini source is released under the **Apache License 2.0**. See `LICENSE` and `NOTICE`. Third-party runtime/model components retain their own licenses.

Copyright 2026 Doc Reo / Signalproof.
