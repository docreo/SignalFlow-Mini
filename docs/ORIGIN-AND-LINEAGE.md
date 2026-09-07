# Origin and Lineage

## ReoSpeak

SignalFlow Mini began as a small internal speech-to-text experiment called **ReoSpeak**. The original goal was simple: make voice input fast enough to use while working instead of treating transcription as a separate task.

That early work established the core direction:

- local speech recognition
- a keyboard-driven push-to-talk interaction
- clipboard recovery before automatic paste
- attention to focus so text is not inserted into the wrong place

## ReoFlow

ReoSpeak evolved into **ReoFlow**. ReoFlow tightened the interaction around a hold-to-talk workflow and added a visible listening and processing state so the user could tell when the app was capturing speech and when local transcription was running.

The working behavior that mattered most was preserved:

- hold F8 to capture
- visible listening state
- release F8 to finish capture
- local transcription
- guarded return of text to the original application
- clipboard fallback when automatic paste cannot be proven safe

## SignalFlow Mini

The public giveaway is named **SignalFlow Mini**.

SignalFlow Mini is the small public member of the Signal Flow family. It keeps the narrow talk-to-type job and removes the internal build context that is not needed by public users.

The product is intentionally smaller than the larger Signal Flow system being developed for the Signalproof media stack. The larger system expands into recording, voice production, voice assets, model routing, performance direction, QA, and other production workflows. Those capabilities are outside the scope of this repository.

## Public release principle

SignalFlow Mini is released as a free open-source utility under Apache License 2.0. The repository contains the application source, build and install scripts, public documentation, licensing, third-party notices, and verification tooling needed for this product.

Historical names are documented here only to explain how the product evolved.
