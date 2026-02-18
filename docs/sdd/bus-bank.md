---
title: bus-bank — bank statement import and reconciliation-ready data (SDD)
description: Bus Bank imports bank statement evidence into schema-validated datasets, normalizes transactions, and provides review outputs that can be reconciled into…
---

## bus-bank — bank statement import and reconciliation-ready data

### Introduction and Overview

Bus Bank imports bank statement evidence into schema-validated datasets, normalizes transactions, and provides review outputs that can be reconciled into the journal. This SDD also defines a profile-driven ERP bank import contract so historical bank data can be imported through reusable mapping profiles instead of generated one-off scripts; that contract is currently specified but not yet implemented as a first-class workflow.

### Requirements

FR-BNK-001 Bank import normalization. The module MUST import bank statement data into normalized datasets with deterministic ordering and stable identifiers. Acceptance criteria: imports create or update `bank-imports.csv` and `bank-transactions.csv` with schema validation.

FR-BNK-002 Review surface. The module MUST provide list outputs for review and reconciliation. Acceptance criteria: `bus bank list` emits deterministic transaction listings and fails with clear diagnostics on invalid filters.

FR-BNK-003 Init behavior. The module MUST provide an `init` command that creates the bank baseline datasets and schemas (`bank-imports.csv`, `bank-transactions.csv` and their schemas) when they are absent. When they already exist in full, `init` MUST print a warning to standard error and exit 0 without modifying anything. When they exist only partially, `init` MUST fail with a clear error and not write any file (see [bus-init](../sdd/bus-init) FR-INIT-004). Acceptance criteria: `bus bank init` is available; idempotent and partial-state behavior as specified.

FR-BNK-004 Profile-driven ERP bank import. The module MUST provide a first-class import workflow that maps ERP bank-export tables into canonical bank datasets using an explicit, versioned mapping profile. Acceptance criteria: import runs from a short command invocation that references a profile and source dataset(s), supports deterministic row selection (for example fiscal-year filters), status and direction normalization, counterparty and reference mapping, and appends canonical bank rows in deterministic order.

FR-BNK-005 Reconciliation proposal input contract. The module MUST expose deterministic transaction fields needed by reconciliation proposal generation and batch apply workflows in [bus-reconcile](./bus-reconcile). Acceptance criteria: bank transaction identifiers, normalized amount, currency, booking date, and reference fields are stable and queryable; unresolved lookup states are explicit in data and diagnostics so proposal generation can fail deterministically instead of guessing.

NFR-BNK-001 Auditability. Imports MUST preserve source statement identifiers and evidence links. Acceptance criteria: each normalized transaction records a source reference and can be traced to attachments metadata.

NFR-BNK-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (bank-imports, bank-transactions, and their schemas). Other modules that need read-only access to bank raw file(s) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration can be supported without breaking consumers. Acceptance criteria: the library provides path accessor(s) for the bank datasets; consumers use these accessors for read-only access; no consumer hardcodes bank file names outside this module.

NFR-BNK-003 Import mapping auditability. ERP bank import mappings MUST be reviewable as repository data and import execution MUST emit auditable artifacts. Acceptance criteria: profile files are committed as regular repository files; imports can emit deterministic plan and result artifacts that include source rows, mapping decisions, and produced bank transaction identifiers; rerunning with the same profile and source data yields byte-identical artifacts.

NFR-BNK-004 Deterministic candidate feed semantics. Data consumed by reconciliation proposal generation MUST be deterministic and unambiguous for a given workspace revision. Acceptance criteria: `bus bank` read outputs used for proposal workflows are stable in ordering and field naming, and diagnostics identify the bank transaction ID when lookup or normalization failures prevent reconciliation planning.

### System Architecture

Bus Bank owns the bank import datasets and normalizes raw statement data into repository tables. It integrates with `bus reconcile` for matching and with `bus journal` for posting outcomes, using `bus accounts`, `bus entities`, and `bus invoices` as reference data.

### Key Decisions

KD-BNK-001 Bank statements are normalized into canonical datasets. The module converts raw statement data into schema-validated tables for deterministic downstream processing.

KD-BNK-002 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of bank datasets for read-only access. Write access and all bank business logic remain in this module.

KD-BNK-003 ERP history import is profile-driven. Historical bank ingestion is defined as reusable mapping profiles and deterministic import runs, not generated one-off append scripts. Profiles are versioned repository data and import execution remains plain Bus commands with deterministic output artifacts.

KD-BNK-004 Reconciliation proposal workflows consume bank data as-is. Candidate generation and apply logic belong to [bus-reconcile](./bus-reconcile), while bus-bank guarantees deterministic transaction identity and normalization surfaces.

### Component Design and Interfaces

Interface IF-BNK-001 (module CLI). The module exposes `bus bank` with subcommands `init`, `import`, and `list` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline bank datasets and schemas (`bank-imports.csv`, `bank-transactions.csv` and their beside-the-table schemas) when they are absent. If all owned bank datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Interface IF-BNK-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to its owned data file(s) (bank-imports.csv, bank-transactions.csv, and their schemas). Given a workspace root path, the library returns the path(s); resolution MUST allow future override from workspace or data package configuration. Other modules use these accessors for read-only access only; all writes and bank logic remain in this module.

Documented parameters are `bus bank import --file <path>` and `bus bank list` filters that constrain the transaction set deterministically. The complete `list` filter surface is `--month <YYYY-M>`, `--from <YYYY-MM-DD>`, `--to <YYYY-MM-DD>`, `--counterparty <entity-id>`, and `--invoice-ref <text>`. Date filters apply to the normalized transaction date in `bank-transactions.csv`. `--month` selects the calendar month and is mutually exclusive with `--from` or `--to`. `--from` and `--to` may be used together or independently and are inclusive bounds. `--counterparty` filters by the stable counterparty identifier as recorded in the transaction row, matching `bus entities` identifiers exactly. `--invoice-ref` filters by the normalized invoice reference string present on the transaction row, matching exactly as stored. When multiple filters are supplied, they are combined with logical AND so every returned row satisfies every filter.

Interface IF-BNK-003 (profile import, planned). The module defines a first-class command surface for ERP history import into bank datasets: `bus bank import --profile <path> --source <path>` with optional deterministic selectors (for example `--year <YYYY>`) and dry-run support. The profile contract defines source table bindings, column mappings, transaction-direction normalization, status mapping, counterparty lookup, and reference extraction rules. Execution emits deterministic import artifacts (plan and result) and appends canonical rows through module-owned write paths. This interface is specified for implementation and is not yet shipped in current module releases.

Interface IF-BNK-004 (reconciliation candidate read surface, planned integration). Bank transaction read outputs consumed by reconciliation proposal workflows MUST provide a deterministic field contract, including at minimum bank transaction ID, amount, currency, booking date, reference text, and reconciliation state marker. The module does not generate proposals, but its read contract must let [bus-reconcile](./bus-reconcile) compute proposals and apply approved rows deterministically.

Usage examples:

```bash
bus bank import --file 202602-bank-statement.csv
bus bank list --month 2026-2
```

### Data Design

The module reads and writes `bank-imports.csv` and `bank-transactions.csv` at the repository root, each with a beside-the-table schema file. Master data owned by this module is stored in the workspace root only; the module does not create or use a `bank/` or other subdirectory for its datasets and schemas. Source bank statement files live in the repository root and may be named with a date prefix such as `202602-bank-statement.csv`, and they can be registered as attachments.

Other modules that need read-only access to bank datasets MUST obtain the path(s) from this module’s Go library (IF-BNK-002). All writes and bank-domain logic remain in this module.

Profile mappings for ERP bank imports are authoritative repository data. A profile describes how source bank-export rows map into `bank-imports.csv` and `bank-transactions.csv`, including deterministic filter predicates, normalization rules, and counterparty/reference resolution. Import execution artifacts are stored as reviewable files so reviewers can verify source-to-target behavior without reviewing generated mega-scripts.

### Assumptions and Dependencies

Bus Bank depends on the workspace layout and schema conventions and on reference data from `bus entities`, `bus accounts`, and `bus invoices` when matching. If required datasets or schemas are missing, the module fails with deterministic diagnostics. The profile import workflow depends on deterministic source-table read and normalization helpers from [bus-data](./bus-data), but bank ownership and all write logic remain in this module. Reconciliation proposal and apply workflows depend on this module’s deterministic bank transaction identity and normalization contract.

### Security Considerations

Bank statements and normalized transactions are sensitive repository data and should be protected by the same access controls as the rest of the workspace. Evidence references must remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Import and schema violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover normalization and schema validation, and command-level tests exercise `import` and `list` against fixture workspaces with sample bank statements. Profile-import tests MUST verify deterministic mapping execution, year-filter behavior, direction and status normalization, counterparty lookup outcomes, and byte-identical import artifacts for repeated runs with the same inputs (FR-BNK-004, NFR-BNK-003). Reconciliation-candidate contract tests MUST verify stable transaction ID lookup, deterministic read ordering, and deterministic diagnostics when candidate-required fields are missing or invalid (FR-BNK-005, NFR-BNK-004).

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly bank data handling.

### Suggested capabilities (out of current scope)

The following capabilities are not yet requirements; they are recorded as suggested enhancements for classification, reconciliation, and migration workflows.

**Counterparty normalization.** Classification rules become noisy when the same logical counterparty appears with inconsistent labels (e.g. SENDANOR vs Sendanor, UPCLOUD HELSINKI vs UPCLOUD OY HELSINKI). A suggested extension is configurable counterparty normalization before rule matching. Configuration would define canonical names with alias patterns (exact match and regex), and optional normalization helpers (trim, case fold, Unicode fold, punctuation cleanup). The module would expose a normalized counterparty field in bank datasets and in exports consumed by [bus-journal](./bus-journal) and [bus-reconcile](./bus-reconcile), while retaining the original counterparty value for audit. Rule matching in other modules would then key off the canonical value. If this capability is adopted, it would be promoted to a formal requirement and to interface and data design (config format, new fields, and export contract) in a future SDD update; module and workflow docs would then document the config format and the normalized vs original field semantics.

**Built-in bank-classification coverage/backlog report.** After partial automation, teams need a deterministic “what remains unclassified” view. A suggested command or report would compare bank transactions to journal source links and emit posted vs unposted counts/sums by month, unposted breakdown by counterparty and message code, optional thresholds/fail-on-backlog for CI, and machine-friendly output (tsv/json) with consistent source-link semantics.

**Reference extractors from bank message/reference.** Bank rows often include embedded hints in free-text message or reference fields (e.g. `ERP <id>`, invoice numbers). Today such hints are parsed manually in custom scripts. A suggested extension is optional reference extractors in bus-bank: configurable patterns (e.g. regex) on message/reference that populate normalized fields (e.g. `erp_id`, `invoice_number_hint`) in bank datasets. Those fields would be exposed in bank list and export so [bus-reconcile](./bus-reconcile) and other modules can use them without parsing raw text. Optional helper commands could join extracted keys against invoice or purchase-invoice ids deterministically. If this capability is adopted, it would be promoted to a formal requirement and to interface and data design (extractor config, new dataset fields, and export contract) in a future SDD update; module docs would then document the extractor config and the new dataset fields.

**Rule-based bank classification and posting.** See the same suggested two-phase flow (classify + apply) under [bus-journal](./bus-journal); bus-bank would supply the bank transaction read surface and, if implemented, counterparty normalization and reference extractors (above) used by the classifier.

### Glossary and Terminology

Bank import: a normalized record of a statement ingest run stored in `bank-imports.csv`.  
Bank transaction: a normalized transaction row stored in `bank-transactions.csv`.

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
- [Workflow: Import ERP history into invoices and bank datasets](../workflow/import-erp-history-into-canonical-datasets)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)

### Document control

Title: bus-bank module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-BANK`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
