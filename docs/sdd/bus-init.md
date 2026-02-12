## bus-init

### Introduction and Overview

Bus Init bootstraps a new BusDK workspace by orchestrating a deterministic sequence of module `init` commands. It invokes [bus-config](./bus-config) first to create or ensure workspace-level configuration (`datapackage.json`), then invokes each domain module’s `init` so that every module remains the sole owner of its datasets and schemas. Bus Init does not write configuration or domain data itself; it delegates to bus-config for the descriptor and to each domain module for its baseline data.

### Requirements

FR-INIT-001 Workspace bootstrap. The module MUST orchestrate a deterministic sequence of module `init` commands, starting with `bus config init` so that workspace configuration exists before domain module inits run. Acceptance criteria: the resulting workspace contains the minimal baseline datasets and schemas for the standard BusDK workspace layout, including `datapackage.json` with a valid `busdk.accounting_entity` object.

FR-INIT-002 Non-invasive initialization. The module MUST not perform Git or network operations. Acceptance criteria: initialization only affects workspace datasets and metadata.

FR-INIT-003 Module init contract. Every module invoked during bootstrap (including bus-config for workspace configuration and each domain module that owns master data) MUST provide an `init` command that creates the module’s baseline datasets and schemas when they are absent. When the module’s data already exists in full (all owned datasets and schemas present and consistent), `init` MUST print a warning to standard error and exit with code 0 without modifying any file. When the module’s data exists only partially (one or more owned datasets or schemas missing or inconsistent), `init` MUST fail with a clear error to standard error, MUST NOT modify any file, and MUST exit with a non-zero code. Acceptance criteria: running `init` on an empty workspace creates the baseline; running `init` again after a successful bootstrap yields a warning and exit 0; running `init` when some but not all owned files exist yields an error and no writes.

NFR-INIT-001 Deterministic output. The module MUST emit deterministic diagnostics and stop on the first failure. Acceptance criteria: failures identify the module command that failed.

### System Architecture

Bus Init is an orchestrator that invokes `bus config init` and then each domain module’s `init` in a fixed order to produce the workspace baseline. It does not own workspace configuration (bus-config owns `datapackage.json`) or domain datasets; it only coordinates the sequence and verifies that required baseline files exist afterward.

### Key Decisions

KD-INIT-001 Module-owned initialization. The bootstrap workflow delegates dataset creation to each module to preserve ownership boundaries.

KD-INIT-002 Init idempotency and partial-state safety. Each module’s `init` obeys the contract in FR-INIT-004: it creates baseline data only when absent, warns and does nothing when data already exists in full, and fails without writing when data exists only partially.

### Component Design and Interfaces

Interface IF-INIT-001 (bootstrap). The module is invoked as `bus init` (or `bus init init`) and follows BusDK CLI conventions for deterministic output and diagnostics. The command runs `bus config init` first, then each domain module’s `init` in a deterministic order (accounts, entities, period, journal, invoices, vat, attachments, bank). It does not accept layout selection flags and always initializes the standard workspace layout with deterministic dataset and schema filenames. `bus init` accepts no positional arguments and no module-level flags beyond the shared global flags. To change accounting entity settings after bootstrap, use [bus config configure](../modules/bus-config).

Usage example:

```bash
bus init
```

### Data Design

The module does not create or own any workspace files directly. It invokes `bus config init`, which creates or ensures `datapackage.json` and the `busdk.accounting_entity` subtree at the workspace root. It then invokes each domain module’s `init`, which create the baseline datasets and schemas (accounts, entities, periods, journals, invoices, VAT, attachments, bank). After all inits complete, bus-init verifies that every required baseline path exists and fails with a clear error if any is missing.

### Assumptions and Dependencies

Bus Init depends on the presence of the `bus` dispatcher, [bus-config](./bus-config) for workspace configuration, and each domain module CLI (accounts, entities, period, journal, invoices, vat, attachments, bank) and on the standard workspace layout conventions. Missing module commands result in deterministic diagnostics.

### Security Considerations

Initialization only creates baseline datasets and does not perform network or version control operations. Access controls are handled at the repository level.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to the module command that failed.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Module failures are surfaced directly without partial completion.

### Testing Strategy

Command-level tests exercise `bus init` against fixture workspaces and verify that required baseline datasets and schemas are created.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Changes to the bootstrap baseline are handled by updating module `init` behavior and documentation.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and repeatable initialization.

### Glossary and Terminology

Workspace bootstrap: the initial creation of baseline datasets and schemas in a new repository.  
Module-owned initialization: each module creates its own datasets during bootstrap.

---

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
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
