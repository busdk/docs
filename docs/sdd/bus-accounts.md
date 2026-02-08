## bus-accounts

### Introduction and Overview

Bus Accounts maintains the chart of accounts as schema-validated repository data. It enforces uniqueness and allowed account types and provides stable account references for downstream modules.

### Requirements

FR-ACC-001 Account registry integrity. Bus Accounts MUST maintain a deterministic chart of accounts in `accounts.csv` with schema validation and stable identifiers. Acceptance criteria: the module refuses duplicate identifiers and invalid account types and writes only schema-valid rows.

FR-ACC-002 CLI surface for account lifecycle. Bus Accounts MUST provide commands to initialize, list, add, and validate accounts so workflows can manage the chart of accounts without manual file edits. Acceptance criteria: the command names `init`, `list`, `add`, and `validate` are available under `bus accounts`, and each command fails with deterministic diagnostics on invalid inputs.

NFR-ACC-001 Deterministic outputs. The module MUST produce deterministic listings and diagnostics so scripting and audits are stable across machines. Acceptance criteria: listings are ordered by stable account identifiers, and diagnostics refer to workspace-relative paths and stable identifiers.

### System Architecture

Bus Accounts is a module that owns the accounts datasets and schemas in the accounts area and exposes a CLI surface that reads and writes those datasets. It integrates with other modules by providing stable account identifiers and types that become foreign keys in journal, invoice, budget, and reporting datasets.

### Key Decisions

KD-ACC-001 Accounts are authoritative repository data. The chart of accounts is stored as workspace datasets with beside-the-table schemas so it remains reviewable and exportable.

### Component Design and Interfaces

Interface IF-ACC-001 (module CLI). The module exposes `bus accounts` with subcommands `init`, `list`, `add`, and `validate` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `add` command accepts account identity and type parameters. Documented parameters are `--code <account-id>`, `--name <account-name>`, and `--type <asset|liability|equity|income|expense>`.

Usage examples:

```bash
bus accounts init
bus accounts list
```

```bash
bus accounts add --code 3000 --name "Consulting Revenue" --type income
bus accounts validate
```

### Data Design

The module reads and writes `accounts.csv` with a beside-the-table JSON Table Schema in the accounts area. Account identifiers are stable keys used by other datasets.

### Assumptions and Dependencies

Bus Accounts depends on the workspace layout and schema conventions defined in the BusDK design spec. If the accounts datasets or schemas are missing or invalid, the module fails with deterministic diagnostics.

### Security Considerations

The chart of accounts is repository data and should be protected by the same access controls as the rest of the workspace. Corrections are recorded as new rows rather than destructive edits to preserve auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema and invariant violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover account validation and deterministic listing behavior, and command-level tests exercise `init`, `add`, `list`, and `validate` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly account data.

### Glossary and Terminology

Chart of accounts: the authoritative list of account identifiers and types stored as workspace datasets.  
Account identifier: a stable key used by other datasets to reference accounts.

### See also

End user documentation: [bus-accounts CLI reference](../modules/bus-accounts)  
Repository: https://github.com/busdk/bus-accounts

For account dataset layout and schema expectations, see [Accounts area](../layout/accounts-area) and [Table schema contract](../data/table-schema-contract).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-entities">bus-entities</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-accounts module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-ACCOUNTS`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
