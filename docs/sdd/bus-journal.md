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

The module reads and writes the journal index `journals.csv` in the repository root and period journal files such as `2026/journals/2026-journal.csv`, with JSON Table Schemas stored beside each dataset.

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

### See also

End user documentation: [bus-journal CLI reference](../modules/bus-journal)  
Repository: https://github.com/busdk/bus-journal

For ledger structure and append-only expectations, see [Journal area](../layout/journal-area) and [Double-entry ledger](../design-goals/double-entry-ledger).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-pdf">bus-pdf</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-assets">bus-assets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-journal module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-JOURNAL`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
