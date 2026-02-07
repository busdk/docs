## bus-reconcile

### Introduction and Overview

Bus Reconcile links bank transactions to invoices or journal entries, records allocations for partials, splits, and fees, and stores reconciliation records as schema-validated repository data.

### Requirements

FR-REC-001 Reconciliation datasets. The module MUST store reconciliation records as schema-validated datasets with stable reconciliation identifiers. Acceptance criteria: reconciliations validate against schemas and preserve allocation history.

FR-REC-002 CLI surface for matching and allocation. The module MUST provide commands to match, allocate, and list reconciliations. Acceptance criteria: `match`, `allocate`, and `list` are available under `bus reconcile`.

NFR-REC-001 Auditability. Allocation history MUST be append-only and traceable to bank transactions, invoices, and vouchers. Acceptance criteria: allocation records are not overwritten and retain source references.

### System Architecture

Bus Reconcile owns reconciliation datasets and integrates bank and invoice data to record matching outcomes. It links to the journal for ledger traceability and updates invoice status references.

### Key Decisions

KD-REC-001 Reconciliation history is stored as repository data. Allocation changes are recorded as new rows to preserve the audit trail.

### Component Design and Interfaces

Interface IF-REC-001 (module CLI). The module exposes `bus reconcile` with subcommands `match`, `allocate`, and `list` and follows BusDK CLI conventions for deterministic output and diagnostics.

Documented parameters for `bus reconcile match` are `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. The command records a single reconciliation link between the specified bank transaction row from `bank-transactions.csv` and the target invoice header or journal transaction. Matching is deterministic and strict: the bank transaction amount and currency must equal the target amount as stored in the invoice header total or the journal transaction total, and the bank transaction must not already be reconciled. If these conditions are not met, the command exits non-zero and writes no reconciliation rows. Partial payments, splits, and fees are handled through `bus reconcile allocate` instead of `match`.

Documented parameters for `bus reconcile allocate` are `--bank-id <id>` plus one or more allocations expressed as repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>` flags. Allocation flags may appear in any order, and each allocation row references the stable invoice identifier or the stable journal transaction identifier as stored in their datasets. Allocation amounts are positive decimals expressed in the same currency as the bank transaction row, and the sum of all allocations must equal the bank transaction amount exactly. If any referenced record does not exist or the amounts do not sum exactly, the command exits non-zero and writes no reconciliation rows.

Usage examples:

```bash
bus reconcile match
bus reconcile allocate --bank-id BANK-001 --invoice INV-1001=900 --journal JRN-2026-014=40 --journal JRN-2026-015=300
bus reconcile list
```

### Data Design

The module reads and writes reconciliation datasets in the reconciliation area, with JSON Table Schemas stored beside each CSV dataset. It consumes bank transactions and invoice references as inputs.

### Assumptions and Dependencies

Bus Reconcile depends on `bus bank` transaction data, `bus invoices` references, and the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Reconciliation data is repository data and should be protected by repository access controls. Evidence references remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover matching and allocation logic, and command-level tests exercise `match`, `allocate`, and `list` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic reconciliation data handling.

### Glossary and Terminology

Reconciliation record: a dataset row linking a bank transaction to an invoice or journal entry.  
Allocation history: append-only records detailing partials, splits, and fees.

### See also

End user documentation: [bus-reconcile CLI reference](../modules/bus-reconcile)  
Repository: https://github.com/busdk/bus-reconcile

For reconciliation workflow context, see [Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment) and [Accounting workflow overview](../workflow/accounting-workflow-overview).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bank">bus-bank</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./modules">Modules (SDD)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-budget">bus-budget</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-reconcile module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-RECONCILE`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Defined deterministic parameter sets for `match` and `allocate`. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
