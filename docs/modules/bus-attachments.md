---
title: bus attachments — register and list evidence files
description: "CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths."
---

## `bus-attachments` — register and list evidence files

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

**Value:** Register evidence files and maintain attachment metadata so bank imports, invoices, and filing can reference stable attachment identifiers and the [accounting workflow](../workflow/accounting-workflow-overview) treats evidence as first-class.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview).

**Completeness:** 60% (Stable for one use case) — init, add, and list verified by e2e; idempotent init and evidence file layout test-backed.

**Use case readiness:** Accounting workflow: 60% — init, add, list verified; workspace-relative paths in diagnostics would improve UX.

**Current:** E2e script `tests/e2e_bus_attachments.sh` proves exact help/version, global flags, init creating attachments.csv and schema, idempotent init warning, add with file and --desc, list with deterministic TSV. Unit tests in `cmd/bus-attachments/run_test.go` and `internal/attachments/validate_test.go` cover run and validate.

**Planned next:** Workspace-relative paths in diagnostics.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-bank](./bus-bank) links imports to attachment metadata; [bus-invoices](./bus-invoices) and [bus-filing](./bus-filing) use attachment metadata.

See [Development status](../implementation/development-status).

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

