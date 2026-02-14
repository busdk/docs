---
title: bus-reports
description: bus reports computes financial reports from journal entries and reference data.
---

## `bus-reports` — generate trial balance, ledger, and statement reports

### Synopsis

`bus reports trial-balance --as-of <YYYY-MM-DD> [--format <text|csv>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <period> [--account <account-id>] [--format <text|csv>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports profit-and-loss --period <period> [--format <text|csv>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--format <text|csv>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus reports` computes financial reports from journal entries and reference data. Reports are deterministic and derived only from repository data; the module does not modify datasets. Use for period close, filing, and management reporting.

### Commands

- `trial-balance` prints trial balance as of a date.
- `general-ledger` prints ledger detail for a period (optionally filtered by account).
- `profit-and-loss` prints profit and loss for a period.
- `balance-sheet` prints balance sheet as of a date.

### Options

`trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>`. `general-ledger` and `profit-and-loss` require `--period <period>`. `general-ledger` accepts optional `--account <account-id>`. All report commands accept `--format <text|csv>` (default `text`). Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reports --help`.

### Files

Reads journal, accounts, and optionally budget datasets. Writes only to stdout (or the file given by global `--output`).

### Exit status

`0` on success. Non-zero on invalid usage or integrity failures.

### Development state

**Value:** Produce trial balance, account-ledger, and statement-style reports from journal and period data so the [accounting workflow](../workflow/accounting-workflow-overview) can generate financial output after close.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 50% (Primary journey) — trial balance and account-ledger implemented; unit tests cover run, workspace load, and report logic. No e2e.

**Use case readiness:** Accounting workflow: 50% — trial balance and account-ledger verified by unit tests; general-ledger and period support would complete. Finnish compliance: 50% — reports support statements; traceable line items (NFR-REP-001) and KPA/PMA would complete.

**Current:** Unit tests in `internal/app/run_test.go`, `internal/workspace/load_test.go`, and `internal/report/report_test.go` prove run dispatch, workspace loading, and report generation. No e2e; report output shape is not asserted end-to-end.

**Planned next:** general-ledger with --period and --account; trial-balance --as-of; --period for P&amp;L; stable text format; traceability; optional budget; KPA/PMA.

**Blockers:** None known.

**Depends on:** [bus-journal](./bus-journal), [bus-period](./bus-period); optionally [bus-budget](./bus-budget).

**Used by:** End users for reporting; no other module invokes it.

See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-reports](../sdd/bus-reports)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)

