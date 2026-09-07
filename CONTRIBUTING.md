# Contributing

SignalFlow Mini is a focused public utility. Contributions are welcome when they improve the push-to-talk speech-to-text experience without expanding the repository into the larger Signal Flow production system.

Before proposing a change:

1. Keep captured speech local unless a future feature is explicitly opt-in and clearly documented.
2. Preserve clipboard-first recovery and safe target verification.
3. Do not add secrets, credentials, personal paths, or machine-specific assumptions.
4. Keep third-party licenses and notices accurate.
5. Run the public verification script in `verify/verify_package.py`.
6. Test Windows installation, launch, F8 capture, transcription, paste behavior, and uninstall when your change touches runtime or packaging.

By contributing, you agree that your contribution may be distributed under the repository's Apache License 2.0.
