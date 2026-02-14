---
title: bus-reports — financial reports from journal and reference data (SDD)
description: Bus Reports computes financial reports from journal entries and reference data, verifies integrity and balances, and emits deterministic report outputs.
---

## bus-reports — financial reports from journal and reference data

### Introduction and Overview

Bus Reports computes financial reports from journal entries and reference data, verifies integrity and balances, and emits deterministic report outputs.

### Requirements

FR-REP-001 Report outputs. The module MUST generate trial balance, general ledger, profit and loss, and balance sheet outputs. Acceptance criteria: each report command emits deterministic outputs with stable ordering.

FR-REP-002 Integrity checks. The module MUST verify ledger integrity before emitting reports. Acceptance criteria: integrity failures are reported with deterministic diagnostics and non-zero exit codes.

NFR-REP-001 Auditability. Report outputs MUST be fully derivable from repository data and traceable to postings and vouchers. Acceptance criteria: report outputs reference stable identifiers or are reproducible from the same datasets.

### System Architecture

Bus Reports reads journal and account datasets and optionally budget datasets to compute reports. It produces report outputs used for filing and management reporting.

### Key Decisions

KD-REP-001 Reports are derived outputs. Reports are computed from canonical datasets and do not modify them.

### Component Design and Interfaces

Interface IF-REP-001 (module CLI). The module exposes `bus reports` with subcommands `trial-balance`, `general-ledger`, `profit-and-loss`, and `balance-sheet` and follows BusDK CLI conventions for deterministic output and diagnostics.

Report scoping is explicit and deterministic. `trial-balance` and `balance-sheet` require `--as-of <YYYY-MM-DD>` and include postings on or before the as-of date. `general-ledger` and `profit-and-loss` require `--period <period>` using the same period identifier form as `bus period` and `bus vat`. `general-ledger` accepts an optional `--account <account-id>` to emit a single-account ledger; when omitted it emits all accounts in deterministic order.

All report commands accept `--format <format>` with supported values `text` and `csv`. The default is `text`, which emits a plain, non-aligned table with a stable column order and a literal `|` separator so output does not vary by terminal width. The `csv` format emits UTF-8 CSV with a header row and the same deterministic row ordering as the text output.

Usage example:

```bash
bus reports trial-balance --as-of 2026-03-31 --format csv
bus reports profit-and-loss --period 2026Q1
```

### Data Design

The module reads journal data from `bus journal`, accounts from `bus accounts`, and optional budgets from `bus budget`, all as schema-validated datasets.

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

Trial balance: a report summarizing balances by account.  
General ledger: a report listing detailed postings by account.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-reports CLI reference](../modules/bus-reports)
- [Repository](https://github.com/busdk/bus-reports)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Append-only and soft deletion](../data/append-only-and-soft-deletion)

### Document control

Title: bus-reports module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-REPORTS`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
