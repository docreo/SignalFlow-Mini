# Security

SignalFlow Mini handles microphone input and can return text to other applications, so input capture, focus handling, and automatic paste behavior are security-sensitive.

Please report security issues privately to the project owner rather than publishing exploit details in a public issue before a fix is available.

## Security principles

- Speech recognition is local in the current runtime.
- The transcript is placed on the clipboard before automatic paste is attempted.
- Automatic paste is refused when the original target cannot be verified safely.
- Runtime and model downloads are pinned and SHA-256 verified.
- Public source must not contain credentials, secrets, personal machine paths, or private Build Ledger data.

For ordinary bugs and feature requests, use the GitHub issue tracker.
