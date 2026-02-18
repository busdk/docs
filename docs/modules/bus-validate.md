---
title: bus-validate — validate workspace datasets and invariants
description: bus validate checks all workspace datasets against their schemas and enforces cross-table invariants (e.g.
---

## `bus-validate` — validate workspace datasets and invariants

### Synopsis

`bus validate [--format <text|tsv>] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus validate` checks all workspace datasets against their schemas and enforces cross-table invariants (e.g. balanced debits/credits, valid references, period integrity). It does not modify data. Use before period close and filing. Diagnostics go to stderr; stdout is empty on success.

The module provides first-class parity and journal-gap subcommands (`bus validate parity`, `bus validate journal-gap`) for source-import parity and journal-gap checks. Script-based fallbacks (e.g. `exports/2024/022-erp-parity-2024.sh`) remain optional.

### Commands

Run `bus validate` from the workspace (or use `-C <dir>`) for workspace-wide validation. Subcommands `parity` and `journal-gap` provide first-class migration checks; see [Parity and gap checks (first-class)](#parity-and-gap-checks-first-class) below.

### Options

`--format text` (default) or `--format tsv` controls diagnostics format. TSV columns are `dataset`, `record_id`, `field`, `rule`, `message`. Global flags are defined in [Standard global flags](../cli/global-flags). For `bus validate`, stdout is empty on success and `--output` has no effect (no result set). For help, run `bus validate --help`.

### Parity and gap checks (first-class)

The module exposes deterministic migration checks as subcommands: `bus validate parity --source <file>` (source-import parity: counts and sums by dataset and period) and `bus validate journal-gap --source <file>` (journal gap: imported operational vs non-opening journal by month). Both support optional threshold flags (`--max-abs-delta`, `--max-count-delta`, `--max-pct-delta-*`) and CI-friendly exit semantics; `--dry-run` emits planned thresholds and scope to stderr without writing a result set. Output is a result set (TSV) to stdout or to the file given by `--output`. A possible future extension is class-aware gap reporting (e.g. operational vs financing/transfer buckets); see [Suggested capabilities](../sdd/bus-validate#suggested-capabilities-out-of-current-scope) in the module SDD.

Script-based diagnostics (e.g. `exports/2024/022-erp-parity-2024.sh`) remain available as an alternative.

### Files

Reads all workspace datasets and schemas. Does not write.

### Exit status

`0` when the workspace is valid. Non-zero on invalid usage or when schema or invariant violations are found.

### Development state

**Value promise:** Validate workspace datasets and invariants so the accounting workflow can run a single check before period close and filing and get deterministic diagnostics.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** high — Run and schema/invariant checks are test-verified; user can complete pre-close validation and get pass/fail and diagnostics. Stdout is empty on success; `--format text` (default) and `--format tsv` control diagnostics to stderr; `--output` is a no-op for `bus validate` (no result set). First-class `parity` and `journal-gap` subcommands are implemented with thresholds and CI exit behavior.

**Use case readiness:** Accounting workflow: high — run, schema/invariant checks, empty stdout, format, and output no-op are in place; parity and journal-gap available. Finnish bookkeeping and tax-audit compliance: high — workspace validation and migration checks available; audit and closed-period would strengthen. Finnish company reorganisation: high — same as above.

**Current:** Verified. `cmd/bus-validate/run_test.go` and `tests/e2e_bus_validate.sh` verify success/failure exit codes, missing CSV, schema and invariant errors, journal double-entry balance, FK handling, and global flags (help, version, quiet, output no-op for validate, chdir, color, format text/tsv and unknown format, quiet+verbose, terminator, errors to stderr). Parity and journal-gap subcommands, dry-run, and threshold/CI behavior are covered. Success path leaves stdout empty.

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

