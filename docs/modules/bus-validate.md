---
title: bus-validate — validate workspace datasets and invariants
description: bus validate checks all workspace datasets against their schemas and enforces cross-table invariants (e.g.
---

## `bus-validate` — validate workspace datasets and invariants

### Synopsis

`bus validate [--format <text|tsv>] [-C <dir>] [global flags]`  
`bus validate parity --source <file> [--max-abs-delta <n>] [--max-count-delta <n>] [--dry-run] [--bucket-thresholds <file>] [-C <dir>] [-o <file>] [global flags]`  
`bus validate journal-gap --source <file> [--max-abs-delta <n>] [--dry-run] [--bucket-thresholds <file>] [-C <dir>] [-o <file>] [global flags]`  
`bus validate evidence-coverage [--vendor <normalized-key>] [--source <bank|invoice|journal|qred_statement|settlement>] [--group-by <vendor|month|document-type|source>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus validate` checks workspace datasets against schemas and cross-table invariants (for example balanced debits/credits, valid references, and period integrity).
It does not modify data.
The validator reads datasets through the shared storage-aware data layer, so a fresh workspace with empty `PCSV-1` tables created by `bus journal init`, `bus period init`, or `bus invoices init` validates the same way as a plain CSV workspace.

Use it before period close and filing.
Diagnostics go to stderr; stdout is empty on success.

The module also provides first-class parity and journal-gap checks through `bus validate parity` and `bus validate journal-gap`, plus evidence coverage auditing through `bus validate evidence-coverage`.

### Commands

Run `bus validate` from the workspace (or use `-C <dir>`) for workspace-wide validation. Subcommands `parity` and `journal-gap` provide first-class migration checks; see [Parity and gap checks (first-class)](#parity-and-gap-checks-first-class) below. Subcommand `evidence-coverage` provides evidence link coverage totals plus search-oriented missing-evidence output; see [Evidence coverage](#evidence-coverage) below.

### Options

`--format text` (default) or `--format tsv` controls diagnostics format. TSV columns are `dataset`, `record_id`, `field`, `rule`, `message`. Global flags are defined in [Standard global flags](../cli/global-flags). For `bus validate`, stdout is empty on success and `--output` has no effect (no result set). For help, run `bus validate --help`.

### Parity and gap checks (first-class)

`bus validate parity --source <file>` runs deterministic source-import parity checks.
`bus validate journal-gap --source <file>` runs deterministic journal gap checks.

Both commands consume a deterministic source-summary artifact with stable columns.
That source artifact can be produced by [bus-reports](./bus-reports) or by scripts.

Threshold flags (for example `--max-abs-delta` and `--max-count-delta`) control pass/fail behavior.
When a row exceeds threshold, the command exits non-zero.
`--dry-run` prints planned scope and thresholds to stderr without result output.

**Per-bucket thresholds (optional).** `--bucket-thresholds <file>` defines bucket-specific thresholds (for example operational, financing, internal transfer).
When provided, gap checks are evaluated per bucket and fail when any configured threshold is exceeded.
Without this file, only aggregate thresholds apply.

For extended capability notes, see [Suggested capabilities](../modules/bus-validate#suggested-capabilities-out-of-current-scope).

Script-based diagnostics (e.g. `exports/2024/022-erp-parity-2024.sh`) remain available as an alternative.

### Evidence coverage

`bus validate evidence-coverage` audits attachments coverage for journal vouchers, bank transactions, and invoices using `attachment-links.csv`. The command emits a deterministic TSV result set with columns `row_kind`, `scope`, `source_id`, `voucher_id`, `bank_txn_id`, `invoice_id`, `total`, `linked`, `missing`, `group_by`, `group_key`, `date`, `amount`, `currency`, `counterparty_name`, `description`, `reference`, `expected_document_type`, `search_hint`, `vendor_key`, and `source_channel`. Summary rows provide totals per scope, optional `group` rows summarize the requested grouping, and `missing` rows provide search-ready evidence leads with exact dates, amounts, normalized vendor keys, and normalized source-channel hints. It exits `0` when all scopes are fully covered and `1` when any missing evidence exists.

Use `--vendor <normalized-key>` to narrow missing rows to one recurring vendor, `--source <...>` to focus on one evidence source channel, and `--group-by <...>` to add deterministic group rows for vendor, month, document type, or source. Direct bank-card purchases and statement-derived purchases are normalized into the same search-oriented output surface.

### Files

Reads all workspace datasets and schemas. Does not write.

### Examples

```bash
bus validate --format tsv
bus validate parity --source ./imports/legacy/parity-2026-01.csv --max-abs-delta 0.01
bus validate journal-gap --source ./imports/legacy/journal-gap-2026q1.csv --max-abs-delta 0.01 --bucket-thresholds ./config/gap-thresholds.csv
bus validate parity --source ./imports/legacy/parity-2026-01.csv --dry-run
bus validate evidence-coverage
bus validate evidence-coverage --vendor vendor-oy --source bank --group-by vendor
bus validate evidence-coverage --source qred_statement --group-by source
```

### Exit status

`0` when the workspace is valid. Non-zero on invalid usage or when schema or invariant violations are found. `bus validate evidence-coverage` exits `0` only when all scopes are fully covered; missing evidence exits `1`.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus validate --format tsv
validate --format tsv

# same as: bus validate parity --source ./imports/legacy/parity-2026-01.csv --max-abs-delta 0.01
validate parity --source ./imports/legacy/parity-2026-01.csv --max-abs-delta 0.01

# same as: bus validate journal-gap --source ./imports/legacy/journal-gap-2026q1.csv --max-abs-delta 0.01 --bucket-thresholds ./config/gap-thresholds.csv
validate journal-gap --source ./imports/legacy/journal-gap-2026q1.csv --max-abs-delta 0.01 --bucket-thresholds ./config/gap-thresholds.csv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Bank transactions](../master-data/bank-transactions/index)
- [Module reference: bus-validate](../modules/bus-validate)
- [Architecture: Shared validation layer](../architecture/shared-validation-layer)
- [CLI: Validation and safety checks](../cli/validation-and-safety-checks)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)
