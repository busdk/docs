---
title: bus-reconcile — bank reconciliation and allocation records (SDD)
description: Bus Reconcile links bank transactions to invoices or journal entries, records allocations for partials, splits, and fees, and stores reconciliation records…
---

## bus-reconcile — bank reconciliation and allocation records

### Introduction and Overview

Bus Reconcile links bank transactions to invoices or journal entries, records allocations for partials, splits, and fees, and stores reconciliation records as schema-validated repository data. The deterministic two-phase reconciliation workflow (proposal generation then batch apply) is implemented: `bus reconcile propose` and `bus reconcile apply` provide the flow, with `--dry-run` and idempotent re-apply; `match`, `allocate`, and `list` remain for one-off use.

### Requirements

FR-REC-001 Reconciliation datasets. The module MUST store reconciliation records as schema-validated datasets with stable reconciliation identifiers. Acceptance criteria: reconciliations validate against schemas and preserve allocation history.

FR-REC-002 CLI surface for matching and allocation. The module MUST provide commands to match, allocate, and list reconciliations. Acceptance criteria: `match`, `allocate`, and `list` are available under `bus reconcile`.

FR-REC-003 Deterministic reconciliation proposal generation. The module MUST provide a command that generates reconciliation proposal rows from bank and invoice/journal datasets using deterministic rules and constraints. Acceptance criteria: the command writes a deterministic proposal dataset or report that includes candidate target, confidence score, and explicit reasons; rules include at least reference matching, amount equality, and uniqueness constraints; repeated runs with the same inputs yield byte-identical output.

FR-REC-004 Batch apply of approved proposals. The module MUST provide a command that consumes approved proposal rows and records reconciliation matches or allocations deterministically. Acceptance criteria: apply consumes explicit proposal row identifiers, writes canonical reconciliation records through module-owned paths, supports `--dry-run`, and refuses ambiguous or invalid proposal rows without partial writes.

FR-REC-005 Reconciliation coverage output contract. The module MUST expose deterministic reconciliation coverage fields that parity and gap checks can consume. Acceptance criteria: proposal and apply outputs include stable identifiers and statuses for matched, allocated, skipped, and rejected rows; period and target references are explicit so [bus-validate](./bus-validate) and [bus-reports](./bus-reports) can compute deterministic migration-quality checks.

FR-REC-006 Deterministic reconciliation dataset bootstrap. The module MUST provide `bus reconcile init` to ensure `matches.csv` and `matches.schema.json` exist with deterministic default content. Acceptance criteria: command is idempotent, supports force rewrite semantics, and emits machine-readable status rows (`path`, `status`) for CI and replay scripts.

NFR-REC-001 Auditability. Allocation history MUST be append-only and traceable to bank transactions, invoices, and vouchers. Acceptance criteria: allocation records are not overwritten and retain source references.

NFR-REC-002 Idempotent re-apply semantics. Reconciliation apply operations MUST be idempotent when the same approved proposal set is applied repeatedly. Acceptance criteria: re-running apply against already-applied proposal rows yields deterministic "already applied" outcomes and does not create duplicate reconciliation records.

NFR-REC-003 Proposal artifact auditability. Proposal generation and apply MUST emit reviewable artifacts that explain decisions. Acceptance criteria: proposal outputs include deterministic confidence and reason fields; apply outputs include per-row status (applied, skipped, rejected) with deterministic diagnostics referencing proposal row identifiers.

NFR-REC-004 Deterministic downstream-consumption semantics. Proposal and apply artifacts MUST be stable for downstream parity and gap checks. Acceptance criteria: field names, status vocabulary, and period references are versioned and deterministic across runs for the same inputs.

### System Architecture

Bus Reconcile owns reconciliation datasets and integrates bank and invoice data to record matching outcomes. It links to the journal for ledger traceability and updates invoice status references.

### Key Decisions

KD-REC-001 Reconciliation history is stored as repository data. Allocation changes are recorded as new rows to preserve the audit trail.

KD-REC-002 Reconciliation is a two-phase workflow. Candidate generation and decision review are separated from write operations. The apply phase consumes explicit approved rows only, which keeps reconciliation deterministic, reviewable, and script-friendly.

KD-REC-003 Reconciliation outputs feed migration controls. Proposal and apply artifacts are designed so migration parity and gap checks can consume them directly without repository-specific script glue.

### Component Design and Interfaces

Interface IF-REC-001 (module CLI). The module exposes `bus reconcile` with subcommands `init`, `match`, `allocate`, `list`, `propose`, and `apply` and follows BusDK CLI conventions for deterministic output and diagnostics.

Documented parameters for `bus reconcile init` are optional `--if-missing` and optional `--force`. The command ensures `matches.csv` and `matches.schema.json` exist at workspace root with deterministic default schema and header. The command prints deterministic status output (`path`, `status`) where status values are one of `created`, `unchanged`, or `updated`. Existing files are preserved by default; `--force` rewrites both files using canonical defaults.

Documented parameters for `bus reconcile match` are `--bank-id <id>` and exactly one of `--invoice-id <id>` or `--journal-id <id>`. The command records a single reconciliation link between the specified bank transaction row from `bank-transactions.csv` and the target invoice header or journal transaction. Matching is deterministic and strict: the bank transaction amount and currency must equal the target amount as stored in the invoice header total or the journal transaction total, and the bank transaction must not already be reconciled. If these conditions are not met, the command exits non-zero and writes no reconciliation rows. Partial payments, splits, and fees are handled through `bus reconcile allocate` instead of `match`.

Documented parameters for `bus reconcile allocate` are `--bank-id <id>` plus one or more allocations expressed as repeatable `--invoice <id>=<amount>` and `--journal <id>=<amount>` flags. Allocation flags may appear in any order, and each allocation row references the stable invoice identifier or the stable journal transaction identifier as stored in their datasets. Allocation amounts are positive decimals expressed in the same currency as the bank transaction row, and the sum of all allocations must equal the bank transaction amount exactly. If any referenced record does not exist or the amounts do not sum exactly, the command exits non-zero and writes no reconciliation rows.

Interface IF-REC-002 (proposal generation). The command surface is `bus reconcile propose --out <path>|-` with optional deterministic selectors such as date range, period, and target scope. The command reads unreconciled bank rows and eligible invoice or journal targets, computes deterministic candidate rows, and writes a proposal dataset or report. Each proposal row includes stable proposal ID, bank transaction ID, proposed target kind and target ID, proposed amount, confidence score, and reason codes. Proposal output ordering is deterministic and stable across machines.

Interface IF-REC-003 (batch apply). The command surface is `bus reconcile apply --in <path>|-` with optional row selection and `--dry-run`. The command consumes approved proposal rows and applies each row as either a one-to-one match or an allocation write, depending on the proposal shape. Apply is deterministic, idempotent, and fail-safe: invalid rows are rejected with deterministic diagnostics and no partial writes for the rejected row; already-applied rows are reported as skipped.

Interface IF-REC-004 (coverage artifact contract). Proposal and apply outputs expose a deterministic row contract including at minimum proposal ID, bank transaction ID, target kind, target ID, period key, amount, confidence, reason codes, and apply status. This contract is consumed by [bus-validate](./bus-validate) parity or gap checks and [bus-reports](./bus-reports) coverage reports.

Optional CI-friendly behavior (suggested extension). Scripts that need to fail on backlog or incomplete apply currently rely on parsing proposal or apply output. An optional extension is thresholds or strict exit codes for "no proposals" vs "partial apply" so CI can fail without custom output parsing. If adopted, the SDD may add an optional exit-code contract and module docs will document exit codes and optional CI flags.

Use of extracted reference keys in reconciliation (suggested extension, depends on [bus-bank](./bus-bank) reference extractors). Not implemented: propose and match use amount and reference only; there is no first-class use of bank-side extracted keys. When [bus-bank](./bus-bank) exposes normalized reference fields (e.g. `erp_id`, `invoice_number_hint`) from its reference extractors, this module would use them in propose and match when joining to invoice or purchase-invoice ids. Expected field names and matching semantics would be documented; amount and currency checks would be retained; an optional "match by extracted key" path would improve match quality and reduce manual pairing. If this capability is adopted, the SDD will extend the reconcile input contract (expected bank fields and match semantics), and module docs will document field names and match-by-key behavior.

Usage examples:

```bash
bus reconcile match --bank-id BANK-001 --invoice-id INV-1001
bus reconcile init
bus reconcile propose --out reconcile-proposals.tsv
bus reconcile apply --in reconcile-proposals-approved.tsv --dry-run
bus reconcile allocate --bank-id BANK-001 --invoice INV-1001=900 --journal JRN-2026-014=40 --journal JRN-2026-015=300
bus reconcile list
```

### Data Design

The module reads and writes reconciliation datasets in the reconciliation area, with JSON Table Schemas stored beside each CSV dataset. Master data owned by this module is stored in the workspace root only; the module does not create or use a `reconcile/` or other subdirectory for its datasets and schemas. It consumes bank transactions and invoice references as inputs.

Proposal generation writes deterministic proposal artifacts as repository data, typically in a dedicated import or reconciliation artifact path. The canonical reconciliation datasets remain the source of truth; proposal files are review artifacts used as explicit apply inputs.

### Assumptions and Dependencies

Bus Reconcile depends on `bus bank` transaction data, `bus invoices` references, and the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics. The proposal workflow depends on stable bank transaction identifiers and deterministic invoice/journal target read surfaces from owning modules. Migration parity and gap workflows depend on this module’s deterministic proposal and apply output contract.

### Security Considerations

Reconciliation data is repository data and should be protected by repository access controls. Evidence references remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover matching and allocation logic, and command-level tests exercise `match`, `allocate`, and `list` against fixture workspaces. Proposal and apply tests MUST verify deterministic candidate output, confidence and reason field stability, exact-match and uniqueness constraints, dry-run behavior, and idempotent re-apply semantics for approved proposal rows. Coverage-contract tests MUST verify stable status vocabulary and period references for downstream parity and gap checks.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

The two-phase flow is implemented: `bus reconcile propose` and `bus reconcile apply` (with `--dry-run` and idempotent re-apply) provide deterministic candidate generation and batch apply. Script-based candidate planning (e.g. `exports/2024/025-reconcile-sales-candidates-2024.sh`) remains an alternative where teams prefer it.

Re-test in 2026-02 indicates that the former bank-ID lookup defect is resolved when a valid `matches` dataset exists; the prior “bank transaction … not found” failure did not reproduce in that configuration. An optional CI-friendly extension is not yet specified: thresholds or strict exit codes for "no proposals" vs "partial apply" would allow scripts to fail on backlog or incomplete apply without custom output parsing; when adopted, the exit-code contract and optional CI flags will be documented in the SDD and module reference.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic reconciliation data handling.

### Glossary and Terminology

Reconciliation record: a dataset row linking a bank transaction to an invoice or journal entry.  
Allocation history: append-only records detailing partials, splits, and fees.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bank">bus-bank</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-assets">bus-assets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Bank transactions](../master-data/bank-transactions/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [End user documentation: bus-reconcile CLI reference](../modules/bus-reconcile)
- [Repository](https://github.com/busdk/bus-reconcile)
- [Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment)
- [Workflow: Deterministic reconciliation proposals and batch apply](../workflow/deterministic-reconciliation-proposals-and-batch-apply)
- [bus-validate module SDD](./bus-validate)
- [bus-reports module SDD](./bus-reports)
- [Workflow: Source import parity and journal gap checks](../workflow/source-import-parity-and-journal-gap-checks)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)

### Document control

Title: bus-reconcile module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-RECONCILE`  
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
