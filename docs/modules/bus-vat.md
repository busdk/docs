---
title: bus-vat — VAT computation, reports, and export
description: bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven and reconcile-evidence cash-basis VAT modes.
---

## `bus-vat` — VAT computation, reports, and export

### Overview

Command names follow [CLI command naming](../cli/command-naming).

`bus vat` computes VAT totals per reporting period, validates VAT code and rate mappings, and reconciles invoice VAT with ledger postings.
It writes VAT summaries and exports as repository data for review and filing workflows.

The module owns VAT period boundary definition and period allocation logic.
Workspace settings from [bus config](./bus-config) (`vat_reporting_period`, `vat_timing`, and optional registration dates) are inputs to that logic.

When invoice data is incomplete, use journal-driven mode:
`bus vat validate|report|export --source journal`.

For payment-evidence cash-basis filing, use reconcile-evidence mode:
`bus vat report|export --source reconcile --basis cash`.

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
`list` outputs deterministic profile rows. `import --file <csv>` normalizes and imports profile definitions for `--period-profile` runs.

### Options

`report`, `export`, `fi-file`, `explain`, `filed-import`, and `filed-diff` support period selection via one of:
`--period <period>`, `--from <date> --to <date>`, or `--period-profile <id>` resolved from `vat-period-profiles.csv`.

`fi-file` supports `--payload-format json|csv|tsv` and outputs one-command filing-ready FI field values.
`explain` supports `--format tsv|json`.
`--strict-fi-eu-rc` enables strict FI reverse-charge classification marker validation (non-zero exit on unresolved rows).

`filed-import` requires `--file <path>`.
`filed-diff` supports `--threshold-cents <int>` and exits `1` when any absolute delta exceeds threshold.

In `--source journal` mode, direction and rate are resolved deterministically from row values, account mapping (`vat-account-mapping.csv`), and account type fallbacks.
Opening-balance rows are excluded.
If direction cannot be resolved, the command fails with a clear diagnostic.

When using `--source reconcile --basis cash`, VAT rows come from `matches.csv`, `bank-transactions.csv`, and invoice evidence rows.
Partial payments are split proportionally across VAT and net rows and allocated by bank payment date.

Reconcile cash mode emits deterministic coverage diagnostics as a `COVERAGE` output row:
matched sales share, matched purchase share, and unmatched cash rows.
Coverage gating is configurable:
use `--strict-coverage` to fail when coverage is below thresholds, and use `--min-sales-coverage <0..1>` with `--min-purchase-coverage <0..1>` to set required minimum shares.
Without strict mode, partial coverage continues with an explicit warning on stderr.

In `--source journal --basis cash`, payment-date allocation uses payment evidence columns first, optional bank transaction lookup second, and posting date fallback last.
Evidence-first context applies: invoice evidence is primary, `entities.csv` is fallback enrichment.

Cash-basis treatment handling:
`reverse_charge`, `intra_eu_supply`, `export`, and `exempt` require `vat_cents=0` on evidence rows in this mode; otherwise the command fails with a deterministic diagnostic. `domestic_standard`, `domestic_reduced`, `import`, and unknown/custom treatment codes are processed from explicit line VAT/net evidence.

Detailed resolution and fallback rules are maintained in [Module SDD: bus-vat](../sdd/bus-vat).

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus vat --help`.

### Journal source: vat-account-mapping.csv

For journal-driven VAT (`--source journal`), direction and optional rate can be supplied by a mapping file `vat-account-mapping.csv` at the workspace root. Required columns: `account_id` (chart-of-accounts identifier) and `direction` (`sale` or `purchase`). Optional rate columns: `vat_rate_bp` or `rate_bp` (basis points), and legacy-compatible `vat_rate`/`vat_percent`. One row per account that needs explicit direction (e.g. asset/liability VAT accounts such as 293x that are not income/expense in `accounts.csv`). Direction resolution order is: row `direction` → `vat-account-mapping.csv` by `account_id` → `accounts.csv` account type (income ⇒ sale, expense ⇒ purchase). In journal-first or migrated workspaces where the journal has no row-level `direction` and posts to non–P&L VAT accounts, add rows to `vat-account-mapping.csv` for those account_ids so report and export can resolve direction. Migration guidance: ensure every journal account that appears in VAT-relevant postings either has `direction` on the row, a mapping row, or an income/expense type in `accounts.csv`; otherwise the command fails with a diagnostic. Optionally, a default mapping for common Finnish non–P&L VAT accounts can be shipped or documented in the [module SDD implementation status](../sdd/bus-vat#implementation-status-journal-driven-mode).

### Files

The module reads invoice and journal datasets and optional VAT reference datasets (e.g. `vat-rates.csv`). It writes VAT summaries, exports, and filed evidence as repository data. VAT master/index data (`vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv`, `vat-filed.csv` and their schemas) is stored at the workspace root only; the module does not create or use a `vat/` or other subdirectory for those datasets. When period-specific report/return/filed data is written to its own file, that file is also stored at the workspace root with a date prefix (e.g. `vat-reports-2026Q1.csv`, `vat-returns-2026Q1.csv`, `vat-filed-2026Q1.csv`), not under a subdirectory. The module may maintain a period-definition dataset (e.g. `vat-periods.csv`) or logic at the workspace root to produce the list of periods. Path resolution is owned by this module; other modules that need read-only access to VAT datasets obtain the path(s) from this module’s Go library, not by hardcoding file names (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus vat init
bus vat report --period 2026-01
bus vat report --from 2026-01-01 --to 2026-01-31 --source journal
bus vat report --period 2026-01 --source reconcile --basis cash
bus vat export --period-profile monthly-2026-q1 --strict-coverage --min-sales-coverage 0.95 --min-purchase-coverage 0.90
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
# same as: bus vat report --period 2026-01 --source journal
vat report --period 2026-01 --source journal

# same as: bus vat export --period 2026-01 --source reconcile --basis cash --strict-coverage
vat export --period 2026-01 --source reconcile --basis cash --strict-coverage

# same as: bus vat filed-diff --period 2026-01 --threshold-cents 0
vat filed-diff --period 2026-01 --threshold-cents 0
```


### Development state

**Value promise:** Compute VAT reports and export period returns from workspace invoice or journal data so users can complete the close-period VAT step and archive returns for filing with traceable source refs.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

**Completeness:** 90% — Core VAT close workflow plus FI filing payload/explain/profile tooling are implemented and test-verified.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview): 80% — close-step VAT (init→validate→report→export) from invoice or journal completable with source_refs and index update. [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit): 80% — VAT report and export with invoice/voucher refs; closed-period/--force and rate validation verified.

**Current:** Init/validate/report/export, journal-source mode, reconcile cash mode, FI filing payload/explain, period profiles, and filed import/diff are test-verified.
Detailed test and implementation notes are maintained in [Module SDD: bus-vat](../sdd/bus-vat).

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
