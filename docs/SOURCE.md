# Source Layout

The SignalFlow Mini application base source is stored in `src/Program.cs.gz`. The Windows build expands it to the generated `src/Program.cs`, applies the checked-in public V1/RD3 patches from `tools/`, and compiles the resulting exact source.

The V1/RD3 public patch set is intentionally narrow:

- `tools/Apply-SignalFlowMiniOverlay.ps1` replaces only the activity presentation with the red-and-gold SignalFlow Mini `LISTENING` / `TRANSCRIBING` surface.
- `tools/Apply-WhisperPipeDrainFix.ps1` changes only the redirected whisper.cpp stdout/stderr drain so both streams are consumed concurrently.

F8 capture, microphone recording, local whisper.cpp invocation, transcript normalization, clipboard-first recovery, guarded paste, target verification, and the rest of the public application behavior remain in the public base source.

`src/Program.cs` is generated during build and remains excluded from Git. The public verification script checks both the immutable base behavior and the checked-in patch contracts; after a build it also checks the exact generated source.

ReoSpeak and ReoFlow remain only in the public origin-and-lineage documentation to explain how SignalFlow Mini evolved. They are not product identities in the V1/RD3 public runtime.

SignalFlow Mini source is released under Apache License 2.0. Third-party runtime and model components retain their own upstream licenses and terms.
