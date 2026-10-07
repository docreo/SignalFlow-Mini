# Testing SignalFlow Mini

## Static package verification

From the repository root:

```powershell
python .\verify\verify_package.py
```

The verifier checks the public package boundary, SignalFlow Mini identity, protected F8/audio/local-Whisper behavior, the V1/RD3 red-and-gold overlay contract, the concurrent whisper.cpp pipe-drain fix, installer integrity controls, licensing, and secret/path hygiene.

## Build verification

On Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
python .\verify\verify_package.py
```

The build always regenerates `src/Program.cs` from the public `src/Program.cs.gz` base, then applies the checked-in public V1/RD3 presentation and transcription patches before compilation.

## Directed redirected-pipe regression

The Windows CI candidate intentionally runs a child process that emits a transcript sentinel on stdout while flooding stderr beyond ordinary pipe capacity. SignalFlow Mini's concurrent stdout/stderr drain must complete without deadlock.

## Windows runtime verification

After installation:

1. Confirm SignalFlow Mini launches from the Desktop shortcut.
2. Click into a normal text field.
3. Hold F8 and confirm the red/gold activity surface appears with **LISTENING** without stealing focus.
4. Speak a short sentence.
5. Release F8 and confirm the same surface changes to **TRANSCRIBING**.
6. Confirm transcription completes and the activity surface disappears.
7. Confirm the transcript returns to the original field when the target remains valid.
8. Repeat while deliberately changing focus before transcription completes. Confirm the transcript remains on the clipboard rather than pasting into the wrong application.
9. Confirm a quick accidental F8 tap does not create an unwanted transcript.
10. Confirm the activity surface never presents `THINKING` or `RESPONDING`.
11. Confirm uninstall removes the selected application directory and Desktop shortcut.

Windows runtime acceptance remains separate from static source and CI validation.
