---
title: bus-reports
description: bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma.
---

## `bus-reports` — generate trial balance, ledger, and statement reports

### Synopsis

`bus reports trial-balance --as-of <YYYY-MM-DD> [--format <text|csv|markdown>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <period> [--account <account-id>] [--format <text|csv|markdown>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports profit-and-loss --period <period> [--format <text|csv|markdown|json|kpa|pma|pdf>] [--layout-id <id>] [--layout <file>] [--comparatives <on|off>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|kpa|pma|pdf>] [--layout-id <id>] [--layout <file>] [--comparatives <on|off>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus reports` computes financial reports from journal and reference data. Reports are deterministic and derived only from repository data; the module does not modify datasets. Use for period close, filing preparation, and management reporting.

The planned migration-quality extension adds a non-opening journal coverage report that compares monthly imported operational totals against journal activity for gap detection workflows. This report surface is specified but not yet implemented.

### Commands

- `trial-balance` prints trial balance as of a date.
- `general-ledger` prints ledger detail for a period (optionally filtered by account).
- `profit-and-loss` prints profit and loss for a period.
- `balance-sheet` prints balance sheet as of a date.

### Finnish statutory financial statements

For Finnish filing-facing statement output, `bus reports` is configured to produce deterministic TASE and tuloslaskelma outputs with explicit layout identifiers and explicit account mapping. The filing-facing minimum in this module is statement output (balance sheet and income statement), comparative handling, consistency validations, and PDF metadata suitable for dating and signing workflows.

The command surface supports statutory layout selection using `--layout-id`. Built-in layout identifiers include:

- `fi-kpa-tuloslaskelma-kululaji`
- `fi-kpa-tuloslaskelma-toiminto`
- `fi-kpa-tase`
- `fi-kpa-tase-lyhennetty`
- `fi-pma-tuloslaskelma-kululaji`
- `fi-pma-tuloslaskelma-toiminto` (where applicable)
- `fi-pma-tase`
- `fi-pma-tase-lyhennetty` (where applicable)

These layout ids are presets of the general layout mechanism documented in [bus-reports SDD](../sdd/bus-reports). `--layout <file>` remains available for custom layouts. The same selected layout governs text, CSV, JSON, KPA/PMA, and PDF output structures. Built-in Finnish layouts produce section-level summaries with Finnish labels (e.g. Pysyvät vastaavat, LIIKEVAIHTO). Full line-by-line parity with a source TASE or tuloslaskelma — same structure and labels as the original — may require a custom layout and fine-grained account mapping; see [Implementation status](../sdd/bus-reports#implementation-status-finnish-full-layout-parity) in the module SDD.

For `fi-*` layouts, account mapping must be deterministic per selected layout. The mapping dataset is `report-account-mapping.csv`, joined to accounts by account code and to statement output by `layout_id`. Unmapped or ambiguously mapped accounts are errors unless the account is explicitly mapped to a permitted statutory other-bucket line in the selected layout.

Statutory comparatives are enabled by default through workspace reporting profile configuration and can be overridden per command with `--comparatives`. When prior-period data exists, comparative columns are expected; first fiscal year is the normal exception. `Tase-erittelyt` are not filed to PRH and are out of generation scope for this module.

### Options

`trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>`. `general-ledger` and `profit-and-loss` require `--period <period>`. `general-ledger` accepts optional `--account <account-id>`. All report commands accept `--format <text|csv|markdown>` (default `text`). For balance-sheet and profit-and-loss, `json`, `kpa`, `pma`, and `pdf` are also supported.

For balance-sheet and profit-and-loss, `--layout-id <id>` selects a built-in layout and `--layout <file>` selects a custom layout file. These options are mutually exclusive; if both are given, the command exits with usage error (exit code 2).

For balance-sheet and profit-and-loss, `--comparatives <on|off>` overrides the workspace profile default for comparative columns. When omitted, behavior comes from workspace configuration.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reports --help`.

### Journal coverage report (planned)

The planned command surface adds a deterministic coverage report, for example `bus reports journal-coverage --from <YYYY-MM> --to <YYYY-MM> --source-summary <path> --exclude-opening`, to emit monthly deltas between imported operational data and non-opening journal activity. Threshold pass or fail decisions remain in [bus-validate](./bus-validate), while bus-reports emits the deterministic coverage rows.

### Files

Reads [journal](./bus-journal), [period](./bus-period), and [accounts](./bus-accounts) datasets and optionally budget datasets. For statutory layouts, also reads workspace reporting profile settings from [bus-config](./bus-config) (`datapackage.json`) and account mapping from `report-account-mapping.csv`. Reports are computed from validated journal data inside explicit period boundaries, including year-end close/opening transitions managed by [bus-period](./bus-period). Writes only to stdout (or the file given by global `--output`).

### Exit status

`0` on success. Non-zero on invalid usage, integrity failures, statutory mapping failures, or statutory statement reconciliation failures.

### Development state

**Value promise:** Produce trial balance, general-ledger, account-ledger, and statement-style reports from journal and period data so the accounting workflow can generate financial output after close.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 90% — Close-step report commands and formats (text/csv/markdown/json/kpa/pma/pdf) are verified by e2e and unit tests; user can complete the report step in all three use cases. Profile-driven defaults (FR-REP-005), report-account-mapping (FR-REP-007), comparatives (FR-REP-008), and journal-coverage report are not yet implemented.

**Use case readiness:** Accounting workflow: 90% — Trial-balance, general-ledger, profit-and-loss, balance-sheet, account-ledger with text/csv/json/markdown/kpa/pma/pdf, built-in statutory layouts (kpa, pma, kpa-full), TASE/tuloslaskelma PDF, and layout-file selection verified by e2e and unit tests; report step completable. Finnish bookkeeping and tax-audit compliance: 90% — Reports, traceability (basis in JSON), statutory layouts and PDF output verified by e2e; user can produce statement outputs for compliance. Finnish company reorganisation: 90% — Trial balance and ledgers as audit evidence; statutory layouts and PDF verified by e2e; evidence-pack report step completable.

**Current:** `tests/e2e_bus_reports.sh` verifies help, version, global flags (color, format, chdir, output, quiet, `--`), journal-area layout (journals.csv + period-segmented), ledger integrity before reports (FR-REP-002), trial-balance/balance-sheet/profit-and-loss in text/csv/json/markdown/kpa/pma/pdf, layout-file selection with custom labels and account mapping (FR-REP-004), built-in kpa-full layout, general-ledger and account-ledger, and error cases. `internal/app/run_test.go`, `internal/report/report_test.go`, and `internal/report/layout_test.go` verify CLI paths, PDF (FR-REP-003), layout resolution (default/kpa/pma/kpa-full) and mapping; `internal/workspace/load_test.go`, `internal/app/period_test.go`, and `internal/cli/flags_test.go` verify workspace load, period parsing, and flag parsing.

**Planned next:** Add non-opening journal coverage report for migration gap checks (advances accounting workflow and source-import parity). Expose stable `--layout-id` and fi-* built-in identifiers, workspace reporting profile (FR-REP-005), and report-account-mapping (FR-REP-007) per PLAN.md.

**Blockers:** None known.

**Depends on:** [journal](./bus-journal), [period](./bus-period); optionally [budget](./bus-budget).

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
- [Module SDD: bus-validate](../sdd/bus-validate)
- [Module SDD: bus-reconcile](../sdd/bus-reconcile)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)
- [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
- [PRH: Tilinpäätösilmoituksen asiakirjat kaupparekisteriin](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/ilmoituksen_liitteet.html)
- [PRH: Digitaalinen iXBRL-rajapinta ohjelmistoyrityksille](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/digitaalinen-tilinpaatosraportointi/rajapinta.html)
- [Finlex: Kirjanpitoasetus 1339/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1339)
- [Finlex: Valtioneuvoston asetus 1753/2015 (PMA)](https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2015/1753)

