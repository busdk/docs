# Error handling, dry-run, and diagnostics

The CLI is expected to fail gracefully and provide clear error messages. If Git is not available or the repository is not initialized, the tool should detect this and instruct the user to run an initialization command or to operate within the correct directory. Merge conflicts caused by concurrent edits or manual file modifications must be detected and surfaced, with guidance for resolution. A `--dry-run` flag should be available to preview changes without committing. Optional logging should provide visibility into validation steps and Git commands executed, supporting trust and diagnosability.

