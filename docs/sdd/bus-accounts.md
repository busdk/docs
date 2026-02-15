---
title: bus-accounts — chart of accounts and stable references (SDD)
description: "Design spec for the BusDK accounts module: chart of accounts as schema-validated repository data, CLI for init, list, add, set, validate, stable references for downstream modules."
---

## bus-accounts — chart of accounts and stable references

### Introduction and Overview

Bus Accounts maintains the chart of accounts as schema-validated repository data. It enforces uniqueness and allowed account types and provides stable account references for downstream modules.

### Requirements

FR-ACC-001 Account registry integrity. Bus Accounts MUST maintain a deterministic chart of accounts in `accounts.csv` with schema validation and stable identifiers. Acceptance criteria: the module refuses duplicate identifiers and invalid account types and writes only schema-valid rows.

FR-ACC-002 CLI surface for account lifecycle. Bus Accounts MUST provide commands to initialize, list, add, set, and validate accounts so workflows can manage the chart of accounts without manual file edits. Acceptance criteria: the command names `init`, `list`, `add`, `set`, and `validate` are available under `bus accounts`, and each command fails with deterministic diagnostics on invalid inputs.

FR-ACC-004 Add fails when account exists. The `add` command MUST fail if an account with the same identifier (e.g. `--code`) already exists in the chart of accounts. Acceptance criteria: invoking `bus accounts add` with a code that is already present exits non-zero, emits a clear diagnostic to standard error, and does not modify the dataset. Modifying an existing account is done via `bus accounts set`, not `add`.

FR-ACC-003 Data-layer init via bus-data library. Bus Accounts MUST perform all initialization of the accounts dataset and schema through the [bus-data](./bus-data) Go library, not by invoking the bus-data CLI. Before creating or ensuring `accounts.csv` and `accounts.schema.json`, the module MUST use the bus-data library to ensure the workspace data package is initialized (i.e. an empty `datapackage.json` exists at the workspace root when missing, as defined by bus-data init). The module MUST create the accounts table and beside-the-table schema via the bus-data library (e.g. schema init or resource add). After a successful `bus accounts init`, `datapackage.json` MUST contain a resource entry for the accounts table with the path to `accounts.csv` and the associated schema so that workspace-level validation and discovery see the accounts data. Acceptance criteria: `bus accounts init` does not shell out to `bus data`; it calls bus-data library APIs only; after init, `datapackage.json` includes a resource for accounts (path and schema reference); re-running init when the data package already contains the accounts resource and files are consistent is idempotent.

NFR-ACC-001 Deterministic outputs. The module MUST produce deterministic listings and diagnostics so scripting and audits are stable across machines. Acceptance criteria: listings are ordered by stable account identifiers, and diagnostics refer to workspace-relative paths and stable identifiers.

NFR-ACC-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (e.g. accounts table and schema). Other modules that need read-only access to the chart of accounts raw file(s) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration (e.g. from workspace or data package config) can be supported without breaking consumers; today paths may be conventional defaults (e.g. `accounts.csv`). Acceptance criteria: the library provides at least one path accessor (e.g. given workspace root, returns the path to the accounts CSV and/or schema); consumers that need to read accounts data for pure-data purposes use this accessor; no consumer hardcodes `accounts.csv` outside this module.

### System Architecture

Bus Accounts is a module that owns the accounts datasets and schemas and exposes a CLI surface that reads and writes those datasets. It integrates with the [bus-data](./bus-data) Go library for all initialization: ensuring the workspace data package exists, creating `accounts.csv` and `accounts.schema.json`, and registering the accounts resource in `datapackage.json`. It integrates with other modules by providing stable account identifiers and types that become foreign keys in journal, invoice, budget, and reporting datasets.

### Key Decisions

KD-ACC-001 Accounts are authoritative repository data. The chart of accounts is stored as workspace datasets with beside-the-table schemas so it remains reviewable and exportable.

KD-ACC-002 Init via bus-data library only. Account baseline creation is implemented on top of the bus-data Go library. The module ensures the data package descriptor exists (bus-data init semantics), then creates `accounts.csv` and `accounts.schema.json` and registers the accounts resource in `datapackage.json` through library calls. This keeps a single code path for descriptor and table creation and aligns with [bus-data](./bus-data) KD-DAT-004 and [bus-config](./bus-config) / [bus-init](./bus-init) practice.

KD-ACC-003 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of the accounts dataset for read-only access without hardcoding file names. Write access and all account business logic remain in this module; path exposure does not grant write or domain-logic rights.

### Component Design and Interfaces

Interface IF-ACC-001 (module CLI). The module exposes `bus accounts` with subcommands `init`, `list`, `add`, `set`, and `validate` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline accounts dataset and schema when they are absent. It MUST use the [bus-data](./bus-data) Go library only (no CLI invocation). Init sequence: (1) Call the bus-data library to ensure the workspace data package is initialized — i.e. create an empty `datapackage.json` at the workspace root when the file is missing, matching bus-data init behavior. (2) Create `accounts.csv` and `accounts.schema.json` via the bus-data library (e.g. schema init or resource add). (3) Ensure `datapackage.json` contains a resource entry for the accounts table (path to `accounts.csv` and schema reference) so that after init the data package describes the accounts dataset. If both `accounts.csv` and `accounts.schema.json` already exist and are consistent and the data package already contains the accounts resource, `init` prints a warning to standard error and exits 0 without modifying anything. If only one of the files exists, or the data is inconsistent, or the data package is missing when it should exist, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](./bus-init) FR-INIT-003).

The `add` command creates a new account. It accepts account identity and type parameters: `--code <account-id>`, `--name <account-name>`, and `--type <asset|liability|equity|income|expense>`. The command MUST fail if an account with the same identifier (e.g. the same `--code`) already exists in the chart of accounts: it MUST exit non-zero, emit a clear diagnostic to standard error, and MUST NOT modify the dataset (FR-ACC-004).

The `set` command modifies an existing account. It is used to update name, type, or other attributes of an account that already exists (identified by code). The command MUST fail if no account with the given identifier exists. Parameters and semantics are defined by the module implementation; the invariant is that creation is done only via `add` and updates only via `set`.

Interface IF-ACC-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to its owned data file(s). For example, given a workspace root path, the library returns the path to the accounts CSV (and optionally the beside-the-table schema path). Resolution MUST be designed so that default paths are conventional names today but can later be overridden from workspace or data package configuration without changing the consumer API. Consumers use these accessors for read-only access to the raw file(s); they must not write to the path or rely on account business logic except via this module’s own APIs.

Usage examples:

```bash
bus accounts init
bus accounts list
```

```bash
bus accounts add --code 3000 --name "Consulting Income" --type income
bus accounts set --code 3000 --name "Consulting & Training Income"
bus accounts validate
```

### Data Design

The module reads and writes `accounts.csv` with a beside-the-table JSON Table Schema. Account identifiers are stable keys used by other datasets. Master data owned by this module is stored in the workspace root only; the module does not create or use an `accounts/` or other subdirectory for its datasets and schemas. After a successful `bus accounts init`, the workspace data package (`datapackage.json`) MUST contain a resource entry for the accounts table: the resource path points to `accounts.csv` and the resource reflects the beside-the-table schema so that `bus data package discover`, `bus data package validate`, and other data-package operations see the accounts dataset.

Other modules that need read-only access to the accounts dataset (e.g. to resolve account codes or read the chart for balance computation in another workspace) MUST obtain the path from this module’s Go library (IF-ACC-002), not by hardcoding `accounts.csv`. All writes and account-domain logic (validation, types, listing) remain in this module.

### Assumptions and Dependencies

Bus Accounts depends on the workspace layout and schema conventions defined in the BusDK design spec and on the [bus-data](./bus-data) Go library for data package and table initialization. The module MUST integrate with bus-data via the library only (no invocation of the `bus data` CLI). If the bus-data library is unavailable or the workspace cannot be initialized (e.g. unwritable root), the module fails with deterministic diagnostics. If the accounts datasets or schemas are missing or invalid after an init attempt, the module fails with deterministic diagnostics.

### Security Considerations

The chart of accounts is repository data and should be protected by the same access controls as the rest of the workspace. Corrections are recorded as new rows rather than destructive edits to preserve auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema and invariant violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover account validation and deterministic listing behavior, and command-level tests exercise `init`, `add`, `set`, `list`, and `validate` against fixture workspaces. Tests MUST verify that `add` fails with non-zero exit and no dataset change when the account code already exists (FR-ACC-004), and that `set` can modify an existing account and fails when the account does not exist.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly account data.

### Glossary and Terminology

Chart of accounts: the authoritative list of account identifiers and types stored as workspace datasets.  
Account identifier: a stable key used by other datasets to reference accounts.  
Data package: the workspace `datapackage.json` descriptor maintained by [bus-data](./bus-data); after accounts init it includes a resource for the accounts table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-entities">bus-entities</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-data SDD](./bus-data) (data package and table init via library)
- [bus-init SDD](./bus-init) (module init contract)
- [Owns master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-accounts CLI reference](../modules/bus-accounts)
- [Repository](https://github.com/busdk/bus-accounts)
- [Accounts area](../layout/accounts-area)
- [Table schema contract](../data/table-schema-contract)

### Document control

Title: bus-accounts module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-ACCOUNTS`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-15  
Owner: BusDK development team  
