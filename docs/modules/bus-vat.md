---
title: bus-vat — VAT computation, reports, and export
description: bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven VAT when invoice masters are incomplete.
---

## `bus-vat` — VAT computation, reports, and export

### Overview

Command names follow [CLI command naming](../cli/command-naming). `bus vat` computes VAT totals per reporting period, validates VAT code and rate mappings against reference data, and reconciles invoice VAT with ledger postings. It writes VAT summaries and export data as repository data so they remain reviewable and exportable for archiving and [VAT reporting and payment](../workflow/vat-reporting-and-payment). The module **owns the definition of VAT period boundaries**: the actual sequence of reporting periods (start and end dates) used for allocation and reporting. That sequence can include transitions when the period length changes within a year (e.g. monthly → yearly → quarterly), transition periods (e.g. 4 months), and non-standard first or last periods (e.g. 18-month first period after registration). Workspace-level inputs come from [bus config](./bus-config) — current `vat_reporting_period`, `vat_timing`, and optional `vat_registration_start` / `vat_registration_end` — with the canonical definition of those keys and allowed values in [Workspace configuration](../data/workspace-configuration). The module uses those settings as inputs and may maintain a period-definition dataset or logic to produce the authoritative list of periods, then allocates transactions and invoices to those periods and produces reports and exports.

Where invoice master data is incomplete or absent (e.g. journal-first bookkeeping or migration), the module supports **journal-driven VAT mode**: computing VAT period totals from journal postings and VAT-related account and tax mappings, with deterministic period allocation and traceable diagnostics. The same period boundaries, allocation rules, and output formats apply as for the invoice-based path; only the input source differs. Use `bus vat validate|report|export --source journal` to run in journal-driven mode.

### Synopsis

`bus vat init [-C <dir>] [global flags]`  
`bus vat validate [-C <dir>] [global flags]`  
`bus vat report --period <period> [-C <dir>] [global flags]`  
`bus vat export --period <period> [-C <dir>] [global flags]`

### Commands

`init` creates the baseline VAT datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their beside-the-table schemas) when they are absent. If all owned VAT datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero.

`report` computes and emits the VAT summary for a given period. `export` writes VAT export output for a period (e.g. for filing). Both require `--period <period>`. Period selection follows the same `--period` flag pattern used by other period-scoped modules; VAT commands do not use a positional period argument.

### Options

`report` and `export` require `--period <period>`. When using `--source journal`, journal rows are read from the journal area and normalized for VAT reporting. Direction is resolved deterministically in this order: row `direction` (`sale`/`purchase`), then `vat-account-mapping.csv` direction by `account_id`, then `accounts.csv` account type (`income` => `sale`, `expense` => `purchase`). Amount can be provided as `amount_cents` (integer) or `amount` (decimal major units). Rate uses row-level `vat_rate_bp` first, then `vat_rate_bp` (or `rate_bp`) from `vat-account-mapping.csv`. If direction cannot be resolved for a row, the command fails with a clear diagnostic naming the row/account and required fallback data. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus vat --help`.

### Journal source: vat-account-mapping.csv

For journal-driven VAT (`--source journal`), direction and optional rate can be supplied by a mapping file `vat-account-mapping.csv` at the workspace root. Required columns: `account_id` (chart-of-accounts identifier) and `direction` (`sale` or `purchase`). Optional columns: `vat_rate_bp` or `rate_bp` (VAT rate in basis points). One row per account that needs explicit direction (e.g. asset/liability VAT accounts such as 293x that are not income/expense in `accounts.csv`). Direction resolution order is: row `direction` → `vat-account-mapping.csv` by `account_id` → `accounts.csv` account type (income ⇒ sale, expense ⇒ purchase). In journal-first or migrated workspaces where the journal has no row-level `direction` and posts to non–P&L VAT accounts, add rows to `vat-account-mapping.csv` for those account_ids so report and export can resolve direction. Migration guidance: ensure every journal account that appears in VAT-relevant postings either has `direction` on the row, a mapping row, or an income/expense type in `accounts.csv`; otherwise the command fails with a diagnostic. Optionally, a default mapping for common Finnish non–P&L VAT accounts can be shipped or documented in the [module SDD implementation status](../sdd/bus-vat#implementation-status-journal-driven-mode).

### Files

The module reads invoice and journal datasets and optional VAT reference datasets (e.g. `vat-rates.csv`). It writes VAT summaries and exports as repository data. VAT master data (`vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their schemas) is stored at the workspace root only; the module does not create or use a `vat/` or other subdirectory for those datasets. When period-specific report or return data is written to its own file, that file is also stored at the workspace root with a date prefix (e.g. `vat-reports-2026Q1.csv`, `vat-returns-2026Q1.csv`), not under a subdirectory. The module may maintain a period-definition dataset (e.g. `vat-periods.csv`) or logic at the workspace root to produce the list of periods. Path resolution is owned by this module; other modules that need read-only access to VAT datasets obtain the path(s) from this module’s Go library, not by hardcoding file names (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus vat init
bus vat report --period 2026-01
```

### Exit status

`0` on success. Non-zero on invalid usage or VAT mapping violations.

### Development state

**Value promise:** Compute VAT reports and export period returns from workspace invoice or journal data so users can complete the close-period VAT step and archive returns for filing with traceable source refs.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 80% — Close-step VAT (init→validate→report→export) from invoice or journal with source_refs and index update is test-verified; user can complete the journey from either source.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 80% — close-step VAT (init→validate→report→export) from invoice or journal completable with source_refs and index update. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 80% — VAT report and export with invoice/voucher refs; closed-period/--force and rate validation verified.

**Current:** Init (incl. --dry-run), validate (incl. rate check, vat_registered=false, --period, --source journal), report and export from invoice or journal with source_refs, vat-returns index update, closed-period re-export/--force, and path API are verified by `tests/e2e_bus_vat.sh` and unit tests in `internal/app/run_test.go`, `internal/vat/` (export_test.go, report_test.go, init_test.go, config_test.go, journal_test.go, validate_rate_test.go, periods_test.go), `vatpath/path_test.go`, and `internal/cli/flags_test.go`. Legacy journal datasets without row-level `direction` are supported via mapping and accounts fallback (vat-account-mapping.csv by account_id, then accounts.csv account type); commands fail deterministically only when all direction sources are missing, with diagnostics that identify the row/account.

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

