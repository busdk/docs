---
title: bus-journal — authoritative ledger and balanced postings (SDD)
description: Bus Journal maintains append-only journal entries as schema-validated repository data, enforces balanced transaction invariants, and serves as the…
---

## bus-journal — authoritative ledger and balanced postings

### Introduction and Overview

Bus Journal maintains append-only journal entries as schema-validated repository data, enforces balanced transaction invariants, and serves as the authoritative ledger.

### Requirements

FR-JRN-001 Journal datasets. The module MUST store journal entries as append-only datasets with stable entry and transaction identifiers. “Schema-validated repository data” includes consuming upstream schema-valid master data (e.g. the chart of accounts) without rejecting valid schemas. Acceptance criteria: entries validate against schemas and maintain balance invariants.

FR-JRN-002 CLI surface for ledger postings. The module MUST provide commands to initialize, add entries, and compute balances. Acceptance criteria: `init`, `add`, and `balance` are available under `bus journal`.

NFR-JRN-001 Period integrity. The module MUST respect period close and lock boundaries. Acceptance criteria: postings that would break closed periods are rejected with deterministic diagnostics.

NFR-JRN-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (journal index and period journal files, and their schemas). Other modules that need read-only access to journal data (e.g. to compute balances in another workspace) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration can be supported without breaking consumers. Acceptance criteria: the library provides path accessor(s) for the journal index and for resolving period journal paths; consumers use these accessors for read-only access; no consumer hardcodes journal file names outside this module.

NFR-JRN-003 Cross-module access via Go libraries only. The module MUST implement all dependencies on other BusDK modules (including [bus-accounts](./bus-accounts), [bus-period](./bus-period), and any other modules whose data it reads) through those modules' Go library APIs. It MUST obtain the workspace-relative path(s) to the chart of accounts, period control dataset, and any other module-owned CSV or schema files from the owning module's library path accessors; it MUST NOT hardcode file names such as `accounts.csv` or `periods.csv`. Account validation (e.g. for `add` and `balance`) and period boundary checks (e.g. for NFR-JRN-001) MUST use paths and, where available, domain APIs provided by the respective modules' libraries. The module MUST NOT implement its own partial or incorrect Table Schema parser for upstream schemas; it MUST obtain account data through either the bus-accounts library domain API (preferred) or the shared bus-data library schema+CSV loader so that schema interpretation is consistent across modules. Acceptance criteria: no hardcoded paths to other modules' datasets; account and period data resolution is done via bus-accounts and bus-period library calls; implementation is testable with swapped or mocked library providers.

NFR-JRN-004 Upstream schema compatibility. Whenever bus-journal reads schemas owned by other modules (at minimum [bus-accounts](./bus-accounts)), it MUST treat those schemas as authoritative Frictionless Table Schema documents and MUST NOT fail solely because optional schema features are present. The presence of `foreignKeys` MUST NOT cause failure. Self-referencing foreign keys MUST be accepted: `reference.resource` equal to the empty string (`""`) means “same table”. The module MAY ignore schema features it does not need, but it MUST NOT reject valid schemas. Acceptance criteria: with `accounts.schema.json` containing a `foreignKeys` entry that references `parent_code` → `code` with `reference.resource` set to `""`, `bus journal add` MUST succeed and MUST NOT emit an unsupported-foreign-key diagnostic.

### System Architecture

Bus Journal owns the journal index and period journal datasets and accepts postings from other modules. It integrates with [bus-accounts](./bus-accounts) and [bus-period](./bus-period) only through their Go libraries: it obtains the path to the chart of accounts from the bus-accounts library and the path to the period control dataset (and effective period state) from the bus-period library when validating account references or enforcing period boundaries. It does not hardcode other modules' file names. When reading the chart of accounts, bus-journal loads account data using shared schema semantics (NFR-JRN-003, NFR-JRN-004); valid `foreignKeys` in `accounts.schema.json` (including self-referencing keys with `reference.resource` set to `""`) are supported or ignored but MUST NOT be treated as an error. It serves as the foundation for reporting and VAT computation.

### Key Decisions

KD-JRN-001 Append-only ledger. Journal corrections are expressed as new entries that reference prior records rather than overwriting them.

KD-JRN-002 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of the journal index and period journal file(s) for read-only access (e.g. balance computation in a prior workspace). Write access and all journal business logic (add, balance, validation) remain in this module.

KD-JRN-003 Cross-module data via owning modules' libraries. Bus-journal MUST NOT hardcode paths to datasets owned by other modules. When it needs to validate account names (e.g. for `add` or `balance`) or to respect period close/lock boundaries (NFR-JRN-001), it MUST obtain the path to the accounts dataset from the [bus-accounts](./bus-accounts) Go library and the path to the period control dataset (and effective state) from the [bus-period](./bus-period) Go library. Any other module whose data bus-journal reads (e.g. for future extensions) MUST be accessed the same way: path and domain APIs from that module's library only.

### Component Design and Interfaces

Interface IF-JRN-001 (module CLI). The module exposes `bus journal` with subcommands `init`, `add`, and `balance` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline journal index and schema (and any required structure for period journals) when they are absent. If the module’s owned journal data already exists in full and is consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially (e.g. journal index without schema or vice versa), `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Documented parameters for `bus journal add` are `--date <YYYY-MM-DD>`, `--desc <text>`, `--debit <account>=<amount>`, and `--credit <account>=<amount>`. The add command may accept optional `--source-id <key>` to record source identity for the posting; idempotent semantics (e.g. `--if-missing` or a separate upsert command) and uniqueness enforcement are not yet required — see [Suggested capabilities](#suggested-capabilities-out-of-current-scope). Documented parameters for `bus journal balance` include `--as-of <YYYY-MM-DD>`.

Each `--debit` and `--credit` flag represents one journal line and uses the syntax `<account>=<amount>`, where `<account>` is the account name as stored in the accounts dataset and should be quoted when it contains spaces. The flags are repeatable, and multiple debit and credit lines may be provided in any order to form a single transaction. At least one debit and one credit line are required, and the module sums all debit amounts and all credit amounts and requires them to balance before it writes the entry.

When validating account names (for `add` and `balance`) the module MUST resolve the chart of accounts path via the [bus-accounts](./bus-accounts) Go library (path accessor), not by hardcoding `accounts.csv`. It loads account data using shared schema semantics (bus-accounts domain API or bus-data schema+CSV loader); valid `foreignKeys` in `accounts.schema.json`, including self-referencing foreign keys with `reference.resource` equal to `""`, MUST be accepted and MUST NOT cause an unsupported-foreign-key error. When enforcing period close and lock boundaries (NFR-JRN-001), the module MUST resolve the period control path and effective period state via the [bus-period](./bus-period) Go library, not by hardcoding `periods.csv`. Any other module-owned data that bus-journal reads MUST be resolved through that module's Go library in the same way.

Interface IF-JRN-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to its owned data file(s): the journal index and, when applicable, period journal file(s) (and their schemas). Given a workspace root path and optionally a period identifier, the library returns the relevant path(s); resolution MUST allow future override from workspace or data package configuration. Other modules use these accessors for read-only access only; all writes and journal logic (balance computation, posting) remain in this module.

Usage examples:

```bash
bus journal add --date 2026-01-10 --desc "Bought new laptop" --debit "Office Equipment"=2500 --credit "Cash"=2500
```

```bash
bus journal balance --as-of 2026-03-31
```

### Data Design

All files owned by Bus Journal include “journal” or “journals” in the filename so that journal data is unambiguous at the workspace root. The module reads and writes the journal index `journals.csv` in the repository root and period journal files at the workspace root with a date prefix, for example `journal-2026.csv` (and its beside-the-table schema `journal-2026.schema.json`). The journal index, its schema, and all period journal files live in the workspace root only; the module does not create or use a subdirectory such as `2026/journals/` for journal data.

When bus-journal needs to read the chart of accounts (e.g. to validate account names in postings) or the period control dataset (e.g. to enforce period boundaries), it MUST obtain the path(s) from the [bus-accounts](./bus-accounts) and [bus-period](./bus-period) Go libraries respectively. It MUST NOT hardcode `accounts.csv`, `periods.csv`, or any other module-owned file names (NFR-JRN-003).

Other modules that need read-only access to journal data (e.g. to compute balances as-of a date in another workspace) MUST obtain the path(s) from this module’s Go library (IF-JRN-002). All writes and journal-domain logic remain in this module.

### Assumptions and Dependencies

Bus Journal MUST integrate with [bus-accounts](./bus-accounts) and [bus-period](./bus-period) via their Go libraries only. It obtains the path to the chart of accounts and the path to the period control dataset (and effective state) from those modules' library APIs; it MUST NOT hardcode `accounts.csv`, `periods.csv`, or other module-owned file names. The module depends on workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Journal data is repository data and should be protected by repository access controls. Voucher references and attachments must remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or balance violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover balance validation and posting logic, and command-level tests exercise `init`, `add`, and `balance` against fixture workspaces. Tests MUST verify that account and period data are resolved via the bus-accounts and bus-period Go libraries (or mocks thereof) and that the module does not hardcode paths to other modules' datasets (NFR-JRN-003).

Required regression coverage for upstream schema compatibility (NFR-JRN-004): an end-to-end or command-level test MUST (a) create a fixture workspace, (b) ensure `accounts.schema.json` includes a self-referencing foreign key with `reference.resource` set to `""` (e.g. `parent_code` → `code`), (c) run `bus journal add` with valid debit and credit accounts, and (d) assert success (no unsupported-foreign-key diagnostic). A separate test MUST ensure that the presence of `foreignKeys` in `accounts.schema.json` does not affect `bus journal balance` or other read operations. These tests are part of the specification; removing or disabling them without an explicit SDD change is non-compliant.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic ledger data handling.

### Suggested capabilities (out of current scope)

The following capabilities are not yet requirements; they are recorded as suggested enhancements for migration and bank-driven bookkeeping workflows.

**Idempotent posting with source keys.** Partially implemented: `bus journal add` supports `--source-id <key>`. Idempotent no-op on re-run is not confirmed, and replay scripts still use Makefile or marker guards. A suggested extension is idempotent semantics when the same source identity already exists: e.g. `bus journal add ... --source-id <key> --if-missing` (no-op if a posting with that `source_system`/`source_id` exists) or `bus journal upsert --source-id <key> ...`. The module would enforce uniqueness on `(source_system, source_id)` and emit clear diagnostics on conflict. Replay scripts could then be re-runnable without marker hacks. If this capability is adopted, the SDD will specify uniqueness and conflict behavior as a formal requirement, and the module docs will document `--if-missing`/upsert and `source_id` semantics.

**Rule-based bank classification and posting.** Bank-driven bookkeeping without a daybook source currently requires custom scripting per class. A suggested two-phase flow: (1) a classify command (e.g. `bus journal classify bank --profile <rules.yml>`) that produces deterministic proposal rows from bank transactions using predicates (counterparty regex, message code/text, sign, amount constraints, reference patterns), and (2) an apply command that posts approved proposals as balanced journal entries with idempotent source-linking and explainable rule traces, including dry-run, confidence scores, and skip reasons for unclassified rows.

**Learning classifications from prior-year bookkeeping.** Pattern-mining commands could suggest account mappings from historical posted data (e.g. infer frequent `(counterparty/message-pattern/sign) -> (debit_account, credit_account)` mappings from prior periods, emit ranked candidate rules for a target period, support approval/export into a rules profile consumable by a classifier). This would speed yearly continuation when the source daybook is missing, with transparent heuristics and reviewer approval before posting.

**Posting templates with automatic VAT split.** Not implemented. Current bank expense classes are posted as gross debit/credit to bank with VAT split done manually per class. A suggested extension is posting templates that split a gross amount into base + VAT by configured rate and VAT account. Each template would define: a predicate (to match bank rows or context), expense account, VAT rate, VAT account, and bank account; the module would post balanced lines with deterministic rounding and trace fields, support dry-run, and optionally link the posting to the source bank row. This would enable correct VAT and reduce custom scripting for recurring domestic supplier charges. If this capability is adopted, the SDD will add a new requirement for templates and the VAT-split flow; module and workflow docs will be required for template format and usage.

**Loan-payment classifier with principal/interest split.** Not implemented. [bus-loans](./bus-loans) exists for loan register, schedule, postings, and amortize but does not classify arbitrary bank rows into principal vs interest; financing-style bank rows (lenders, installments) still require custom code or manual split for two journal lines (liability + finance cost). A suggested extension, either in bus-journal or by integrating with bus-loans, is loan-profile–aware handling so that a bank payment can produce deterministic posting proposals with principal vs interest/fee split. Options: register lender payment profiles (reference keys, liability account, interest account, fee account, split policy); generate proposals per bank row with explicit split rationale; support fixed split, schedule-based split (e.g. [bus-loans](./bus-loans) schedule), or “all to liability” fallback with warning. Output would be balanced journal proposals for apply. If this capability is adopted, the SDD will change in bus-journal and/or bus-loans to specify the new behavior and interfaces; module docs will be required for profiles, split policy, and proposal output.

### Glossary and Terminology

Journal entry: a ledger posting row associated with a transaction and voucher.  
Journal index: the root-level dataset `journals.csv` that records which period journal files exist and where they live; all bus-journal owned filenames include “journal” or “journals” so journal data is unambiguous.  
Transaction identifier: a stable identifier that groups journal entries for a posting.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-accounts SDD](./bus-accounts) (chart of accounts path via library)
- [bus-period SDD](./bus-period) (period control path and state via library)
- [bus-bank SDD](./bus-bank)
- [bus-assets SDD](./bus-assets) (schedule-style patterns for loan-payment suggested capability)
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
Version: 2026-02-18  
Status: Draft  
Last updated: 2026-02-18  
Owner: BusDK development team  
