# Changelog

## V1/RD3 public candidate

- Replaced the prior activity waveform with the compact red-and-gold SignalFlow Mini moving swirl.
- Limited the visible activity surface to `LISTENING` and `TRANSCRIBING`.
- Preserved F8 hold-to-talk capture, local whisper.cpp recognition, clipboard-first recovery, guarded paste, and target-focus protections.
- Corrected a redirected-process deadlock risk by draining whisper.cpp stdout and stderr concurrently.
- Added a directed pipe-pressure regression for the transcription runner.
- Kept the public product boundary intact: SignalFlow Mini remains a small Windows talk-to-type utility and does not absorb the larger Signal Flow system.


## Public cleanup release

- Prepared SignalFlow Mini as a free Apache 2.0 giveaway.
- Removed internal owner-test and Build Ledger material from the public package.
- Removed owner-machine drive assumptions from installation logic.
- Added selectable install location support.
- Added persistent install-location discovery for launch and uninstall.
- Preserved local whisper.cpp transcription, F8 push-to-talk, listening feedback, clipboard recovery, and guarded paste behavior.
- Added public origin, roadmap, security, contribution, source, and testing documentation.
- Added Signalproof information and the Clarity Core Session link.
