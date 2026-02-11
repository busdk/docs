## bus-vat

### Introduction and Overview

Bus VAT computes VAT totals per reporting period, validates VAT code and rate mappings against reference data, and reconciles invoice VAT with ledger postings.

### Requirements

FR-VAT-001 VAT computations. The module MUST compute VAT summaries from invoice and journal data. Acceptance criteria: VAT report outputs are deterministic and traceable to source postings.

FR-VAT-002 VAT export outputs. The module MUST write VAT summary and export files as repository data. Acceptance criteria: export outputs are recorded in datasets such as `vat-reports.csv` and `vat-returns.csv`.

FR-VAT-003 CLI surface for VAT baseline. The module MUST provide an `init` command that creates the VAT baseline datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their schemas) when they are absent. When they already exist in full, `init` MUST print a warning to standard error and exit 0 without modifying anything. When they exist only partially, `init` MUST fail with a clear error and not write any file (see [bus-init](../sdd/bus-init) FR-INIT-004). Acceptance criteria: `bus vat init` is available; idempotent and partial-state behavior as specified.

NFR-VAT-001 Auditability. VAT corrections MUST be append-only and traceable to original records. Acceptance criteria: corrections create new records that reference originals.

### System Architecture

Bus VAT reads invoice and journal datasets and optional VAT reference datasets to compute reports and exports. It integrates with filing workflows and reporting outputs.

### Key Decisions

KD-VAT-001 VAT outputs are stored as repository data. VAT summaries and exports remain reviewable and exportable.

### Component Design and Interfaces

Interface IF-VAT-001 (module CLI). The module exposes `bus vat` with subcommands `init`, `report`, and `export` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline VAT datasets and schemas (e.g. `vat-rates.csv`, `vat-reports.csv`, `vat-returns.csv` and their beside-the-table schemas) when they are absent. If all owned VAT datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Documented parameters include `bus vat report --period <period>` and `bus vat export --period <period>`. Period selection follows the same `--period` flag pattern used by other period-scoped modules, and VAT commands do not use a positional period argument.

Usage examples:

```bash
bus vat report --period 2026Q1
bus vat export --period 2026Q1
```

### Data Design

The module reads invoice data and journal postings and writes VAT summaries and export data. VAT master data (vat-rates.csv, vat-reports.csv, vat-returns.csv and their schemas) is stored in the workspace root only; the module does not create or use a `vat/` or other subdirectory for those datasets. When period-specific report or return data is written to its own file (rather than only appended to the root index datasets), that file is also stored at the workspace root with a date prefix, for example `vat-reports-2026Q1.csv` or `vat-returns-2026Q1.csv`, not under a subdirectory such as `2026/vat-reports/`. The index datasets at root record which period files exist and where they live.

### Assumptions and Dependencies

Bus VAT depends on invoice and journal datasets and on VAT reference datasets such as `vat-rates.csv`. Missing datasets or schemas result in deterministic diagnostics.

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

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

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
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
