# Error handling, dry-run, and diagnostics

The CLI is expected to fail gracefully and provide clear error messages. If the repository is not initialized as a Git repository, the tool should detect this (for example, by checking for a `.git` directory) and instruct the user to run an initialization command or to operate within the correct directory. BusDK does not execute any Git commands or commit changes. Merge conflicts caused by concurrent edits or manual file modifications must be detected and surfaced, with guidance for resolution. A `--dry-run` flag should be available to preview file changes without committing. Optional logging should provide visibility into validation steps and planned file changes, supporting trust and diagnosability.

`bus-loans` is intentionally minimal and omits Git-related helpers and the `--dry-run` preview; it writes data files only, leaving version control and previews to external tooling.

