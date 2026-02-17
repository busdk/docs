---
title: bus-validate — validate workspace datasets and invariants
description: bus validate checks all workspace datasets against their schemas and enforces cross-table invariants (e.g.
---

## `bus-validate` — validate workspace datasets and invariants

### Synopsis

`bus validate [--format <text|tsv>] [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus validate` checks all workspace datasets against their schemas and enforces cross-table invariants (e.g. balanced debits/credits, valid references, period integrity). It does not modify data. Use before period close and filing. Diagnostics go to stderr; stdout is empty on success.

### Commands

This module has no subcommands. Run `bus validate` from the workspace (or use `-C <dir>`).

### Options

`--format text` (default) or `--format tsv` controls diagnostics format. TSV columns are `dataset`, `record_id`, `field`, `rule`, `message`. Global flags are defined in [Standard global flags](../cli/global-flags). For help, run `bus validate --help`.

### Files

Reads all workspace datasets and schemas. Does not write.

### Exit status

`0` when the workspace is valid. Non-zero on invalid usage or when schema or invariant violations are found.

### Development state

**Value promise:** Validate workspace datasets and invariants so the accounting workflow can run a single check before period close and filing and get deterministic diagnostics.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 50% — Run and schema/invariant checks verified by tests; user can run pre-close validation and get pass/fail and diagnostics. Diagnostics format (text/tsv), empty stdout on success, and --output no-op are in PLAN; audit and closed-period checks not implemented.

**Use case readiness:** Accounting workflow: 50% — run and schema/invariant checks verified; format and empty stdout would complete pre-close contract. Finnish bookkeeping and tax-audit compliance: 50% — workspace validation for coherence before close/filing verified; audit and closed-period would strengthen. Finnish company reorganisation: 50% — workspace validation before evidence pack verified; same gaps.

**Current:** Verified only. `cmd/bus-validate/run_test.go` and `tests/e2e_bus_validate.sh` verify success/failure exit codes, missing CSV, schema parse and required/enum/primaryKey/foreignKey errors, journal double-entry balance, FK cascade suppression, ambiguous FK, and global flags (help, version, quiet, output, chdir, color, format-unknown, quiet+verbose, terminator, errors to stderr). `internal/validate/type_property_test.go`, `internal/validate/schema_test.go`, `internal/workspace/discover_test.go`, and `internal/cli/flags_test.go` verify type validation, FK schema shapes, discovery and naming styles, and flag parsing. Success path currently prints "validation ok" to stdout; empty stdout on success is planned.

**Planned next:** `--format text` (default) and `--format tsv` for diagnostics; empty stdout on success and `--output` no-op for validate (PLAN.md). Table Schema min/max constraints; audit-trail and closed-period checks to advance [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) and [Finnish company reorganisation](../compliance/fi-company-reorganisation-evidence-pack).

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

