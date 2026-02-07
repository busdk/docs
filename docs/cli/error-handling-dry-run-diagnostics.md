## Error handling, dry-run, and diagnostics

The CLI is expected to fail gracefully and provide clear error messages. BusDK does not require a Git repository to run and does not execute any Git commands or commit changes. When users choose to track the workspace datasets in Git, merge conflicts caused by concurrent edits or manual file modifications must be detected and surfaced, with guidance for resolution. A `--dry-run` flag should be available to preview file changes without committing. Optional logging should provide visibility into validation steps and planned file changes, supporting trust and diagnosability.

BusDK’s CLI contract follows Unix-style conventions to keep behavior script-friendly. Command results are written to standard output, and diagnostics are written to standard error. When help text, warnings, or other human-facing diagnostics use styled terminal output, that styling applies only to standard error and only when standard error is a terminal. Structured outputs intended for downstream tooling must not include terminal control sequences.

Exit codes are part of the public contract. A successful command exits with status code 0. Invalid usage (unknown command, missing required arguments in non-interactive use, invalid flag values) exits with status code 2 and prints a concise usage error to standard error. Failures caused by repository contents, filesystem I/O, schema or invariant violations, or unsafe operations exit with a non-zero status code and include diagnostics sufficient to identify the dataset and identifiers involved.

Diagnostics must be deterministic and citeable. Error messages should name the dataset (table) and field involved and should point to stable identifiers (for example primary keys) rather than relying on unstable row numbers. When file paths are included, they should be shown relative to the workspace root so that diagnostics remain stable across machines.

For Finnish compliance, missing audit-trail references or retention-critical metadata MUST be treated as hard errors with diagnostics that point to the missing identifiers and datasets. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

`bus-loans` is intentionally minimal and omits Git-related helpers and the `--dry-run` preview; it writes data files only, leaving version control and previews to external tooling.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./minimum-command-surface">Minimum required command surface (end-to-end workflow)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./interactive-and-scripting-parity">Interactive use and scripting parity</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
