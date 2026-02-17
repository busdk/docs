---
title: bus-reports
description: bus reports computes financial reports from journal entries and reference data.
---

## `bus-reports` — generate trial balance, ledger, and statement reports

### Synopsis

`bus reports trial-balance --as-of <YYYY-MM-DD> [--format <text|csv|markdown>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <period> [--account <account-id>] [--format <text|csv|markdown>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports profit-and-loss --period <period> [--format <text|csv|markdown|json|kpa|pma|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|kpa|pma|pdf>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus reports` computes financial reports from journal entries and reference data. Reports are deterministic and derived only from repository data; the module does not modify datasets. Use for period close, filing, and management reporting.

### Commands

- `trial-balance` prints trial balance as of a date.
- `general-ledger` prints ledger detail for a period (optionally filtered by account).
- `profit-and-loss` prints profit and loss for a period.
- `balance-sheet` prints balance sheet as of a date.

### Options

`trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>`. `general-ledger` and `profit-and-loss` require `--period <period>`. `general-ledger` accepts optional `--account <account-id>`. All report commands accept `--format <text|csv|markdown>` (default `text`). For balance-sheet and profit-and-loss, `json`, `kpa`, `pma`, and `pdf` are also supported. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reports --help`.

### Files

Reads journal, accounts, and optionally budget datasets. Writes only to stdout (or the file given by global `--output`).

### Exit status

`0` on success. Non-zero on invalid usage or integrity failures.

### Development state

**Value promise:** Produce trial balance, general-ledger, account-ledger, and statement-style reports from journal and period data so the [accounting workflow](../workflow/accounting-workflow-overview) can generate financial output after close.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 90% — Close-step reports and all formats (text/csv/json/markdown, KPA/PMA, TASE/tuloslaskelma PDF) and balance-sheet/profit-and-loss `--layout` file with custom labels verified by e2e and unit tests; FR-REP-004 account→line mapping in layout schema not implemented.

**Use case readiness:** Accounting workflow: 90% — Close-step reports verified by e2e; user can run trial-balance, general-ledger, profit-and-loss, balance-sheet, account-ledger with text/csv/json/markdown, KPA/PMA, and TASE/tuloslaskelma PDF. Finnish bookkeeping and tax-audit compliance: 90% — Reports, traceability (basis in JSON), KPA/PMA, and TASE/tuloslaskelma PDF verified by e2e. Finnish company reorganisation: 90% — Trial balance and ledgers as audit evidence; KPA/PMA and TASE/tuloslaskelma PDF verified by e2e.

**Current:** `tests/e2e_bus_reports.sh` verifies help, version, global flags (color, format, chdir, output, quiet, `--`), trial-balance (text/csv/json/markdown with basis), balance-sheet and profit-and-loss (text, kpa, pma, pdf), balance-sheet `--layout` file with custom labels and trial-balance + `--layout` → exit 2, optional budget for P&amp;L, general-ledger (all and `--account`), account-ledger (`--from`/`--to`), and error cases. `internal/app/run_test.go` verifies CLI success/error paths, PDF and KPA/PMA formats, layout-file and layout-only-for-BS/P&amp;L behavior, and flag behavior; `internal/report/report_test.go` verifies report logic, PDF writer (FR-REP-003), and KPA/PMA; `internal/report/layout_test.go` verifies layout resolution (default, kpa, layout file) and balance-sheet/profit-and-loss with layout in all formats; `internal/workspace/load_test.go`, `internal/app/period_test.go`, and `internal/cli/flags_test.go` verify workspace load, period parsing, and flag parsing.

**Planned next:** FR-REP-004 account→line mapping in layout schema (built-in or layout file) per PLAN.md; advances [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) and [accounting workflow](../workflow/accounting-workflow-overview).

**Blockers:** None known.

**Depends on:** [bus-journal](./bus-journal), [bus-period](./bus-period); optionally [bus-budget](./bus-budget).

**Used by:** End users for reporting; no other module invokes it.

See [Development status](../implementation/development-status).

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
- [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)

