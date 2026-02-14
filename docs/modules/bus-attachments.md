---
title: bus attachments — register and list evidence files
description: CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths.
---

## bus-attachments

### Name

`bus attachments` — register and list evidence files.

### Synopsis

`bus attachments init [-C <dir>] [global flags]`  
`bus attachments add <file> [--desc <text>] [-C <dir>] [global flags]`  
`bus attachments list [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus attachments` registers evidence files and stores attachment metadata in `attachments.csv` so other modules can link to evidence without embedding file paths directly in domain datasets.

### Commands

- `init` creates the baseline attachments metadata dataset and schema. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` registers a file and writes attachment metadata.
- `list` prints registered attachments in deterministic order.

### Options

`add` accepts a positional `<file>` plus `--desc <text>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus attachments --help`.

### Files

`attachments.csv` and its beside-the-table schema at the repository root. Evidence files are stored under `./attachments/yyyy/mm/yyyymmdd-filename...` (for example `attachments/2026/01/20260115-INV-1001.pdf`), where `yyyy` is the four-digit year, `mm` is the two-digit month, and the filename is prefixed with an eight-digit date. This is the only layout that places files in a subdirectory; the metadata (dataset and schema) stays at the workspace root.

### Exit status

`0` on success. Non-zero on errors, including missing files or schema violations.

### Development state

Init, add, and list work today; e2e tests cover attachments workflows. [bus-bank](./bus-bank) will link imports to attachment metadata; invoice PDFs and evidence are registered here; filing bundles may include attachment metadata. Planned next: use workspace-relative paths in CSV I/O diagnostics (e.g. report `attachments.csv` instead of absolute paths in error messages). See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-invoices">bus-invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [Module SDD: bus-attachments](../sdd/bus-attachments)
- [Attachment storage: Invoice PDF storage](../layout/invoice-pdf-storage)

