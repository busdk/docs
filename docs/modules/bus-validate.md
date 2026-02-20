---
title: bus-validate — validate workspace datasets and invariants
description: bus validate checks all workspace datasets against their schemas and enforces cross-table invariants (e.g.
---

## `bus-validate` — validate workspace datasets and invariants

### Synopsis

`bus validate [--format <text|tsv>] [-C <dir>] [global flags]`  
`bus validate parity --source <file> [--max-abs-delta <n>] [--max-count-delta <n>] [--dry-run] [--bucket-thresholds <file>] [-C <dir>] [-o <file>] [global flags]`  
`bus validate journal-gap --source <file> [--max-abs-delta <n>] [--dry-run] [--bucket-thresholds <file>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus validate` checks workspace datasets against schemas and cross-table invariants (for example balanced debits/credits, valid references, and period integrity).
It does not modify data.

Use it before period close and filing.
Diagnostics go to stderr; stdout is empty on success.

The module also provides first-class parity and journal-gap checks through `bus validate parity` and `bus validate journal-gap`.

### Commands

Run `bus validate` from the workspace (or use `-C <dir>`) for workspace-wide validation. Subcommands `parity` and `journal-gap` provide first-class migration checks; see [Parity and gap checks (first-class)](#parity-and-gap-checks-first-class) below.

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

For extended capability notes, see [Suggested capabilities](../sdd/bus-validate#suggested-capabilities-out-of-current-scope).

Script-based diagnostics (e.g. `exports/2024/022-erp-parity-2024.sh`) remain available as an alternative.

### Files

Reads all workspace datasets and schemas. Does not write.

### Examples

```bash
bus validate --format tsv
bus validate parity --source ./imports/legacy/parity-2026-01.csv --max-abs-delta 0.01
bus validate journal-gap --source ./imports/legacy/journal-gap-2026q1.csv --max-abs-delta 0.01 --bucket-thresholds ./config/gap-thresholds.csv
bus validate parity --source ./imports/legacy/parity-2026-01.csv --dry-run
```

### Exit status

`0` when the workspace is valid. Non-zero on invalid usage or when schema or invariant violations are found.


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


### Development state

**Value promise:** Validate workspace datasets and invariants so the accounting workflow can run a single check before period close and filing and get deterministic diagnostics.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** high — Run and schema/invariant checks are test-verified; user can complete pre-close validation and get pass/fail and diagnostics. Stdout is empty on success; `--format text` (default) and `--format tsv` control diagnostics to stderr; `--output` is a no-op for `bus validate` (no result set). First-class `parity` and `journal-gap` subcommands are implemented with thresholds and CI exit behavior.

**Use case readiness:** Accounting workflow: high — run, schema/invariant checks, empty stdout, format, and output no-op are in place; parity and journal-gap available. Finnish bookkeeping and tax-audit compliance: high — workspace validation and migration checks available; audit and closed-period would strengthen. Finnish company reorganisation: high — same as above.

**Current:** Workspace validation, parity, and journal-gap flows are test-verified, including threshold and dry-run behavior.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-validate](../sdd/bus-validate).

**Planned next:** Table Schema min/max and audit/closed-period checks for [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) and [Finnish company reorganisation](../compliance/fi-company-reorganisation-evidence-pack). Class-aware gap reporting with per-bucket thresholds (see [Suggested capabilities](../sdd/bus-validate#suggested-capabilities-out-of-current-scope) in the module SDD) as a possible extension.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Run before [bus-period](./bus-period) close and [bus-filing](./bus-filing); workflows assume validation is available.

See [Development status](../implementation/development-status).

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
- [Module SDD: bus-validate](../sdd/bus-validate)
- [Architecture: Shared validation layer](../architecture/shared-validation-layer)
- [CLI: Validation and safety checks](../cli/validation-and-safety-checks)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
- [Finnish closing adjustments and evidence controls](../compliance/fi-closing-adjustments-and-evidence-controls)
