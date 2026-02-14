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

**Value:** Validate workspace datasets and invariants so the [accounting workflow](../workflow/accounting-workflow-overview) can run a single check before period close and filing and get deterministic diagnostics.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 50% (Primary journey) — workspace and resource validation implemented; unit tests cover run and type/constraint checks. No e2e; format and stdout behavior not fully verified.

**Use case readiness:** Accounting workflow: 50% — run and type checks verified; format and success stdout would complete pre-close check. Finnish compliance: 50% — validation supports coherence; audit and closed-period checks would strengthen.

**Current:** Unit tests in `cmd/bus-validate/run_test.go`, `internal/validate/type_property_test.go`, and `internal/workspace/normalize_fuzz_test.go` prove run, type validation, and workspace normalization. No e2e; format and success stdout behavior are in PLAN.

**Planned next:** --format text (default) and tsv; empty stdout on success; help; min/max; audit and closed-period protection.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Run before [bus-period](./bus-period) close and [bus-filing](./bus-filing); workflows assume validation is available.

See [Development status](../implementation/development-status).

---

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

