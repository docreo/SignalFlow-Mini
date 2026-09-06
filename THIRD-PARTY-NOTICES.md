# Third-Party Notices

SignalFlow Mini does not vendor the speech model or whisper.cpp runtime in this source repository. The installer downloads pinned artifacts at install time and verifies SHA-256 hashes before use.

- **whisper.cpp**: external local speech-recognition runtime, MIT-licensed upstream project.
- **Whisper `small.en` model artifact**: external speech-recognition model used by the local runtime.

The installer records exact URLs and SHA-256 hashes. Review upstream licenses before redistributing third-party binaries or model weights as part of another package.
