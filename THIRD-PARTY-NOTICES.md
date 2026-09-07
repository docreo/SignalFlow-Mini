# Third-Party Notices

SignalFlow Mini does not vendor the speech runtime or speech model in this source repository. The installer downloads pinned artifacts at install time and verifies SHA-256 hashes before use.

- **whisper.cpp**: local speech-recognition runtime distributed by its upstream project under the MIT License.
- **Whisper `small.en` model artifact**: external model artifact downloaded from the pinned upstream location used by the installer. Review the upstream repository and model terms before redistributing the model as part of another package.

SignalFlow Mini's Apache License 2.0 does not replace or override the licenses and terms that apply to third-party components.
