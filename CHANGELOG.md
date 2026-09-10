# Changelog

## V1 / RD3 - modern voice overlay candidate

- Replaced the old rectangular listening/transcribing presentation with a modern oval/pill activity surface at build time.
- Added smooth rounded waveform bars with distinct listening and local-transcription motion.
- Listening uses the blue SignalFlow treatment; transcription uses a graphite/blue-grey treatment.
- Preserved the visible state words: Listening, Transcribing locally, Pasted, Copied to clipboard, and No speech detected.
- Preserved F8 push-to-talk, microphone capture, local whisper.cpp transcription, clipboard recovery, guarded paste, focus protection, and the existing timing path.
- Kept this public candidate sanitized; no owner-specific ReoFlow identity or private control material is introduced.
- The V1/RD2 public source is preserved on the rollback branch `rollback/signalflow-mini-v1-rd2-public-2026-09-10`.

## Public cleanup release

- Prepared SignalFlow Mini as a free Apache 2.0 giveaway.
- Removed internal owner-test and Build Ledger material from the public package.
- Removed owner-machine drive assumptions from installation logic.
- Added selectable install location support.
- Added persistent install-location discovery for launch and uninstall.
- Preserved local whisper.cpp transcription, F8 push-to-talk, listening feedback, clipboard recovery, and guarded paste behavior.
- Added public origin, roadmap, security, contribution, source, and testing documentation.
- Added Signalproof information and the Clarity Core Session link.
