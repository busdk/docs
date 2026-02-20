---
title: bus-vat — VAT computation, reports, and export
description: bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven and reconcile-evidence cash-basis VAT modes.
---

## `bus-vat` — VAT computation, reports, and export

### Overview

Command names follow [CLI command naming](../cli/command-naming). `bus vat` computes VAT totals per reporting period, validates VAT code and rate mappings against reference data, and reconciles invoice VAT with ledger postings. It writes VAT summaries and export data as repository data so they remain reviewable and exportable for archiving and [VAT reporting and payment](../workflow/vat-reporting-and-payment). The module **owns the definition of VAT period boundaries**: the actual sequence of reporting periods (start and end dates) used for allocation and reporting. That sequence can include transitions when the period length changes within a year (e.g. monthly → yearly → quarterly), transition periods (e.g. 4 months), and non-standard first or last periods (e.g. 18-month first period after registration). Workspace-level inputs come from [bus config](./bus-config) — current `vat_reporting_period`, `vat_timing`, and optional `vat_registration_start` / `vat_registration_end` — with the canonical definition of those keys and allowed values in [Workspace configuration](../data/workspace-configuration). The module uses those settings as inputs and may maintain a period-definition dataset or logic to produce the authoritative list of periods, then allocates transactions and invoices to those periods and produces reports and exports.

Where invoice master data is incomplete or absent (e.g. journal-first bookkeeping or migration), the module supports **journal-driven VAT mode**: computing VAT period totals from journal postings and VAT-related account and tax mappings, with deterministic period allocation and traceable diagnostics. The same period boundaries, allocation rules, and output formats apply as for the invoice-based path; only the input source differs. Use `bus vat validate|report|export --source journal` to run in journal-driven mode.

For payment-evidence cash-basis filing (`maksuperusteinen`), the module also supports **reconcile-evidence cash mode**: `bus vat report|export --source reconcile --basis cash`. This mode derives VAT periodization from payment evidence (`matches.csv` + `bank-transactions.csv`) and splits partial payments proportionally across invoice VAT/net evidence rows with deterministic source references and deterministic cent allocation.

### Synopsis

`bus vat init [-C <dir>] [global flags]`  
`bus vat validate [-C <dir>] [global flags]`  
`bus vat report --period <period> [-C <dir>] [global flags]`  
`bus vat export --period <period> [-C <dir>] [global flags]`  
`bus vat fi-file --period <period> [-C <dir>] [global flags]`  
`bus vat explain --period <period> [-C <dir>] [global flags]`  
`bus vat period-profile <list|import> [-C <dir>] [global flags]`  
`bus vat filed-import --period <period> --file <path> [-C <dir>] [global flags]`  
`bus vat filed-diff --period <period> [-C <dir>] [global flags]`

### Commands

`init` creates the baseline VAT datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their beside-the-table schemas) when they are absent. If all owned VAT datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero.

`report` computes and emits the VAT summary for a given period. `export` writes VAT export output for a period (e.g. for filing). Both require `--period <period>`. Period selection follows the same `--period` flag pattern used by other period-scoped modules; VAT commands do not use a positional period argument.

`filed-import` imports externally filed VAT evidence for a period with provenance (`source_path`, `source_sha256`) and writes canonical period data at workspace root (`vat-filed-<period>.csv`) plus an index row in `vat-filed.csv`. Existing period evidence is refused unless `--force`.

`filed-diff` compares filed VAT totals vs replay totals for the same period and emits deterministic machine-readable TSV with filed/replay/delta values for output/input/net VAT. It exits non-zero when any absolute delta exceeds `--threshold-cents` (default `0`).

`fi-file` emits one-command Finnish VAT filing payload values (machine-consumable `json|csv|tsv`) with deterministic formulas, provenance refs, and `calculation_version` metadata.

`explain` emits deterministic row-level FI filing trace grouped by FI field keys (`tsv|json`) for audit verification.

`period-profile` manages named filing period profiles in `vat-period-profiles.csv`:
- `list` outputs deterministic profile rows.
- `import --file <csv>` normalizes/imports profile definitions for `--period-profile` runs.

### Options

`report`, `export`, `fi-file`, `explain`, `filed-import`, and `filed-diff` support period selection via one of:
- `--period <period>`
- `--from <date> --to <date>`
- `--period-profile <id>` (resolved from `vat-period-profiles.csv`)

`fi-file` supports `--payload-format json|csv|tsv` and outputs one-command filing-ready FI field values.
`explain` supports `--format tsv|json`.
`--strict-fi-eu-rc` enables strict FI reverse-charge classification marker validation (non-zero exit on unresolved rows).

`filed-import` requires `--file <path>`. `filed-diff` supports `--threshold-cents <int>` and exits `1` when any absolute VAT delta exceeds threshold. When using `--source journal`, journal rows are read from the journal area and normalized for VAT reporting. Direction is resolved deterministically in this order: row `direction` (`sale`/`purchase`), then `vat-account-mapping.csv` direction by `account_id`, then `accounts.csv` account type (`income` => `sale`, `expense` => `purchase`). Amount can be provided as `amount_cents` (integer) or `amount` (decimal major units). Rate uses row-level `vat_rate_bp` first, then `vat_rate`/`vat_percent`, then mapping (`vat_rate_bp`/`rate_bp`/`vat_rate`/`vat_percent`) from `vat-account-mapping.csv`. For mapped VAT-account rows that have direction but no explicit rate, amount is treated as VAT amount (net 0). Legacy fallback also infers VAT amount from sided debit/credit postings on likely VAT accounts (for example `293x`) when mapping is missing and row rate is absent. Opening-balance rows are excluded from journal-source VAT reporting, including rows identifiable via opening voucher/source kind or opening-style source identifiers (for example `opening:*`). In cash basis, bank evidence references such as `bank_row:<id>:journal:<n>` are normalized to corresponding bank transaction ids (including `erp-bank-<id>` forms) for payment-date lookup. If direction cannot be resolved for a row, the command fails with a clear diagnostic naming the row/account and required fallback data.

When using `--source reconcile --basis cash`, VAT rows are derived from `matches.csv` (`kind=invoice_payment`), `bank-transactions.csv` payment dates (`booked_date`/`booking_date`/`value_date`/`booked_at`), and invoice evidence rows. Partial payments are split proportionally across invoice VAT/net rows and allocated to the bank payment-date period.
Reconcile cash mode also emits deterministic coverage diagnostics as a `COVERAGE` output row:
- matched sales share
- matched purchase share
- unmatched cash rows
and machine-readable source refs for diagnostics provenance.
Coverage gating is configurable:
- `--strict-coverage` to fail when coverage is below thresholds
- `--min-sales-coverage <0..1>` and `--min-purchase-coverage <0..1>` to set required minimum shares
Without strict mode, partial coverage continues with an explicit warning on stderr.
When using `--source journal --basis cash`, payment-date allocation uses journal payment-date evidence columns when present (`payment_date`/`paid_date`/`value_date`/`booked_date`/`booking_date`/`booked_at`), optional `bank_txn_id` lookup to `bank-transactions.csv`, and falls back to `posting_date` when explicit payment evidence is missing.
Evidence-first context applies: country/party context is read from invoice evidence first; `entities.csv` is only fallback enrichment.

Cash-basis treatment handling is explicit:
- `reverse_charge`, `intra_eu_supply`, `export`, `exempt` require `vat_cents=0` on evidence rows in this mode; otherwise the command fails with a deterministic diagnostic.
- `domestic_standard`, `domestic_reduced`, `import`, and unknown/custom treatment codes are processed from explicit line VAT/net evidence.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus vat --help`.

### Journal source: vat-account-mapping.csv

For journal-driven VAT (`--source journal`), direction and optional rate can be supplied by a mapping file `vat-account-mapping.csv` at the workspace root. Required columns: `account_id` (chart-of-accounts identifier) and `direction` (`sale` or `purchase`). Optional rate columns: `vat_rate_bp` or `rate_bp` (basis points), and legacy-compatible `vat_rate`/`vat_percent`. One row per account that needs explicit direction (e.g. asset/liability VAT accounts such as 293x that are not income/expense in `accounts.csv`). Direction resolution order is: row `direction` → `vat-account-mapping.csv` by `account_id` → `accounts.csv` account type (income ⇒ sale, expense ⇒ purchase). In journal-first or migrated workspaces where the journal has no row-level `direction` and posts to non–P&L VAT accounts, add rows to `vat-account-mapping.csv` for those account_ids so report and export can resolve direction. Migration guidance: ensure every journal account that appears in VAT-relevant postings either has `direction` on the row, a mapping row, or an income/expense type in `accounts.csv`; otherwise the command fails with a diagnostic. Optionally, a default mapping for common Finnish non–P&L VAT accounts can be shipped or documented in the [module SDD implementation status](../sdd/bus-vat#implementation-status-journal-driven-mode).

### Files

The module reads invoice and journal datasets and optional VAT reference datasets (e.g. `vat-rates.csv`). It writes VAT summaries, exports, and filed evidence as repository data. VAT master/index data (`vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv`, `vat-filed.csv` and their schemas) is stored at the workspace root only; the module does not create or use a `vat/` or other subdirectory for those datasets. When period-specific report/return/filed data is written to its own file, that file is also stored at the workspace root with a date prefix (e.g. `vat-reports-2026Q1.csv`, `vat-returns-2026Q1.csv`, `vat-filed-2026Q1.csv`), not under a subdirectory. The module may maintain a period-definition dataset (e.g. `vat-periods.csv`) or logic at the workspace root to produce the list of periods. Path resolution is owned by this module; other modules that need read-only access to VAT datasets obtain the path(s) from this module’s Go library, not by hardcoding file names (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus vat init
bus vat report --period 2026-01
bus vat report --period 2026-01 --source reconcile --basis cash
bus vat fi-file --period 2026-01 --payload-format json
bus vat explain --period 2026-01 --format tsv
bus vat period-profile import --file ./vat-period-profiles.csv
bus vat filed-import --period 2026-01 --file ./authority-2026-01.csv
bus vat filed-diff --period 2026-01 --threshold-cents 0
```

### Exit status

`0` on success. Non-zero on invalid usage or VAT mapping violations.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus vat --help
vat --help

# same as: bus vat -V
vat -V
```


### Development state

**Value promise:** Compute VAT reports and export period returns from workspace invoice or journal data so users can complete the close-period VAT step and archive returns for filing with traceable source refs.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 90% — Core VAT close workflow plus FI filing payload/explain/profile tooling are implemented and test-verified.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 80% — close-step VAT (init→validate→report→export) from invoice or journal completable with source_refs and index update. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 80% — VAT report and export with invoice/voucher refs; closed-period/--force and rate validation verified.

**Current:** Init (incl. --dry-run), validate (incl. rate check, vat_registered=false, --period, --source journal), report/export from invoice or journal with source_refs, FI filing payload (`fi-file`), FI row-level explain output (`explain`), strict FI reverse-charge marker validation (`--strict-fi-eu-rc`), period profile import/list and `--period-profile` selection, filed evidence import (`filed-import`) with provenance hash, deterministic filed-vs-replay diff (`filed-diff`) with threshold-based exit, vat-returns/vat-filed index updates, closed-period export re-run control (`--force`), and path API are verified by `tests/e2e_bus_vat.sh` and unit tests in `internal/app/run_test.go`, `internal/vat/` (including `fi_filing_test.go` and `period_profiles_test.go`), `vatpath/path_test.go`, and `internal/cli/flags_test.go`.

**Planned next:** None in PLAN.md; all documented requirements satisfied.

**Blockers:** None known.

**Depends on:** [bus-period](./bus-period), [bus-journal](./bus-journal), [bus-invoices](./bus-invoices) (data sources for report/export).

**Used by:** End users for reporting and export; no other module invokes it.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-config (VAT configuration reference)](./bus-config)
- [Workspace configuration](../data/workspace-configuration)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-vat](../sdd/bus-vat)
- [Layout: VAT area](../layout/vat-area)
- [Workflow: VAT reporting and payment](../workflow/vat-reporting-and-payment)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
