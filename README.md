# SignalFlow Mini

**SignalFlow Mini** is a free, open-source, local push-to-talk speech-to-text utility for Windows from Signalproof.

Hold **F8**, speak, release **F8**, and SignalFlow Mini transcribes your voice locally and returns the text to the application you were using. A compact visual indicator shows when the app is listening and when transcription is running without taking focus away from the text field.

SignalFlow Mini is a giveaway. There is no purchase required to use the source code in this repository under the Apache License 2.0.

## What it does

1. Click into the text field where you want the words to go.
2. Hold **F8** to begin capture.
3. SignalFlow Mini shows that it is listening.
4. Speak normally.
5. Release **F8**.
6. The app transcribes locally with whisper.cpp and the Whisper `small.en` model.
7. The transcript is placed on the clipboard first.
8. When the original target can still be verified safely, SignalFlow Mini pastes the text back into that field.
9. If safe automatic paste cannot be confirmed, the text stays on the clipboard instead of being typed into the wrong place.

## Local-first speech path

```text
F8 hold
  |
  v
Microphone capture
  |
  v
Local whisper.cpp + small.en
  |
  v
Transcript
  |
  v
Clipboard
  |
  v
Guarded paste into the original target
```

Speech audio is processed locally by the current runtime. SignalFlow Mini does not send captured speech to a cloud speech API.

## Install on Windows

1. Clone or download this repository.
2. Run `BUILD-AND-INSTALL.cmd`.
3. Choose the folder where you want SignalFlow Mini installed.
4. Allow the installer to download the pinned whisper.cpp runtime and Whisper `small.en` model.
5. Click into any normal text field.
6. Hold **F8**, speak, and release.

The installer verifies the SHA-256 hashes of the downloaded runtime and model before using them. It also uses a staged install and rollback path so an existing recognized SignalFlow Mini installation can be restored if replacement fails.

A Desktop shortcut is created for the selected installation.

### Scripted install

For a non-interactive location, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -InstallPath "D:\Apps\SignalFlow-Mini"
```

## Why SignalFlow Mini exists

The idea started as a small internal voice-input experiment called **ReoSpeak**. It evolved into **ReoFlow**, where the goal became more specific: hold a key, speak, see a clear listening state, transcribe locally, and return text without disrupting the application you are working in.

That working idea became **SignalFlow Mini**, the public, stripped-down version of the voice-input capability. The larger Signal Flow system being developed inside the Signalproof media stack goes much further, but this repository intentionally stays focused on one job: fast local talk-to-type.

Read more in [`docs/ORIGIN-AND-LINEAGE.md`](docs/ORIGIN-AND-LINEAGE.md).

## What is next

SignalFlow Mini will receive another refinement update soon. The next public update is intended to improve polish, usability, and the everyday push-to-talk experience while keeping the product small and local-first.

See [`ROADMAP.md`](ROADMAP.md) for the public direction.

## About Signalproof

Signalproof builds human-controlled AI systems and practical tools designed around clarity, proof, ownership, and human authority.

SignalFlow Mini is one of our free public tools.

If you want help identifying where AI fits into your work, what should stay human-controlled, and what to build next, book a **Clarity Core Session**:

**https://signalproof.com/cccore**

Learn more about Signalproof at **https://signalproof.com**.

## License

SignalFlow Mini source code is released under the **Apache License 2.0**. See [`LICENSE`](LICENSE) and [`NOTICE`](NOTICE).

Third-party components downloaded by the installer keep their own upstream licenses and terms. See [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md).

Copyright 2026 Doc Reo / Signalproof.
