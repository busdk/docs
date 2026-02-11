## bus-journal

### Introduction and Overview

Bus Journal maintains append-only journal entries as schema-validated repository data, enforces balanced transaction invariants, and serves as the authoritative ledger.

### Requirements

FR-JRN-001 Journal datasets. The module MUST store journal entries as append-only datasets with stable entry and transaction identifiers. Acceptance criteria: entries validate against schemas and maintain balance invariants.

FR-JRN-002 CLI surface for ledger postings. The module MUST provide commands to initialize, add entries, and compute balances. Acceptance criteria: `init`, `add`, and `balance` are available under `bus journal`.

NFR-JRN-001 Period integrity. The module MUST respect period close and lock boundaries. Acceptance criteria: postings that would break closed periods are rejected with deterministic diagnostics.

### System Architecture

Bus Journal owns the journal index and period journal datasets and accepts postings from other modules. It relies on account references from `bus accounts` and serves as the foundation for reporting and VAT computation.

### Key Decisions

KD-JRN-001 Append-only ledger. Journal corrections are expressed as new entries that reference prior records rather than overwriting them.

### Component Design and Interfaces

Interface IF-JRN-001 (module CLI). The module exposes `bus journal` with subcommands `init`, `add`, and `balance` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline journal index and schema (and any required structure for period journals) when they are absent. If the module’s owned journal data already exists in full and is consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially (e.g. journal index without schema or vice versa), `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Documented parameters for `bus journal add` are `--date <YYYY-MM-DD>`, `--desc <text>`, `--debit <account>=<amount>`, and `--credit <account>=<amount>`. Documented parameters for `bus journal balance` include `--as-of <YYYY-MM-DD>`.

Each `--debit` and `--credit` flag represents one journal line and uses the syntax `<account>=<amount>`, where `<account>` is the account name as stored in the accounts dataset and should be quoted when it contains spaces. The flags are repeatable, and multiple debit and credit lines may be provided in any order to form a single transaction. At least one debit and one credit line are required, and the module sums all debit amounts and all credit amounts and requires them to balance before it writes the entry.

Usage examples:

```bash
bus journal add --date 2026-01-10 --desc "Bought new laptop" --debit "Office Equipment"=2500 --credit "Cash"=2500
```

```bash
bus journal balance --as-of 2026-03-31
```

### Data Design

The module reads and writes the journal index `journals.csv` in the repository root and period journal files at the workspace root with a date prefix, for example `journal-2026.csv` (and its beside-the-table schema `journal-2026.schema.json`). The journal index, its schema, and all period journal files live in the workspace root only; the module does not create or use a subdirectory such as `2026/journals/` for journal data.

### Assumptions and Dependencies

Bus Journal depends on account references from `bus accounts` and on workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Journal data is repository data and should be protected by repository access controls. Voucher references and attachments must remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or balance violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover balance validation and posting logic, and command-level tests exercise `init`, `add`, and `balance` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic ledger data handling.

### Glossary and Terminology

Journal entry: a ledger posting row associated with a transaction and voucher.  
Transaction identifier: a stable identifier that groups journal entries for a posting.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [End user documentation: bus-journal CLI reference](../modules/bus-journal)
- [Repository](https://github.com/busdk/bus-journal)
- [Journal area](../layout/journal-area)
- [Double-entry ledger](../design-goals/double-entry-ledger)

### Document control

Title: bus-journal module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-JOURNAL`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
