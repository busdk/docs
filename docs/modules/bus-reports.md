---
title: bus-reports
description: bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma.
---

## `bus-reports` — generate trial balance, ledger, and statement reports

### Synopsis

`bus reports trial-balance --as-of <YYYY-MM-DD> [--format <text|csv>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <period> [--account <account-id>] [--format <text|csv|markdown>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports profit-and-loss --period <period> [--format <text|csv|markdown|json|kpa|pma|pdf>] [--layout-id <id>] [--layout <file>] [--comparatives <on|off>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|kpa|pma|pdf>] [--layout-id <id>] [--layout <file>] [--comparatives <on|off>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports parity [options] [-C <dir>] [global flags]`  
`bus reports journal-gap [options] [-C <dir>] [global flags]`  
`bus reports compliance-checklist --period <YYYY|YYYY-MM|YYYYQn> [--format <tsv|csv|json|text>] [-C <dir>] [global flags]`  
`bus reports journal-coverage --from <YYYY-MM> --to <YYYY-MM> [--source-summary <path>] [--exclude-opening] [--format <text|csv|json>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus reports` computes financial reports from journal and reference data.
Reports are deterministic and derived only from repository data.
The module does not modify datasets.

Use it for period close, filing preparation, and management reporting.
Migration-quality outputs are available through `parity`, `journal-gap`, and `journal-coverage`.
[bus-validate](./bus-validate) provides threshold and CI behavior for parity and journal-gap checks.

### Commands

`trial-balance` prints trial balance as of a date and supports `text` (default) or `csv`. `general-ledger` prints ledger detail for a period and can be filtered by account. `profit-and-loss` prints period P&L, and `balance-sheet` prints balance sheet as of a date.

`parity` and `journal-gap` emit deterministic migration-review artifacts for use with [bus-validate](./bus-validate) threshold and CI behavior. `compliance-checklist` emits a Finnish legal-form-aware checklist for the selected period with `required`, `conditionally_required`, and `not_applicable` states. `journal-coverage` emits deterministic monthly comparison between imported operational totals and non-opening journal activity.

### Finnish statutory financial statements

For Finnish filing-facing output, `bus reports` provides deterministic TASE and tuloslaskelma results with explicit layout ids and account mapping.
The module covers statement output, comparatives, consistency checks, and PDF metadata for dating/signing workflows.

The command surface supports statutory layout selection with `--layout-id`. Common built-in identifiers include `fi-kpa-tuloslaskelma-kululaji`, `fi-kpa-tuloslaskelma-toiminto`, `fi-kpa-tase`, `fi-kpa-tase-lyhennetty`, `fi-pma-tuloslaskelma-kululaji`, `fi-pma-tuloslaskelma-toiminto`, `fi-pma-tase`, `fi-pma-tase-lyhennetty`, plus full-layout options such as `kpa-full` and `pma-full`.

These ids are presets of the general layout mechanism documented in [Module SDD: bus-reports](../sdd/bus-reports).
`--layout <file>` remains available for custom layouts.
The selected layout governs text, CSV, JSON, KPA/PMA, and PDF outputs.

### TASE / tuloslaskelma layout parity

Finnish full-layout parity is implemented with built-in full layout ids (for example `kpa-full`, `pma-full`, `fi-kpa-tase-full`, `fi-pma-tase-full`, `fi-kpa-tuloslaskelma-full`, and `fi-pma-tuloslaskelma-full`).
`fi-*` layouts use deterministic account mapping.

For `fi-*` layouts, mapping comes from `report-account-mapping.csv` by account code and `layout_id`.
Unmapped or ambiguous accounts are errors unless explicitly mapped to a permitted statutory other-bucket line.

Comparatives are enabled by default from workspace reporting profile settings and can be overridden with `--comparatives`.
When prior-period data exists, comparative columns are expected.
`Tase-erittelyt` are not filed to PRH and are out of scope for this module.

### Options

`trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>`. `general-ledger` and `profit-and-loss` require `--period <period>`. `general-ledger` accepts optional `--account <account-id>`. Trial-balance accepts `-f text` (default) or `-f csv` only (not `tsv`). Other report commands accept `--format` as documented; for balance-sheet and profit-and-loss, `json`, `kpa`, `pma`, and `pdf` are also supported.

For balance-sheet and profit-and-loss, `--layout-id <id>` selects a built-in layout and `--layout <file>` selects a custom layout file. These options are mutually exclusive; if both are given, the command exits with usage error (exit code 2).

For balance-sheet and profit-and-loss, `--comparatives <on|off>` overrides the workspace profile default for comparative columns. When omitted, behavior comes from workspace configuration.

For detailed statutory mapping and parity behavior, see [Module SDD: bus-reports](../sdd/bus-reports).

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reports --help`.

### Journal coverage and parity reports

`bus reports journal-coverage --from <YYYY-MM> --to <YYYY-MM> [--source-summary <path>] [--exclude-opening] [--format <text|csv|json>]` emits a deterministic monthly comparison between imported totals and non-opening journal activity. `bus reports parity` emits source-import parity artifacts by period, and `bus reports journal-gap` emits bucket-based gap artifacts through `--account-buckets <file>`. These outputs are machine-friendly review artifacts. [bus-validate](./bus-validate) adds threshold-based pass/fail behavior for CI.

### Files

Reads [journal](./bus-journal), [period](./bus-period), and [accounts](./bus-accounts) datasets and optionally budget datasets. For statutory layouts, also reads workspace reporting profile settings from [bus-config](./bus-config) (`datapackage.json`) and account mapping from `report-account-mapping.csv`. Reports are computed from validated journal data inside explicit period boundaries, including year-end close/opening transitions managed by [bus-period](./bus-period). Writes only to stdout (or the file given by global `--output`).

### Examples

```bash
bus reports trial-balance \
  --as-of 2026-01-31 \
  --format csv \
  -o ./out/trial-balance-2026-01.csv
bus reports profit-and-loss \
  --period 2026-01 \
  --format markdown \
  -o ./out/pl-2026-01.md
bus reports balance-sheet \
  --as-of 2026-12-31 \
  --layout-id fi-kpa-tase \
  --format pdf \
  -o ./out/tase-2026.pdf
bus reports journal-coverage \
  --from 2026-01 \
  --to 2026-03 \
  --format json \
  -o ./out/journal-coverage-2026q1.json
```

### Exit status

`0` on success. Non-zero on invalid usage, integrity failures, statutory mapping failures, or statutory statement reconciliation failures.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus reports profit-and-loss --period 2026-01 --layout-id fi-kpa-tuloslaskelma-kululaji --format kpa
reports profit-and-loss --period 2026-01 --layout-id fi-kpa-tuloslaskelma-kululaji --format kpa

# same as: bus reports balance-sheet --as-of 2026-12-31 --layout-id fi-pma-tase --comparatives on --format json
reports balance-sheet --as-of 2026-12-31 --layout-id fi-pma-tase --comparatives on --format json

# same as: bus reports parity --format csv
reports parity --format csv
```


### Development state

**Value promise:** Produce trial balance, general-ledger, account-ledger, and statement-style reports from journal and period data so the accounting workflow can generate financial output after close.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit), [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](../compliance/fi-company-reorganisation-evidence-pack).

**Completeness:** 90% — Close-step report commands and formats (text/csv/markdown/json/kpa/pma/pdf) are verified by e2e and unit tests; user can complete the report step in all three use cases. `bus reports journal-coverage`, `bus reports parity`, and `bus reports journal-gap` are implemented as deterministic migration-review artifacts, and profile-driven defaults (FR-REP-005), report-account-mapping (FR-REP-007), and comparatives (FR-REP-008) are covered by tests.

**Use case readiness:** Accounting workflow: 90% — Trial-balance, general-ledger, profit-and-loss, balance-sheet, account-ledger with text/csv/json/markdown/kpa/pma/pdf, built-in statutory layouts (kpa, pma, kpa-full), TASE/tuloslaskelma PDF, and layout-file selection verified by e2e and unit tests; report step completable. Finnish bookkeeping and tax-audit compliance: 90% — Reports, traceability (basis in JSON), statutory layouts and PDF output verified by e2e; user can produce statement outputs for compliance. Finnish company reorganisation: 90% — Trial balance and ledgers as audit evidence; statutory layouts and PDF verified by e2e; evidence-pack report step completable.

**Current:** Trial balance, ledger, statutory statement outputs, layout selection, and migration-quality reports are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-reports](../sdd/bus-reports).

**Planned next:** None in PLAN.md.

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
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
