# Source Layout

The SignalFlow Mini application source is stored in `src/Program.cs.gz` in this repository. The build script expands it to `src/Program.cs` before compilation.

This packaging keeps the repository buildable through the current Git transport while preserving the complete C# source. To inspect it manually, expand the gzip file with any standard gzip-compatible tool or run the repository build script on Windows.

The public source archive already uses the SignalFlow Mini product identity. ReoSpeak and ReoFlow are retained only in the public origin-and-lineage documentation to explain how the project evolved.

SignalFlow Mini source is released under Apache License 2.0. Third-party runtime and model components retain their own upstream licenses and terms.
