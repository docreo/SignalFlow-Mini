# Origin and Lineage

## ReoFlow → SignalFlow Mini

The owner supplied the protected source package:

`ReoFlow-V1-RD2-Overlay-Owner-Test-2026-09-03.zip`

SHA-256: `53dfbf4d0acaa29851754540735e9a4334e573650a758619ed977cbc359f8377`

SignalFlow Mini V1 RD2 is a product rebrand and public-source packaging of that small speech-to-text module. The intent is not to redesign the speech engine. The defining interaction remains: **hold F8 → visible listening state → release → local transcription → guarded text return**.

The historical ReoFlow/ReoSpeak names remain only where provenance or backward-compatibility behavior requires them, including the shared legacy mutex and old model-search paths.

## How this led into the larger Signal Flow build

The small voice-input idea became one capability in a much larger Signal Flow plan for Signalproof Media Studio. The larger system adds recording, voice design, voice assets, model routing, performance direction, dubbing/ADR, QA, project provenance, and human approval.

**SignalFlow Mini intentionally does not include those larger production capabilities.** It remains the small global voice-input utility and can later be consumed by the larger system as a shared component.

## Experimental next stage

A separate experimental package created during the 2026-09-05 design session is preserved privately in the Signalproof Build Ledger as a future workstream. It is not the public SignalFlow Mini baseline and must not be mixed into this repository until separately designed, tested, and accepted.
