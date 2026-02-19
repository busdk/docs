---
title: bus-vat — VAT computation, reporting, and export (SDD)
description: Bus VAT computes VAT totals per reporting period, validates VAT code and rate mappings against reference data, and reconciles invoice VAT with ledger…
---

## bus-vat — VAT computation, reporting, and export

### Introduction and Overview

Bus VAT computes VAT totals per reporting period, validates VAT code and rate mappings against reference data, and reconciles invoice VAT with ledger postings. It **owns the definition of VAT period boundaries**: the actual sequence of reporting periods (start and end dates) used for allocation and reporting. That sequence can include transitions when the period length changes within a year (e.g. monthly → yearly → quarterly), transition periods (e.g. 4 months), and non-standard first or last periods (e.g. 18-month first period after registration). Bus-vat uses workspace-level inputs from [bus-config](../sdd/bus-config) — current `vat_reporting_period`, `vat_timing`, and optional `vat_registration_start` / `vat_registration_end` — and may maintain a period-definition dataset or logic to produce the authoritative list of periods. The canonical definition of those configuration keys and allowed values is in [bus-config](../sdd/bus-config) and [Workspace configuration](../data/workspace-configuration).

Some bookkeeping sources are journal-first and do not have complete invoice master datasets. VAT workflows that emphasize invoice data as the primary source can block migration and parity workflows for such sources. The module therefore supports a **journal-driven VAT mode**: computation of VAT period totals from journal postings plus VAT-related account and tax mappings, with deterministic period allocation and traceable diagnostics. That mode enables VAT reporting in migrations where invoice masters are incomplete and improves parity for historical datasets while preserving auditability and deterministic outputs.

### Requirements

FR-VAT-001 VAT computations. The module MUST compute VAT summaries from invoice and journal data. Acceptance criteria: VAT report outputs are deterministic and traceable to source postings.

FR-VAT-002 VAT export outputs. The module MUST write VAT summary and export files as repository data. Acceptance criteria: export outputs are recorded in datasets such as `vat-reports.csv` and `vat-returns.csv`.

FR-VAT-003 CLI surface for VAT baseline. The module MUST provide an `init` command that creates the VAT baseline datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their schemas) when they are absent. When they already exist in full, `init` MUST print a warning to standard error and exit 0 without modifying anything. When they exist only partially, `init` MUST fail with a clear error and not write any file (see [bus-init](../sdd/bus-init) FR-INIT-004). Acceptance criteria: `bus vat init` is available; idempotent and partial-state behavior as specified.

FR-VAT-004 Journal-driven VAT mode. The module MUST support computing VAT period totals from journal postings and VAT-related account/tax mappings when invoice master data is incomplete or absent. Acceptance criteria: period allocation is deterministic; diagnostics are traceable to source postings and mappings; report and export outputs remain append-only and audit-ready; behavior is equivalent in auditability and determinism to the invoice-based path where both sources exist.

NFR-VAT-003 Decimal-safe money arithmetic. All VAT money calculations (base amounts, VAT amounts, totals, export values, and thresholds) MUST use decimal-safe arithmetic and MUST NOT rely on binary floating-point. Acceptance criteria: computations use exact decimal-safe representations (scaled cents or exact decimal/rational types), rounding behavior is explicit and deterministic, and repeated runs produce byte-identical monetary outputs for the same inputs.

NFR-VAT-001 Auditability. VAT corrections MUST be append-only and traceable to original records. Acceptance criteria: corrections create new records that reference originals.

NFR-VAT-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (e.g. vat-rates, vat-reports, vat-returns, and any period-definition or period-scoped files and their schemas). Other modules that need read-only access to VAT raw file(s) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration can be supported without breaking consumers. Acceptance criteria: the library provides path accessor(s) for the VAT datasets; consumers use these accessors for read-only access; no consumer hardcodes VAT file names outside this module.

### System Architecture

Bus VAT reads invoice and journal datasets and optional VAT reference datasets to compute reports and exports. It integrates with filing workflows and reporting outputs. Period boundaries (including transitions and non-standard lengths) are defined within the VAT module, e.g. via a period-definition dataset or logic that consumes workspace config.

### Key Decisions

KD-VAT-001 VAT outputs are stored as repository data. VAT summaries and exports remain reviewable and exportable.

KD-VAT-002 VAT period boundaries are owned by bus-vat. The sequence of VAT reporting periods (including changes within a year from monthly to yearly to quarterly, 4-month transition periods, 18-month first period, and partial first or last periods from registration dates) is defined or computed by bus-vat. Workspace config in bus-config supplies the current period length and registration start/end dates as inputs; bus-vat is the single place that produces the actual list of (start_date, end_date) periods for reporting and allocation.

KD-VAT-003 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of VAT datasets for read-only access. Write access and all VAT business logic remain in this module.

KD-VAT-004 Journal-driven mode supports migration and legacy scenarios. Where invoice master data is incomplete or absent, VAT period totals are computed from journal postings and VAT-related account/tax mappings. The same period boundaries, allocation rules, and output formats apply as for the invoice-based path; only the input source differs. The binding is `--source journal` on `bus vat validate|report|export`.

### Component Design and Interfaces

Interface IF-VAT-001 (module CLI). The module exposes `bus vat` with subcommands `init`, `validate`, `report`, and `export` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline VAT datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their beside-the-table schemas) when they are absent. If all owned VAT datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Documented parameters include `bus vat report --period <period>` and `bus vat export --period <period>`. Period selection follows the same `--period` flag pattern used by other period-scoped modules, and VAT commands do not use a positional period argument. Journal-driven VAT mode (FR-VAT-004) is invoked with `--source journal` on `bus vat validate|report|export`.

Interface IF-VAT-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to its owned data file(s) (vat-rates, vat-reports, vat-returns, and any period-definition or period-scoped files and their schemas). Given a workspace root path and optionally a period identifier, the library returns the relevant path(s); resolution MUST allow future override from workspace or data package configuration. Other modules use these accessors for read-only access only; all writes and VAT logic remain in this module.

Usage examples:

```bash
bus vat report --period 2026Q1
bus vat export --period 2026Q1
```

### Data Design

The module reads invoice data and journal postings and writes VAT summaries and export data. It owns the definition of VAT period boundaries; that definition may be stored in a period-definition dataset (e.g. `vat-periods.csv`) at the workspace root or computed from workspace config and rules. VAT master data (vat-rates.csv, vat-reports.csv, vat-returns.csv and their schemas) is stored in the workspace root only; the module does not create or use a `vat/` or other subdirectory for those datasets. When period-specific report or return data is written to its own file (rather than only appended to the root index datasets), that file is also stored at the workspace root with a date prefix, for example `vat-reports-2026Q1.csv` or `vat-returns-2026Q1.csv`, not under a subdirectory such as `2026/vat-reports/`. The index datasets at root record which period files exist and where they live.

In journal-driven VAT mode (FR-VAT-004), inputs are journal postings and VAT-related account/tax mappings (e.g. chart-of-accounts or mapping tables that identify which accounts and tax codes contribute to VAT). Period boundaries and allocation rules are unchanged; outputs (vat-reports, vat-returns) use the same schemas and repository layout so that migration and parity workflows produce reviewable, deterministic results.

Other modules that need read-only access to VAT datasets MUST obtain the path(s) from this module’s Go library (IF-VAT-002). All writes and VAT-domain logic remain in this module.

### Assumptions and Dependencies

Bus VAT depends on invoice and journal datasets and on VAT reference datasets such as `vat-rates.csv`. It reads accounting entity settings from the workspace `datapackage.json` (maintained by [bus-config](../sdd/bus-config)): `vat_registered`, `vat_reporting_period` (current/default period length), `vat_timing`, and optionally `vat_registration_start` and `vat_registration_end`. The VAT module owns the authoritative list of period boundaries; it uses those workspace settings as inputs and may maintain a period-definition dataset (e.g. `vat-periods.csv`) or logic to produce periods that can include transitions and non-standard lengths. The VAT engine uses that period list for allocation and reporting, and `vat_timing` to choose the allocation date (performance, invoice, or payment date). Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

VAT data is repository data and should be protected by repository access controls. Evidence references remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or VAT mapping violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover VAT computations and mapping validation, and command-level tests exercise `report` and `export` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic VAT outputs.

### Glossary and Terminology

VAT report: a computed summary of VAT totals for a reporting period.  
VAT export: a repository data output intended for filing or archiving.  
Journal-driven VAT mode: computation of VAT period totals from journal postings and VAT-related account/tax mappings instead of (or in addition to) invoice master data; used when invoice masters are incomplete or absent (e.g. migration or legacy sources).

### Implementation status (journal-driven mode)

Journal-driven mode is implemented on `bus vat validate|report|export --source journal`. Invoice source and journal source (with direction resolvable) work. Direction fallback is deterministic: row `direction` (`sale`/`purchase`), then `vat-account-mapping.csv` direction by `account_id`, then `accounts.csv` account type (`income` => `sale`, `expense` => `purchase`). VAT rate fallback is deterministic: row `vat_rate_bp` first, then row `vat_rate`/`vat_percent`, then `vat-account-mapping.csv` (`vat_rate_bp`/`rate_bp`/`vat_rate`/`vat_percent`) for `account_id`. Legacy fallbacks: (1) when mapping provides direction for a VAT account but no rate, the posting amount is treated as VAT amount (net set to 0); (2) when mapping is missing, sided debit/credit rows on likely VAT accounts (for example `293x`) are interpreted as VAT-amount rows with inferred direction. Opening-balance rows are excluded from journal-source VAT totals, including rows identified via opening voucher/source kind or opening-style source identifiers (for example `opening:*`). For cash basis date resolution, bank evidence references such as `bank_row:<id>:journal:<n>` are normalized to candidate bank transaction ids (including `erp-bank-<id>`) before lookup in `bank-transactions.csv`. If direction remains unresolved, commands fail with deterministic diagnostics that identify the row/account and required normalization input (e.g. `journal-2023.csv row N: missing direction (need direction column value sale|purchase, vat-account-mapping.csv direction for account_id "XXXX", or accounts.csv type income/expense for account_id "XXXX")`).

In workspaces where journal posts to asset/liability VAT accounts (e.g. 293x) or other non–income/expense accounts without a `direction` column, `--source journal` can fail because neither the row nor `accounts.csv` type supplies direction; adding a mapping in `vat-account-mapping.csv` for those account_ids would resolve it. Still to do: (1) Document the direction fallback and the optional `vat-account-mapping.csv` format (columns, semantics) so legacy workspaces can add mapping for asset/liability VAT accounts. (2) Optionally extend the fallback (e.g. treat known VAT account code ranges as purchase/sale by convention) or ship a default mapping for common Finnish VAT accounts. Goal: `--source journal` usable for journal-first workspaces without adding a `direction` column to legacy journal CSVs. No SDD change is required; the implementation status and module docs will be updated to document `vat-account-mapping.csv` format and any optional default mapping when that documentation is added.

### Open Questions

None. OQ-VAT-001 (journal-driven mode binding) is resolved: the binding is `--source journal` on `bus vat validate|report|export`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-config module SDD](../sdd/bus-config) (canonical VAT configuration contract)
- [Workspace configuration (datapackage.json extension)](../data/workspace-configuration)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [End user documentation: bus-vat CLI reference](../modules/bus-vat)
- [Repository](https://github.com/busdk/bus-vat)
- [VAT area](../layout/vat-area)
- [VAT reporting and payment](../workflow/vat-reporting-and-payment)

### Document control

Title: bus-vat module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-VAT`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
