# Testing SignalFlow Mini

## Static package verification

From the repository root:

```powershell
python .\verify\verify_package.py
```

## Windows runtime verification

After installation:

1. Confirm SignalFlow Mini launches from the Desktop shortcut.
2. Click into a normal text field.
3. Hold F8 and confirm the listening indicator appears without stealing focus.
4. Speak a short sentence.
5. Release F8 and confirm local transcription starts.
6. Confirm the transcript returns to the original field when the target remains valid.
7. Repeat while deliberately changing focus before transcription completes. Confirm the transcript remains on the clipboard rather than pasting into the wrong application.
8. Confirm a quick accidental F8 tap does not create an unwanted transcript.
9. Confirm uninstall removes the selected application directory and Desktop shortcut.

Windows runtime acceptance remains separate from static source validation.
