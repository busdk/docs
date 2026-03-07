---
title: bus-reports
description: bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma.
---

## `bus-reports` — generate trial balance, ledger, and statement reports

### Synopsis

`bus reports trial-balance --as-of <YYYY-MM-DD> [--format <text|csv>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports general-ledger --period <period> [--account <account-id>] [--format <text|csv|markdown|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports day-book --period <period> [--format <text|csv|markdown|pdf>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports profit-and-loss --period <period> [--format <text|csv|markdown|json|kpa|pma|pdf>] [--layout-id <id>] [--layout <file>] [--comparatives <on|off>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|kpa|pma|pdf>] [--layout-id <id>] [--layout <file>] [--comparatives <on|off>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports balance-sheet-specification --as-of <YYYY-MM-DD> [--format <text|csv|markdown|json|pdf>] [--layout-id <id>] [--layout <file>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports parity [options] [-C <dir>] [global flags]`  
`bus reports journal-gap [options] [-C <dir>] [global flags]`  
`bus reports compliance-checklist --period <YYYY|YYYY-MM|YYYYQn> [--format <tsv|csv|json|text>] [-C <dir>] [global flags]`  
`bus reports journal-coverage --from <YYYY-MM> --to <YYYY-MM> [--source-summary <path>] [--exclude-opening] [--format <text|csv|json>] [-C <dir>] [-o <file>] [global flags]`  
`bus reports materials-register [--format <text|csv|markdown|json|pdf>] [-C <dir>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus reports` computes financial reports from journal and reference data.
Reports are deterministic and derived only from repository data.
The module does not modify datasets.

Use it for period close, filing preparation, and management reporting.
Migration-quality outputs are available through `parity`, `journal-gap`, and `journal-coverage`.
[bus-validate](./bus-validate) provides threshold and CI behavior for parity and journal-gap checks.

### Commands

`trial-balance` prints trial balance as of a date and supports `text` (default) or `csv`. `general-ledger` prints ledger detail for a period and can be filtered by account. `day-book` prints postings in date order (päiväkirja) for the period. `profit-and-loss` prints period P&L, and `balance-sheet` prints balance sheet as of a date.

`parity` and `journal-gap` emit deterministic migration-review artifacts for use with [bus-validate](./bus-validate) threshold and CI behavior. `compliance-checklist` emits a Finnish legal-form-aware checklist for the selected period with `required`, `conditionally_required`, and `not_applicable` states. `journal-coverage` emits deterministic monthly comparison between imported operational totals and non-opening journal activity. `materials-register` emits a deterministic index of accounting records and materials (luettelo kirjanpidoista ja aineistoista) based on `datapackage.json` resources and their schemas, including linkage fields and retention classes for audit evidence packs. `balance-sheet-specification` emits an internal-only balance-sheet breakdown (tase-erittely) by statement line and account with evidence references for audit packs; it is not a public filing document.

### Finnish statutory financial statements

For Finnish filing-facing output, `bus reports` provides deterministic TASE and tuloslaskelma results with explicit layout ids and account mapping.
The module covers statement output, comparatives, consistency checks, and PDF metadata for dating/signing workflows.

In TASE output, BusDK follows the Finnish two-sided presentation under `TASE`. Asset lines are presented under `VASTAAVA` in uppercase. Liability and equity lines are presented under `VASTATTAVAA`, with the closing total shown as `Vastattavaa yhteensä`. For end-of-year presentation, asset balances belong on the debit side, liability balances belong on the credit side, and equity is usually credit-sided but can also be debit-sided when accumulated losses or comparable equity deficits require that presentation. The printed TASE is only valid when `VASTAAVA` and `VASTATTAVAA` are equal.

In tuloslaskelma output, BusDK follows the statutory grouping order instead of printing a flat account list. The expected structure is `Liikevaihto`, `Liiketoiminnan muut tuotot`, `Materiaalit ja palvelut`, `Henkilöstökulut`, `Poistot ja arvonalentumiset`, `Liiketoiminnan muut kulut`, `LIIKEVOITTO (-tappio)`, `Rahoitustuotot- ja kulut`, `TULOS ENNEN TILINPÄÄTÖSSIIRTOJA JA VEROJA`, `TULOVEROT`, and `TILIKAUDEN VOITTO (-TAPPIO)`. Within `Materiaalit ja palvelut`, the layout includes at least `Materiaalit`, `Ulkopuoliset palvelut`, and the subtotal `Materiaalit ja palvelut yhteensä`. Within `Henkilöstökulut`, the layout includes at least `Palkat ja palkkiot`, `Henkilösivukulut`, and the subtotal `Henkilöstökulut yhteensä`. Within `Rahoitustuotot- ja kulut`, the layout includes at least `Rahoitustuotot`, `Rahoituskulut`, and the subtotal `Rahoitustuotot- ja kulut yhteensä`.

For printed tuloslaskelma lines, income is shown as positive and expenses as negative statement amounts. This presentation rule is separate from ledger debet/kredit normal-side handling. `LIIKEVOITTO (-tappio)`, `TULOS ENNEN TILINPÄÄTÖSSIIRTOJA JA VEROJA`, and `TILIKAUDEN VOITTO (-TAPPIO)` are calculated statement totals, not manually entered report rows.

The command surface supports statutory layout selection with `--layout-id`. Common built-in identifiers include `fi-kpa-tuloslaskelma-kululaji`, `fi-kpa-tuloslaskelma-toiminto`, `fi-kpa-tase`, `fi-kpa-tase-lyhennetty`, `fi-pma-tuloslaskelma-kululaji`, `fi-pma-tuloslaskelma-toiminto`, `fi-pma-tase`, `fi-pma-tase-lyhennetty`, plus full-layout options such as `kpa-full` and `pma-full`. For internal drill-down, `fi-kpa-tuloslaskelma-full-accounts`, `fi-kpa-tuloslaskelma-kululaji-accounts`, `fi-pma-tuloslaskelma-full-accounts`, and `fi-pma-tuloslaskelma-kululaji-accounts` expand grouped rows with per-account `Tilinumero`, `Tilin nimi`, and `Saldo`.

These ids are presets of the general layout mechanism documented in [Module reference: bus-reports](../modules/bus-reports).
`--layout <file>` remains available for custom layouts.
The selected layout governs text, CSV, JSON, KPA/PMA, and PDF outputs.

### TASE / tuloslaskelma layout parity

Finnish full-layout parity is implemented with built-in full layout ids (for example `kpa-full`, `pma-full`, `fi-kpa-tase-full`, `fi-pma-tase-full`, `fi-kpa-tuloslaskelma-full`, and `fi-pma-tuloslaskelma-full`).
`fi-*` layouts use deterministic account mapping.

The `*-accounts` tuloslaskelma variants are internal review layouts. They keep the same grouped statutory row order but add account-level rows under each mapped subgroup in deterministic account-code order. Group totals and result rows stay visible, so the report can be read both as a statement and as a tilikohtainen breakdown. When a workspace defines explicit mapping for the base layout such as `pma-full` or `fi-kpa-tuloslaskelma-full`, the matching `*-accounts` variant inherits that same effective mapping by default so the drill-down report does not reclassify accounts differently from the parent statement.

In human-facing grouped output, the hierarchy is also made visible in formatting. Main groups and subtotal/result rows are emphasized, subgroup rows are indented, and `*-accounts` layouts indent account rows one level deeper than their host subgroup. This applies to text, markdown, CSV, and PDF rendering so the calculation structure stays readable across review outputs.

For PDF output, the statutory table uses the full printable page width and wraps long labels onto continuation lines when needed. This keeps long Finnish row labels such as `TULOS ENNEN TILINPÄÄTÖSSIIRTOJA JA VEROJA` readable instead of clipping them to a narrow label column.

For `fi-*` layouts, mapping comes from `report-account-mapping.csv` by account code and `layout_id`.
Unmapped or ambiguous accounts are errors unless explicitly mapped to a permitted statutory other-bucket line.

Comparatives are enabled by default from workspace reporting profile settings and can be overridden with `--comparatives`.
When prior-period data exists, comparative columns are expected.
`Tase-erittelyt` are not filed to PRH and are out of scope for this module.

### Options

`trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>`. `general-ledger`, `day-book`, and `profit-and-loss` require `--period <period>`. `general-ledger` accepts optional `--account <account-id>`. Trial-balance accepts `-f text` (default) or `-f csv` only (not `tsv`). Other report commands accept `--format` as documented; for balance-sheet and profit-and-loss, `json`, `kpa`, `pma`, and `pdf` are also supported. `general-ledger` and `day-book` also support `--format pdf` for filing-grade ledger exports.

For balance-sheet and profit-and-loss, `--layout-id <id>` selects a built-in layout and `--layout <file>` selects a custom layout file. These options are mutually exclusive; if both are given, the command exits with usage error (exit code 2).

For balance-sheet and profit-and-loss, `--comparatives <on|off>` overrides the workspace profile default for comparative columns. When omitted, behavior comes from workspace configuration.

For detailed statutory mapping and parity behavior, see [Module reference: bus-reports](../modules/bus-reports).

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus reports --help`.

When `--locale` is omitted, `bus reports` derives presentation formatting from the process locale environment in order `LC_ALL`, `LC_NUMERIC`, then `LANG`. Human-facing outputs such as `text`, `markdown`, `kpa`, `pma`, and `pdf` therefore pick up Finnish decimal commas automatically from settings such as `LC_ALL=fi_FI.UTF-8`, while machine-facing `csv`, `json`, and `tsv` stay dot-decimal for deterministic parsing.

For regulated PDFs, missing entity metadata and signature metadata are shown as blank fill-in fields in the document itself rather than as placeholder commentary text. The command also prints explicit stderr guidance that tells the user how to configure company name, Y-tunnus, signer names, and signature date with `bus config set ...` commands.

### Journal coverage and parity reports

`bus reports journal-coverage --from <YYYY-MM> --to <YYYY-MM> [--source-summary <path>] [--exclude-opening] [--format <text|csv|json>]` emits a deterministic monthly comparison between imported totals and non-opening journal activity. `bus reports parity` emits source-import parity artifacts by period, and `bus reports journal-gap` emits bucket-based gap artifacts through `--account-buckets <file>`. These outputs are machine-friendly review artifacts. [bus-validate](./bus-validate) adds threshold-based pass/fail behavior for CI.

### Files

Reads [journal](./bus-journal), [period](./bus-period), and [accounts](./bus-accounts) datasets and optionally budget datasets. For statutory layouts, also reads workspace reporting profile settings from [bus-config](./bus-config) (`datapackage.json`) and account mapping from `report-account-mapping.csv`. `materials-register` reads `datapackage.json` resources and their schemas to enumerate storage paths and linkage fields. `balance-sheet-specification` uses the balance-sheet layout and account mapping to emit internal evidence drill-downs; it is internal-only and not a public filing output. Reports are computed from validated journal data inside explicit period boundaries, including year-end close/opening transitions managed by [bus-period](./bus-period). Writes only to stdout (or to the file given by global `--output`). When `--output` targets an existing file, bus-reports replaces it only after successful report generation; failed runs preserve the previous file content.

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
bus reports day-book \
  --period 2026-01 \
  --format pdf \
  -o ./out/paivakirja-2026-01.pdf
bus reports journal-coverage \
  --from 2026-01 \
  --to 2026-03 \
  --format json \
  -o ./out/journal-coverage-2026q1.json
bus reports materials-register \
  --format pdf \
  -o ./out/materials-register.pdf
bus reports \
  --format pdf \
  -o ./out/tase-erittely-2026.pdf \
  balance-sheet-specification \
  --as-of 2026-12-31
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

# same as: bus reports day-book --period 2026-01 --format pdf
reports day-book --period 2026-01 --format pdf
```

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
- [Module reference: bus-reports](../modules/bus-reports)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Module reference: bus-validate](../modules/bus-validate)
- [Module reference: bus-reconcile](../modules/bus-reconcile)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Regulated report PDFs (TASE and tuloslaskelma)](../modules/bus-reports)
- [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
- [PRH: Tilinpäätösilmoituksen asiakirjat kaupparekisteriin](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/ilmoituksen_liitteet.html)
- [PRH: Digitaalinen iXBRL-rajapinta ohjelmistoyrityksille](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/digitaalinen-tilinpaatosraportointi/rajapinta.html)
- [Finlex: Kirjanpitoasetus 1339/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1339)
- [Finlex: Valtioneuvoston asetus 1753/2015 (PMA)](https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2015/1753)
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
