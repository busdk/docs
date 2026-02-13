---
title: bus-bank — Software Design Document
description: Bus Bank imports bank statement evidence into schema-validated datasets, normalizes transactions, and provides review outputs that can be reconciled into…
---

## bus-bank

### Introduction and Overview

Bus Bank imports bank statement evidence into schema-validated datasets, normalizes transactions, and provides review outputs that can be reconciled into the journal.

### Requirements

FR-BNK-001 Bank import normalization. The module MUST import bank statement data into normalized datasets with deterministic ordering and stable identifiers. Acceptance criteria: imports create or update `bank-imports.csv` and `bank-transactions.csv` with schema validation.

FR-BNK-002 Review surface. The module MUST provide list outputs for review and reconciliation. Acceptance criteria: `bus bank list` emits deterministic transaction listings and fails with clear diagnostics on invalid filters.

FR-BNK-003 Init behavior. The module MUST provide an `init` command that creates the bank baseline datasets and schemas (`bank-imports.csv`, `bank-transactions.csv` and their schemas) when they are absent. When they already exist in full, `init` MUST print a warning to standard error and exit 0 without modifying anything. When they exist only partially, `init` MUST fail with a clear error and not write any file (see [bus-init](../sdd/bus-init) FR-INIT-004). Acceptance criteria: `bus bank init` is available; idempotent and partial-state behavior as specified.

NFR-BNK-001 Auditability. Imports MUST preserve source statement identifiers and evidence links. Acceptance criteria: each normalized transaction records a source reference and can be traced to attachments metadata.

### System Architecture

Bus Bank owns the bank import datasets and normalizes raw statement data into repository tables. It integrates with `bus reconcile` for matching and with `bus journal` for posting outcomes, using `bus accounts`, `bus entities`, and `bus invoices` as reference data.

### Key Decisions

KD-BNK-001 Bank statements are normalized into canonical datasets. The module converts raw statement data into schema-validated tables for deterministic downstream processing.

### Component Design and Interfaces

Interface IF-BNK-001 (module CLI). The module exposes `bus bank` with subcommands `init`, `import`, and `list` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline bank datasets and schemas (`bank-imports.csv`, `bank-transactions.csv` and their beside-the-table schemas) when they are absent. If all owned bank datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Documented parameters are `bus bank import --file <path>` and `bus bank list` filters that constrain the transaction set deterministically. The complete `list` filter surface is `--month <YYYY-M>`, `--from <YYYY-MM-DD>`, `--to <YYYY-MM-DD>`, `--counterparty <entity-id>`, and `--invoice-ref <text>`. Date filters apply to the normalized transaction date in `bank-transactions.csv`. `--month` selects the calendar month and is mutually exclusive with `--from` or `--to`. `--from` and `--to` may be used together or independently and are inclusive bounds. `--counterparty` filters by the stable counterparty identifier as recorded in the transaction row, matching `bus entities` identifiers exactly. `--invoice-ref` filters by the normalized invoice reference string present on the transaction row, matching exactly as stored. When multiple filters are supplied, they are combined with logical AND so every returned row satisfies every filter.

Usage examples:

```bash
bus bank import --file 202602-bank-statement.csv
bus bank list --month 2026-2
```

### Data Design

The module reads and writes `bank-imports.csv` and `bank-transactions.csv` at the repository root, each with a beside-the-table schema file. Master data owned by this module is stored in the workspace root only; the module does not create or use a `bank/` or other subdirectory for its datasets and schemas. Source bank statement files live in the repository root and may be named with a date prefix such as `202602-bank-statement.csv`, and they can be registered as attachments.

### Assumptions and Dependencies

Bus Bank depends on the workspace layout and schema conventions and on reference data from `bus entities`, `bus accounts`, and `bus invoices` when matching. If required datasets or schemas are missing, the module fails with deterministic diagnostics.

### Security Considerations

Bank statements and normalized transactions are sensitive repository data and should be protected by the same access controls as the rest of the workspace. Evidence references must remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Import and schema violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover normalization and schema validation, and command-level tests exercise `import` and `list` against fixture workspaces with sample bank statements.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly bank data handling.

### Glossary and Terminology

Bank import: a normalized record of a statement ingest run stored in `bank-imports.csv`.  
Bank transaction: a normalized transaction row stored in `bank-transactions.csv`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-reconcile">bus-reconcile</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Bank accounts](../master-data/bank-accounts/index)
- [Owns master data: Bank transactions](../master-data/bank-transactions/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [End user documentation: bus-bank CLI reference](../modules/bus-bank)
- [Repository](https://github.com/busdk/bus-bank)
- [Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)
- [CSV conventions](../data/csv-conventions)

### Document control

Title: bus-bank module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-BANK`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
