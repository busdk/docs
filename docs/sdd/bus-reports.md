---
title: bus-reports — financial reports from journal and reference data (SDD)
description: Bus Reports computes financial reports from journal entries and reference data, supports configurable TASE and tuloslaskelma layouts for line-by-line match to a given source, and emits deterministic report outputs.
---

## bus-reports — financial reports from journal and reference data

### Introduction and Overview

Bus Reports computes financial reports from journal entries and reference data, verifies integrity and balances, and emits deterministic report outputs. For balance sheet (TASE) and income statement (tuloslaskelma), the module supports configurable report layouts so that outputs can match a given source structure — for example the full Finnish line hierarchy (Pysyvät vastaavat, Vaihtuvat vastaavat, Oma pääoma, LIIKEVAIHTO, LIIKEVOITTO, Korkokulut, and related lines) for line-by-line comparison or filing.

### Requirements

FR-REP-001 Report outputs. The module MUST generate trial balance, general ledger, profit and loss, and balance sheet outputs. Acceptance criteria: each report command emits deterministic outputs with stable ordering.

FR-REP-002 Integrity checks. The module MUST verify ledger integrity before emitting reports. Acceptance criteria: integrity failures are reported with deterministic diagnostics and non-zero exit codes.

NFR-REP-001 Auditability. Report outputs MUST be fully derivable from repository data and traceable to postings and vouchers. Acceptance criteria: report outputs reference stable identifiers or are reproducible from the same datasets.

FR-REP-003 Regulated report PDFs. The toolchain MUST support producing the balance sheet (TASE) and the income statement (tuloslaskelma) as PDF suitable for Finnish regulated reporting (archiving, auditors, authorities). Acceptance criteria: users can obtain compliant TASE and tuloslaskelma PDFs from workspace data via the CLI without relying on external conversion tools. This requirement is satisfied by `--format pdf` in `bus reports balance-sheet` and `bus reports profit-and-loss`; see [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs).

FR-REP-004 Configurable report layout (TASE / tuloslaskelma). The module MUST support selecting or defining a report layout that specifies the report-line hierarchy, labels (e.g. Finnish), and account→line mapping so that balance-sheet and profit-and-loss outputs can match a given source structure line-by-line (e.g. for comparison or filing). Acceptance criteria: (1) a report layout is expressible as a schema (report-line tree, account→line mapping, label set); (2) users can select a built-in layout (e.g. Finnish full) or supply a layout file; (3) `bus reports balance-sheet` and `bus reports profit-and-loss` emit the same line structure and labels as the selected layout in text, CSV, JSON, KPA/PMA, and PDF formats.

### System Architecture

Bus Reports reads journal and account datasets and optionally budget datasets to compute reports. It produces report outputs used for filing and management reporting.

### Key Decisions

KD-REP-001 Reports are derived outputs. Reports are computed from canonical datasets and do not modify them.

KD-REP-002 Report layout drives line structure and labels. Balance-sheet and profit-and-loss line hierarchy, labels (e.g. Finnish), and account aggregation are defined by a selected report layout (built-in or custom), not hardcoded per format. This allows outputs to match a given source structure (e.g. original 2023 TASE/tuloslaskelma) for line-by-line comparison or filing (FR-REP-004).

### Component Design and Interfaces

Interface IF-REP-001 (module CLI). The module exposes `bus reports` with subcommands `trial-balance`, `general-ledger`, `profit-and-loss`, and `balance-sheet` and follows BusDK CLI conventions for deterministic output and diagnostics.

Report scoping is explicit and deterministic. `trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>` and include postings on or before the as-of date. `general-ledger` and `profit-and-loss` require `--period <period>` using the same period identifier form as `bus period` and `bus vat`. `general-ledger` accepts an optional `--account <account-id>` to emit a single-account ledger; when omitted it emits all accounts in deterministic order.

All report commands accept `--format <format>` with supported values `text`, `csv`, and `markdown`. For balance-sheet and profit-and-loss, `json`, `kpa`, `pma`, and `pdf` are also supported. Extended layout formats (e.g. `kpa-full`, `pma-full`) or a layout file reference may be supported to select a report layout that defines the full line hierarchy and Finnish labels (FR-REP-004); when a layout is selected, the same line structure applies to text, CSV, JSON, KPA/PMA, and PDF. The default is `text`, which emits a plain, non-aligned table with a stable column order and a literal `|` separator so output does not vary by terminal width. The `csv` format emits UTF-8 CSV with a header row and the same deterministic row ordering as the text output. The `markdown` format emits a Markdown table (header row and `|`-separated columns) with the same row ordering, suitable for documentation or further processing. The `pdf` format writes a PDF suitable for Finnish regulated reporting (TASE and tuloslaskelma) to the path given by `-o` (FR-REP-003); see [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs).

Report layout (FR-REP-004). A report layout defines the report-line tree (hierarchy), the label set (e.g. Finnish line names such as Pysyvät vastaavat, Vaihtuvat vastaavat, Oma pääoma, LIIKEVAIHTO, LIIKEVOITTO, Korkokulut), and the mapping from account codes or account types to report lines. The module may provide built-in layouts (e.g. a compact KPA/PMA variant and a “Finnish full” variant matching a given source structure) and may accept an optional `--layout <file>` or layout identifier so that custom report templates can define the line tree and account→line mapping; Bus fills amounts and emits outputs in the chosen format (CSV, JSON, PDF) with that structure. Adding or selecting a layout is documented so that outputs can be made identical to a given source for comparison or filing.

Usage example:

```bash
bus reports trial-balance --as-of 2026-03-31 --format csv
bus reports profit-and-loss --period 2026Q1
```

### Data Design

The module reads journal data from `bus journal`, accounts from `bus accounts`, and optional budgets from `bus budget`, all as schema-validated datasets.

Report layout schema (FR-REP-004). A report layout is a structured definition that drives balance-sheet and profit-and-loss line structure and labels. It comprises: (1) **Report-line schema** — an ordered tree of report lines, each with a stable identifier, optional parent, and display label (e.g. Finnish). (2) **Account→line mapping** — rules that map account codes or account types from the chart of accounts to one or more report lines so that balances are aggregated into the correct line. (3) **Label set** — the set of human-readable labels (e.g. Finnish) used for each report line in text, CSV, and PDF output. Layouts may be built-in (e.g. compact KPA/PMA with few section totals, or “Finnish full” with the full hierarchy matching a given source) or supplied as a layout file (e.g. YAML or JSON). The exact file format and schema for custom layout files are defined by the module so that implementers and users can add or select a layout to produce outputs that match a given source structure line-by-line.

### Assumptions and Dependencies

Bus Reports depends on valid journal and account datasets and on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Report outputs may contain sensitive financial data and should be protected by repository access controls. Derived outputs must not alter canonical datasets.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Integrity failures exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover report calculations and integrity checks, and command-level tests exercise each report command against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Report schema changes are handled by updating the module and documenting new output expectations.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic report outputs.

### Glossary and Terminology

**Account→line mapping:** Rules that assign account codes or account types from the chart of accounts to specific report lines so that balances are aggregated into the correct line in balance-sheet or profit-and-loss output.

**General ledger:** A report listing detailed postings by account.

**Report layout:** A definition of the report-line tree (hierarchy), label set (e.g. Finnish line names), and account→line mapping used to produce balance-sheet or profit-and-loss output. Layouts may be built-in or supplied via a layout file.

**Report line:** A single row in a balance-sheet or profit-and-loss report, identified by a stable id and optional parent, with a display label and aggregated amount(s).

**TASE:** Tasapainolaskelma; the Finnish balance sheet. Required for regulated reporting and archiving.

**Trial balance:** A report summarizing balances by account.

**Tuloslaskelma:** The Finnish income statement (profit and loss). Required for regulated reporting and archiving.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-replay">bus-replay</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-reports CLI reference](../modules/bus-reports)
- [Repository](https://github.com/busdk/bus-reports)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Append-only and soft deletion](../data/append-only-and-soft-deletion)
- [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)

### Document control

Title: bus-reports module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-REPORTS`  
Version: 2026-02-17  
Status: Draft  
Last updated: 2026-02-17  
Owner: BusDK development team  
