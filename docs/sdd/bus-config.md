## bus-config

### Introduction and Overview

Bus Config owns workspace-level configuration stored in `datapackage.json` at the workspace root. It creates and updates the BusDK extension metadata (the `busdk.accounting_entity` object) that defines accounting entity settings — base currency, fiscal year boundaries, VAT registration, and VAT reporting cadence. Other modules read these settings when they validate, post, reconcile, report, or produce filings; they do not duplicate entity-wide settings in row-level datasets.

The module provides a dedicated CLI surface for configuration so that editing workspace settings is separate from bootstrapping a new workspace. Bootstrap is orchestrated by [bus-init](./bus-init), which invokes `bus config init` first to create or ensure `datapackage.json`, then runs each domain module’s `init`. Bus Config is the sole owner of the workspace configuration file and the accounting entity subtree; it does not own domain datasets (chart of accounts, parties, journals, and so on), which remain owned by their respective modules.

### Requirements

FR-CFG-001 Workspace configuration creation. The module MUST provide an `init` command that creates or ensures `datapackage.json` at the workspace root with a valid `busdk.accounting_entity` object. When the file already exists and already contains `busdk.accounting_entity`, `init` MUST print a warning to standard error and exit with code 0 without modifying the file. When the file is missing or does not contain `busdk.accounting_entity`, `init` MUST create or update it so that the descriptor conforms to the [workspace configuration](../data/workspace-configuration) shape. Acceptance criteria: running `bus config init` in an empty directory creates `datapackage.json` with default accounting entity settings; running it again yields a warning and no write; running it in a directory that has a minimal data package without the BusDK extension adds the `busdk.accounting_entity` subtree with defaults.

FR-CFG-002 Accounting entity settings update. The module MUST support updating accounting entity properties in an existing workspace `datapackage.json` without re-running init. Acceptance criteria: `bus config configure` accepts flags for each property (`base_currency`, `fiscal_year_start`, `fiscal_year_end`, `vat_registered`, `vat_reporting_period`); only provided flags alter the stored value; the command fails with a clear error if `datapackage.json` does not exist or does not contain `busdk.accounting_entity`.

FR-CFG-003 Non-invasive operation. The module MUST not perform Git or network operations. Acceptance criteria: all commands only read and write the workspace `datapackage.json` (and only the BusDK extension subtree where applicable).

FR-CFG-004 Deterministic output. The module MUST emit deterministic diagnostics and fail with a clear message when preconditions are not met. Acceptance criteria: invalid usage or missing preconditions produce a deterministic error to standard error and a non-zero exit code.

NFR-CFG-001 Schema conformance. Flag values for `configure` MUST conform to the canonical schema in [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration). Invalid values produce a deterministic usage error and exit code 2.

### System Architecture

Bus Config is a small CLI module that reads and writes a single workspace artifact (`datapackage.json`). It is invoked directly by users when they want to create or change accounting entity settings, and it is invoked by bus-init during bootstrap to ensure the workspace descriptor exists before domain module inits run. It has no internal subprocess calls beyond the normal dependency on the `bus` dispatcher; it does not invoke other BusDK modules for configuration.

### Key Decisions

KD-CFG-001 Configuration as a dedicated module. Workspace configuration is owned by bus-config rather than bus-init so that the CLI surface is simplified: `bus init` means “bootstrap a new workspace,” and `bus config` means “create or edit workspace configuration.” Users and scripts can run `bus config configure` without implying re-initialization.

KD-CFG-002 Init idempotency. `bus config init` is idempotent when the workspace already has a valid `busdk.accounting_entity` object. It does not overwrite existing configuration, which avoids accidental loss of user settings during re-runs or scripting.

### Component Design and Interfaces

Interface IF-CFG-001 (init). The module is invoked as `bus config init` and follows BusDK CLI conventions for deterministic output and diagnostics. The command accepts no positional arguments and no module-specific flags beyond the shared global flags. It creates or updates `datapackage.json` at the effective workspace root (current directory or the directory given by `-C` / `--chdir`). When the file already contains `busdk.accounting_entity`, it exits 0 and prints a warning to stderr without writing.

Interface IF-CFG-002 (configure). The module is invoked as `bus config configure` and updates accounting entity settings in an existing workspace `datapackage.json`. The command requires a workspace that already contains `datapackage.json` with a `busdk.accounting_entity` object. It accepts optional flags: `--base-currency`, `--fiscal-year-start`, `--fiscal-year-end`, `--vat-registered`, `--vat-reporting-period`. Only flags explicitly provided are written; other properties remain unchanged. Flag values must conform to the canonical schema; invalid values produce a deterministic usage error and exit code 2.

Usage examples:

```bash
bus config init
bus config configure --base-currency=EUR --vat-registered=true
```

### Data Design

The module owns a single artifact: `datapackage.json` at the workspace root. The descriptor contains both the Frictionless resource manifest and BusDK workspace-level configuration via the `busdk.accounting_entity` extension. The `init` command creates the file or ensures the `busdk.accounting_entity` subtree exists with default values; the `configure` command updates only the properties specified by flags. The module does not create or modify domain datasets (accounts, entities, journals, etc.); those are owned by other modules.

### Assumptions and Dependencies

Bus Config depends on the standard workspace layout: the effective workspace root is the directory where `datapackage.json` is expected. It assumes the `bus` dispatcher is available when invoked. When invoked by bus-init during bootstrap, bus-config init runs before any domain module init so that the descriptor exists for modules that read it.

### Security Considerations

The module only reads and writes the workspace descriptor. Access controls are handled at the repository and filesystem level.

### Observability and Logging

Command results are written to standard output when applicable; diagnostics and warnings are written to standard error with deterministic messages.

### Error Handling and Resilience

Invalid usage or missing preconditions (e.g. `datapackage.json` not found, or `busdk.accounting_entity` missing for `configure`) result in a non-zero exit and a concise error on stderr.

### Testing Strategy

Command-level tests exercise `bus config init` and `bus config configure` against fixture workspaces and verify that the descriptor is created or updated as specified and that idempotency and precondition checks behave as required.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Existing workspaces that already have `datapackage.json` with `busdk.accounting_entity` are unchanged; they can use `bus config configure` from the new module instead of the previous `bus init configure` command.

### Risks

Not Applicable beyond the need for deterministic, repeatable behavior when reading and writing the descriptor.

### Glossary and Terminology

Workspace configuration: the contents of `datapackage.json` at the workspace root, including the BusDK extension `busdk.accounting_entity`.  
Accounting entity settings: the set of properties (base currency, fiscal year, VAT registration, VAT reporting period) that apply to the whole workspace and are read by other modules.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-config CLI reference](../modules/bus-config)
- [Initialize repo](../workflow/initialize-repo)
- [Layout principles](../layout/layout-principles)

### Document control

Title: bus-config module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-CFG`  
Version: 2026-02-12  
Status: Draft  
Last updated: 2026-02-12  
Owner: BusDK development team
