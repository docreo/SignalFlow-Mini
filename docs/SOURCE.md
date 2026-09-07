# Source Layout

The SignalFlow Mini application source is stored in `src/Program.cs.gz` in this repository. The build script expands it to `src/Program.cs` before compilation.

This packaging keeps the repository buildable through the current Git transport while preserving the complete C# source. To inspect it manually on Windows PowerShell, run the repository build script or expand the gzip file with any standard gzip-compatible tool.

During build, the script also normalizes one historical mutual-exclusion identifier from the earlier ReoSpeak/ReoFlow prototype into the public SignalFlow Mini identity. That compatibility string is not a credential or secret and is not used as public branding.

The application itself remains Apache 2.0 licensed. Third-party runtime and model components retain their own upstream licenses and terms.
