---
title: bus attachments — register and list evidence files
description: "CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths."
---

## `bus-attachments` — register and list evidence files

### Synopsis

`bus attachments init [-C <dir>] [global flags]`  
`bus attachments add <file> [--desc <text>] [-C <dir>] [global flags]`  
`bus attachments link <attachment_id> [--if-missing] [--kind <kind> --id <resource_id> | --bank-row <id> | --voucher <id> | --invoice <id>] [-C <dir>] [global flags]`  
`bus attachments link [--path <relpath>|--desc-exact <text>|--source-hash <sha256>] [--if-missing] [--kind <kind> --id <resource_id> | --bank-row <id> | --voucher <id> | --invoice <id>] [-C <dir>] [global flags]`  
`bus attachments list [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus attachments` registers evidence files and stores metadata in `attachments.csv`.
Other modules then link to attachments without embedding file paths directly in domain datasets.

### Commands

`init` creates baseline attachment metadata and link datasets and schemas. If they already exist in full, `init` warns and exits 0 without changes. If they exist only partially, `init` fails and does not modify files.

`add` registers a file and writes attachment metadata. `link` adds deterministic links from attachments to domain resources such as bank rows, vouchers, invoices, or custom kind/id targets. Repeated identical links are idempotent.

For replay flows, `link` can select attachments without UUID lookup by using `--path`, `--desc-exact`, or `--source-hash`. Resolution is deterministic and fails if there are zero or multiple matches.

`list` prints registered attachments in deterministic order and supports filters, reverse-link graph output, and strict audit flags.

### Options

`add` accepts positional `<file>` and optional `--desc <text>`.

`link` accepts an attachment selector (id or selector flags) and a target (`--bank-row`, `--voucher`, `--invoice`, or `--kind` + `--id`).
Use `--if-missing` for idempotent replay runs.

`list` supports `--by-bank-row`, `--by-voucher`, `--by-invoice`, `--date-from`, `--date-to`, `--unlinked-only`, `--graph`, `--fail-if-unlinked`, and repeatable `--fail-if-missing-kind <kind>`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus attachments --help`.

### Files

`attachments.csv` and `attachment-links.csv` with beside-the-table schemas at the repository root. Evidence files are stored under `./attachments/yyyy/mm/yyyymmdd-filename...` (for example `attachments/2026/01/20260115-INV-1001.pdf`), where `yyyy` is the four-digit year, `mm` is the two-digit month, and the filename is prefixed with an eight-digit date. This is the only layout that places files in a subdirectory; the datasets and schemas stay at the workspace root. Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus attachments init
bus attachments add ./evidence/INV-1001.pdf --desc "Sales invoice 1001 PDF"
bus attachments link ATT-000123 --invoice INV-1001
bus attachments link --path attachments/2026/01/20260115-INV-1001.pdf --bank-row bank_row:27201 --if-missing
bus attachments list --by-voucher VCH-1 --graph --fail-if-unlinked
bus attachments list --unlinked-only --format tsv --output ./out/unlinked-attachments.tsv
```

### Exit status

`0` on success. Non-zero on errors, including missing files or schema violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus attachments add ./evidence/BANK-2026-01.csv --desc "January bank statement"
attachments add ./evidence/BANK-2026-01.csv --desc "January bank statement"

# same as: bus attachments link --source-hash 9f0d2c... --voucher VCH-2026-003 --if-missing
attachments link --source-hash 9f0d2c... --voucher VCH-2026-003 --if-missing

# same as: bus attachments list --by-invoice INV-1001 --graph
attachments list --by-invoice INV-1001 --graph
```


### Development state

**Value promise:** Register evidence files and maintain attachment metadata so other modules can reference stable attachment identifiers and the accounting workflow treats evidence as first-class.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 85% — Register-attachments and attachment-link graph workflows are completable; init/add/link/list filters, reverse-link graph, strict audit flags, dry-run, and path accessors are verified by e2e and unit tests.

**Use case readiness:** Accounting workflow: 85% — Register evidence, link to bank/voucher/invoice resources, filter by linkage, and enforce audit gates. Finnish company reorganisation: 85% — Link source documents and verify linkage coverage with deterministic audit flags.

**Current:** Init/add/link/list flows, filters, audit flags, dry-run behavior, and global-flag handling are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-attachments](../sdd/bus-attachments).

**Planned next:** None in PLAN.md.

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
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)
