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

`attachments.csv` and its beside-the-table schema at the repository root. Evidence files are stored under `./attachments/yyyy/mm/yyyymmdd-filename...` (for example `attachments/2026/01/20260115-INV-1001.pdf`), where `yyyy` is the four-digit year, `mm` is the two-digit month, and the filename is prefixed with an eight-digit date. This is the only layout that places files in a subdirectory; the metadata (dataset and schema) stays at the workspace root. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on errors, including missing files or schema violations.

### Development state

**Value promise:** Register evidence files and maintain attachment metadata so other modules can reference stable attachment identifiers and the accounting workflow treats evidence as first-class.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 60% — Register-attachments step completable; init, add, and list verified by tests; idempotent init and workspace-relative diagnostics verified.

**Use case readiness:** Accounting workflow: 60% — Register evidence and list; init/add/list and diagnostics verified. Finnish company reorganisation: 60% — Link source documents for audit; traceability verified.

**Current:** Verified capabilities: help/version, global flags (color, format, quiet, `--`, chdir, output), init (CSV and schema), idempotent init, add with file and `--desc`, list (deterministic TSV, evidence under `attachments/yyyy/mm/`), quiet with `--output` (no file written), and workspace-relative diagnostics (errors cite `attachments.csv`, no absolute path). Proved by `tests/e2e_bus_attachments.sh` and `cmd/bus-attachments/run_test.go`; `internal/attachments/validate_test.go` and `internal/attachments/csvio_test.go` cover relpath/pattern and CSV basename; `internal/cli/flags_test.go` covers flag parsing.

**Planned next:** Go library path accessors for cross-module read-only access (NFR-ATT-002; advances accounting and evidence-pack when consumers link). Optional `--dry-run` for init and add.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-bank](./bus-bank), [bus-invoices](./bus-invoices), [bus-filing](./bus-filing) reference attachment metadata.

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

