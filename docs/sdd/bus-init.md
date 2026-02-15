---
title: bus-init — workspace bootstrap with optional domain datasets (SDD)
description: Bus Init creates workspace configuration by default (datapackage.json only); domain module inits run only when the user supplies per-module flags.
---

## bus-init — workspace bootstrap with optional domain datasets

### Introduction and Overview

Bus Init bootstraps a new BusDK workspace by creating or ensuring workspace-level configuration and, when requested, by orchestrating domain module `init` commands. By default it runs only [bus-config](./bus-config) `init`, so that `datapackage.json` and accounting entity settings exist without creating any domain datasets. bus-config init uses the [bus-data](./bus-data) library to create the empty descriptor when missing, then adds the accounting entity subtree; bus-init does not call bus-data directly. Domain module inits run only when the user explicitly includes them via per-module flags. Each Bus module that owns workspace data has its own flag; when one or more of these flags are present, bus-init runs `bus config init` first, then each selected module’s `init` in a deterministic order. Bus Init does not write configuration or domain data itself; it delegates to bus-config for the descriptor and to each domain module for its baseline data.

### Requirements

FR-INIT-001 Workspace bootstrap. The module MUST run `bus config init` so that workspace configuration (`datapackage.json` and `busdk.accounting_entity`) exists. When no module-include flags are supplied, the module MUST run only `bus config init` and MUST NOT invoke any domain module’s `init`. When one or more module-include flags are supplied, the module MUST run `bus config init` first, then each selected domain module’s `init` in the deterministic order defined for IF-INIT-001, and MUST NOT invoke any domain module whose flag was not supplied. Acceptance criteria: running `bus init` with no module flags results in only `datapackage.json` (and accounting entity) at the workspace root; running `bus init --accounts --entities` results in config plus accounts and entities baseline datasets and schemas; the workspace never contains baseline files for a module whose flag was not supplied.

FR-INIT-002 Non-invasive initialization. The module MUST not perform Git or network operations. Acceptance criteria: initialization only affects workspace datasets and metadata.

FR-INIT-003 Module init contract. Every module invoked during bootstrap (including bus-config for workspace configuration and each domain module that owns master data) MUST provide an `init` command that creates the module’s baseline datasets and schemas when they are absent. When the module’s data already exists in full (all owned datasets and schemas present and consistent), `init` MUST print a warning to standard error and exit with code 0 without modifying any file. When the module’s data exists only partially (one or more owned datasets or schemas missing or inconsistent), `init` MUST fail with a clear error to standard error, MUST NOT modify any file, and MUST exit with a non-zero code. Acceptance criteria: running `init` on an empty workspace creates the baseline; running `init` again after a successful bootstrap yields a warning and exit 0; running `init` when some but not all owned files exist yields an error and no writes.

NFR-INIT-001 Deterministic output. The module MUST emit deterministic diagnostics and stop on the first failure. Acceptance criteria: failures identify the module command that failed.

FR-INIT-004 Owned paths only. The module MUST NOT require or verify the presence of files owned by other modules (e.g. `journals.csv`, `accounts.csv`). Success MUST be determined solely by the exit codes of the commands it invokes (`bus config init` and, when selected, each domain module’s `init`). Acceptance criteria: the implementation does not perform a post-hoc check against a fixed list of baseline paths; running `bus init` never fails with a “missing required path X” error for any path X owned by bus-config or a domain module.

FR-INIT-005 Per-module flags. For each Bus module that owns workspace datasets (see the table in “Module-include flags (data-owning modules)”), the module MUST provide a corresponding boolean flag. When that flag is set, the module’s `init` is included in the sequence run after `bus config init`. The set of flags MUST be: `--accounts`, `--entities`, `--period`, `--journal`, `--balances`, `--invoices`, `--vat`, `--attachments`, `--bank`, `--budget`, `--assets`, `--inventory`, `--loans`, `--payroll`. When multiple flags are supplied, the corresponding module inits MUST run in the order: accounts, entities, period, journal, balances, invoices, vat, attachments, bank, budget, assets, inventory, loans, payroll. The module MUST accept an optional subcommand that selects a named module set. Two subcommands are defined: `defaults` (initialize only workspace configuration; same as omitting the subcommand and supplying no module-include flags) and `all` (initialize config plus all fourteen data-owning modules). When the subcommand is `all`, the module MUST also accept `--no-<name>` flags: for each module that has a per-module include flag, the corresponding boolean `--no-<name>` flag (e.g. `--no-accounts`, `--no-payroll`) excludes that module from the set of inits run; the effective set is all fourteen minus any for which `--no-<name>` was supplied. When the subcommand is not `all`, `--no-<name>` flags have no effect. Additional named sets (e.g. `sheets` for a future bus-sheets–related set) MAY be added as further subcommands; using subcommands for sets avoids name clashes with module names (e.g. a `--sheets` flag would conflict with bus-sheets). Acceptance criteria: help output lists subcommands `defaults` and `all`, each per-module flag, and the `--no-<name>` exclusions for `all`; invoking `bus init` or `bus init defaults` runs only `bus config init`; invoking `bus init --accounts` runs only `bus config init` and `bus accounts init`; invoking `bus init all` runs config init then all fourteen module inits in order; invoking `bus init all --no-payroll` runs config init then all thirteen module inits other than payroll, in the same deterministic order.

### System Architecture

Bus Init is an orchestrator that always runs `bus config init` and, when the user supplies one or more module-include flags, invokes each selected domain module’s `init` in a fixed order. By default it runs only `bus config init`, so the workspace gets `datapackage.json` and accounting entity settings without any domain datasets. It does not own workspace configuration (bus-config owns `datapackage.json`) or domain datasets; it only coordinates the sequence and relies on exit codes for success.

### Key Decisions

KD-INIT-001 Module-owned initialization. The bootstrap workflow delegates dataset creation to each module to preserve ownership boundaries.

KD-INIT-002 Init idempotency and partial-state safety. Each module’s `init` obeys the contract in FR-INIT-003: it creates baseline data only when absent, warns and does nothing when data already exists in full, and fails without writing when data exists only partially.

KD-INIT-003 No verification of other modules’ paths. Per FR-INIT-004, bus-init does not require or verify the presence of files owned by other modules. Success is determined solely by the orchestration: `bus config init` and, when run, each selected domain module’s `init` exit successfully. Each module is responsible for creating its own datasets and for failing its init when it cannot; bus-init does not perform a post-hoc check against a fixed list of baseline paths. This avoids bus-init failing with “missing required path X” when X is owned by a module that was not run, failed earlier, or is not installed.

KD-INIT-004 Config-only default; module init opt-in. By default, `bus init` (or `bus init defaults`) initializes only workspace configuration so that new or partial workspaces can have a valid `datapackage.json` without committing to every domain dataset. Users who want the full baseline use the `all` subcommand (`bus init all`); they can exclude specific modules with `--no-<name>`. Users who want a subset use per-module include flags without a set subcommand. The set of per-module flags corresponds to the Bus modules that own workspace datasets; if new data-owning modules are added to BusDK, each receives its own flag and a place in the deterministic execution order.

KD-INIT-005 Module sets as subcommands. Named module sets (e.g. `all`, and in future `sheets` or others) are exposed as subcommands rather than as flags so that set names never conflict with module names. A flag such as `--sheets` would clash with the bus-sheets module; a subcommand `bus init sheets` does not.

### Module-include flags (data-owning modules)

A Bus module receives a module-include flag if and only if it owns some kind of master data in the current workspace: it has datasets and/or schemas in the workspace root that it creates or ensures via its `init` command. The following modules meet that criterion and MUST each have a corresponding boolean flag. The execution order when multiple flags are supplied is the order listed below.

| Flag | Module | Owned workspace data (baseline) |
|------|--------|---------------------------------|
| `--accounts` | bus-accounts | Chart of accounts: `accounts.csv`, `accounts.schema.json` |
| `--entities` | bus-entities | Counterparties: `entities.csv`, `entities.schema.json` |
| `--period` | bus-period | Period control: `periods.csv`, `periods.schema.json` |
| `--journal` | bus-journal | Journal index: `journals.csv`, `journals.schema.json` (and period-scoped journal files when used) |
| `--balances` | bus-balances | Balance snapshot: `balances.csv`, `balances.schema.json` |
| `--invoices` | bus-invoices | Sales and purchase invoices and lines: `sales-invoices.csv`, `sales-invoice-lines.csv`, `purchase-invoices.csv`, `purchase-invoice-lines.csv` and their schemas |
| `--vat` | bus-vat | VAT reference and reports: `vat-rates.csv`, `vat-returns.csv`, `vat-reports.csv` and their schemas |
| `--attachments` | bus-attachments | Evidence index: `attachments.csv`, `attachments.schema.json` |
| `--bank` | bus-bank | Bank imports and transactions: `bank-imports.csv`, `bank-transactions.csv` and their schemas |
| `--budget` | bus-budget | Budget dataset: `budgets.csv`, `budgets.schema.json` (optional for statutory bookkeeping) |
| `--assets` | bus-assets | Fixed-asset register and depreciation datasets and schemas in the workspace root |
| `--inventory` | bus-inventory | Item master and movement datasets and schemas in the workspace root |
| `--loans` | bus-loans | Loan register and event datasets and schemas in the workspace root |
| `--payroll` | bus-payroll | Employee and payroll run datasets and schemas in the workspace root |

No other Bus modules own workspace master data in this sense. bus-config owns only `datapackage.json` (workspace configuration), which is always initialized by `bus config init` before any module-include step; bus-validate, bus-reports, bus-reconcile, bus-filing, bus-agent, bus-dev, bus-preferences, and similar modules do not own workspace datasets and therefore do not have a module-include flag.

**Subcommands for module sets.** The command accepts an optional subcommand that selects a named module set. Using subcommands (instead of flags like `--all` or `--sheets`) keeps set names from clashing with module names—e.g. a future `bus init sheets` can denote a sheets-related set without conflicting with the bus-sheets module.

- **`defaults`** (or no subcommand with no module-include flags): run only `bus config init`. Equivalent to config-only initialization. Explicitly run `bus init defaults` or plain `bus init` with no flags.
- **`all`**: run config init then all fourteen data-owning module inits in the deterministic order. You can exclude specific modules with the corresponding `--no-<name>` flag (e.g. `--no-accounts`, `--no-payroll`). Example: `bus init all --no-payroll` initializes config and all data-owning modules except payroll. When the subcommand is not `all`, `--no-<name>` flags are ignored.

Additional named sets (e.g. `sheets`) may be added later as further subcommands; they are not defined in this document.

### Component Design and Interfaces

Interface IF-INIT-001 (bootstrap). The module is invoked as `bus init` and follows BusDK CLI conventions for deterministic output and diagnostics. The command always runs `bus config init` first. When no subcommand or subcommand is `defaults`, and no module-include flags are supplied, it runs only `bus config init` and exits; no domain module inits are invoked. When subcommand is `all`, the set of modules to run is all fourteen data-owning modules minus any for which a `--no-<name>` flag was supplied (e.g. `--no-payroll` excludes payroll); those module inits run after config init in the same deterministic order. When one or more module-include flags are present (and subcommand is not `all`), it then runs each selected module’s `init` in this deterministic order: accounts, entities, period, journal, balances, invoices, vat, attachments, bank, budget, assets, inventory, loans, payroll (only those whose flag was supplied are run, in this order). It does not accept layout selection flags and uses the standard workspace layout with deterministic dataset and schema filenames. An optional subcommand (`defaults` or `all`) may be supplied. Module-include flags are those listed in the table in “Module-include flags (data-owning modules)”; each has a corresponding `--no-<name>` that excludes that module when subcommand is `all`. To change accounting entity settings after bootstrap, use [bus config configure](../modules/bus-config).

Usage examples:

```bash
bus init
```

Initializes only workspace configuration (`datapackage.json` and accounting entity). No domain datasets are created.

```bash
bus init --accounts --entities --journal
```

Initializes workspace configuration, then accounts, entities, and journal baseline datasets and schemas in that order.

```bash
bus init all
```

Initializes the full baseline (config plus all fourteen data-owning modules). To initialize only a subset of modules, use per-module flags without the `all` subcommand (e.g. `bus init --accounts --entities`).

```bash
bus init all --no-payroll
```

Initializes config and all fourteen data-owning modules except payroll. Use any combination of `--no-<name>` flags with `bus init all` to exclude specific modules.

### Data Design

The module does not create or own any workspace files directly. It always invokes `bus config init`, which creates or ensures `datapackage.json` and the `busdk.accounting_entity` subtree at the workspace root. When the user has supplied one or more module-include flags, it then invokes each selected domain module’s `init`, which create that module’s baseline datasets and schemas. With no module flags, the workspace after `bus init` contains only `datapackage.json` (and accounting entity settings); no accounts, entities, journal, or other domain files are created. Success is determined only by the orchestration: when every invoked command (`bus config init` and, when run, each selected module’s `init`) exits with code 0, the operation is successful. Bus-init does not verify a fixed list of baseline paths afterward; each module owns its outputs and is responsible for failing its init if it cannot create them. Bus-init must not fail with a “missing required path” error for any file owned by another module (see KD-INIT-003).

### Assumptions and Dependencies

Bus Init depends on the presence of the `bus` dispatcher and [bus-config](./bus-config) for workspace configuration. bus-config in turn uses the [bus-data](./bus-data) library to create the empty `datapackage.json` when missing. When a module-include flag is supplied, the corresponding domain module CLI (e.g. bus-accounts for `--accounts`, bus-entities for `--entities`) must be available; if that module is not installed or not in PATH, the invoked step fails and bus-init reports it. The standard workspace layout conventions apply to any datasets created by the selected modules. Missing or unavailable module commands result in deterministic diagnostics.

### Security Considerations

Initialization only creates baseline datasets and does not perform network or version control operations. Access controls are handled at the repository level.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to the module command that failed.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Module failures are surfaced directly without partial completion.

### Testing Strategy

Command-level tests exercise `bus init` against fixture workspaces. Tests verify that with no module flags only `datapackage.json` (and accounting entity) is created; with one or more module-include flags, config plus the selected modules’ baseline datasets and schemas are created; that the deterministic order of module inits is respected when multiple flags are supplied; that `bus init all` runs config init then all fourteen module inits in order; and that `bus init all --no-<name>` (e.g. `bus init all --no-payroll`) runs config init then the remaining modules in the same order, excluding the specified module(s).

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Changes to the bootstrap baseline are handled by updating module `init` behavior and documentation.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and repeatable initialization.

### Glossary and Terminology

**Workspace bootstrap:** the initial creation of baseline datasets and schemas in a new repository. When used in the context of bus-init, “full bootstrap” means running `bus init` with all fourteen module-include flags (or `bus init all`, optionally with `--no-<name>` to exclude specific modules) so that config and every desired data-owning module’s baseline exist.

**Module-include flag:** a boolean flag (e.g. `--accounts`, `--journal`) that, when set, causes bus-init to run that module’s `init` after `bus config init`. With no module-include flags, only workspace configuration is initialized.

**`--no-<name>` flag:** for each module with a module-include flag, the corresponding exclusion flag (e.g. `--no-payroll`, `--no-accounts`). When the subcommand is `all`, each `--no-<name>` excludes that module from the set of inits run; when the subcommand is not `all`, `--no-<name>` flags are ignored.

**Module-owned initialization:** each module creates its own datasets during bootstrap; bus-init only orchestrates which modules run.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./modules">Modules (SDD)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-config">bus-config</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-config module SDD](./bus-config)
- [End user documentation: bus-init CLI reference](../modules/bus-init)
- [End user documentation: bus-config CLI reference](../modules/bus-config)
- [Layout principles](../layout/layout-principles)
- [Initialize repo](../workflow/initialize-repo)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Repository](https://github.com/busdk/bus-init)

### Document control

Title: bus-init module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-INIT`  
Version: 2026-02-14  
Status: Draft  
Last updated: 2026-02-14  
Owner: BusDK development team  
