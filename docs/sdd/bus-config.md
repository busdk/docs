---
title: bus-config — workspace configuration, accounting entity settings (SDD)
description: Bus Config owns workspace-level configuration stored in datapackage.json at the workspace root.
---

## bus-config — workspace configuration, accounting entity settings

### Introduction and Overview

Bus Config owns workspace-level configuration stored in `datapackage.json` at the workspace root. The workspace descriptor holds the BusDK extension metadata (the `busdk.accounting_entity` object) that defines accounting entity settings — base currency, fiscal year boundaries, VAT registration, VAT reporting cadence, VAT timing basis, and optional VAT registration dates for partial first or last periods. Other modules read these settings when they validate, post, reconcile, report, or produce filings.

The module provides a dedicated CLI surface for configuration so that editing workspace settings is separate from bootstrapping a new workspace. Bootstrap is orchestrated by [bus-init](./bus-init), which invokes `bus config init` first to create or ensure `datapackage.json`; when the user supplies module-include flags, it then runs each selected domain module’s `init`. Bus Config is the sole owner of the workspace configuration file and the accounting entity subtree. It does not own domain datasets (chart of accounts, parties, journals, and so on), which remain owned by their respective modules. Agent runtime preferences are owned by modules that use the agent (e.g. [bus-agent](./bus-agent), [bus-dev](./bus-dev)); those modules set their defaults in their own namespaces via [bus-preferences](./bus-preferences).

### Requirements

FR-CFG-001 Workspace configuration creation. The module MUST provide an `init` command that creates or ensures `datapackage.json` at the workspace root with a valid `busdk.accounting_entity` object. When the file already exists and already contains `busdk.accounting_entity`, `init` MUST print a warning to standard error and exit with code 0 without modifying the file. When the file is missing or does not contain `busdk.accounting_entity`, `init` MUST create or update it so that the descriptor conforms to the [workspace configuration](../data/workspace-configuration) shape. The `init` command MUST accept the same optional accounting-entity flags as `set` (batch form): `--base-currency`, `--fiscal-year-start`, `--fiscal-year-end`, `--vat-registered`, `--vat-reporting-period`, `--vat-timing`, `--vat-registration-start`, `--vat-registration-end`. When init creates or adds the `busdk.accounting_entity` subtree, any provided flag overrides the default for that property; when the file already contains `busdk.accounting_entity`, init does not write and the flags are ignored. Acceptance criteria: running `bus config init` in an empty directory creates `datapackage.json` with default accounting entity settings; running it again yields a warning and no write; running `bus config init --base-currency=SEK` in an empty directory creates the descriptor with `base_currency` `SEK` and other defaults; running init in a directory that has a minimal data package without the BusDK extension adds the subtree, with any provided flags applied.

FR-CFG-002 Accounting entity settings update. The module MUST support updating accounting entity properties in an existing workspace `datapackage.json` without re-running init. The module MUST provide (1) a batch form `bus config set [--base-currency <code>] [--fiscal-year-start <date>] [--fiscal-year-end <date>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>]` where only provided flags alter the stored value, and (2) per-property forms `bus config set <key> <value>` where `<key>` is one of `base-currency`, `fiscal-year-start`, `fiscal-year-end`, `vat-registered`, `vat-reporting-period`, `vat-timing`, `vat-registration-start`, `vat-registration-end`. Acceptance criteria: both forms update only the specified properties; the command fails with a clear error if `datapackage.json` does not exist or does not contain `busdk.accounting_entity`; unknown key in the per-property form yields exit 2.

FR-CFG-003 Non-invasive operation. The module MUST not perform Git or network operations. Acceptance criteria: all commands only read and write the workspace `datapackage.json` (and only the BusDK extension subtree where applicable).

FR-CFG-004 Deterministic output. The module MUST emit deterministic diagnostics and fail with a clear message when preconditions are not met. Acceptance criteria: invalid usage or missing preconditions produce a deterministic error to standard error and a non-zero exit code.

NFR-CFG-001 Schema conformance. Values for `init` (when creating or adding the subtree) and for `set` (whether from flags or from per-property `<key> <value>`) MUST conform to the canonical schema in [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration). Invalid values produce a deterministic usage error and exit code 2.

### System Architecture

Bus Config is a small CLI module that reads and writes workspace configuration (`datapackage.json`). It depends on the [bus-data](./bus-data) Go library to create or ensure the empty descriptor when the file is missing; bus-config then adds or updates the `busdk.accounting_entity` subtree. The CLI is invoked directly by users when they want to create or change accounting entity settings; it is invoked by bus-init during bootstrap to ensure the workspace descriptor exists before domain module inits run. Bus Config does not invoke the `bus data` CLI; integration with bus-data is via the library only.

### Key Decisions

KD-CFG-001 Configuration as a dedicated module. Workspace configuration is owned by bus-config rather than bus-init so that the CLI surface is simplified: `bus init` means “bootstrap a new workspace,” and `bus config` means “create or edit workspace configuration.” Users and scripts can run `bus config set` without implying re-initialization.

KD-CFG-002 Init idempotency. `bus config init` is idempotent when the workspace already has a valid `busdk.accounting_entity` object. It does not overwrite existing configuration, which avoids accidental loss of user settings during re-runs or scripting.

KD-CFG-003 Datapackage bootstrap via bus-data library. When `datapackage.json` is missing, bus-config init MUST call the bus-data library (not the CLI) to create the empty descriptor at the workspace root before writing the `busdk.accounting_entity` subtree. This keeps a single implementation responsible for the base descriptor shape and formatting, and ensures bus-config and [bus-init](./bus-init) never shell out to `bus data` for bootstrap.

### Component Design and Interfaces

Interface IF-CFG-001 (init). The module is invoked as `bus config init [--base-currency <code>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>]` and follows BusDK CLI conventions for deterministic output and diagnostics. The command accepts no positional arguments. It creates or updates `datapackage.json` at the effective workspace root (current directory or the directory given by `-C` / `--chdir`). When the file is missing, init MUST call the bus-data library to create the empty descriptor (profile, empty resources) first; then init adds or updates the `busdk.accounting_entity` subtree. When the file exists but does not contain `busdk.accounting_entity`, init adds the subtree; any provided accounting-entity flag sets that property (others use defaults). When the file already contains `busdk.accounting_entity`, it exits 0 and prints a warning to stderr without writing; flags are ignored. Flag values must conform to the same schema as for `set`; invalid values produce exit code 2.

Interface IF-CFG-002 (set, batch). The module is invoked as `bus config set [--base-currency <code>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>]`. The command requires a workspace that already contains `datapackage.json` with a `busdk.accounting_entity` object. Only flags explicitly provided are written; other properties remain unchanged. Flag values must conform to the canonical schema; invalid values produce a deterministic usage error and exit code 2. When no property flags are given, the command exits 0 without modifying the file (no-op).

Interface IF-CFG-003 (set, per-property). The module is invoked as `bus config set <key> <value>` where `<key>` is one of: `base-currency`, `fiscal-year-start`, `fiscal-year-end`, `vat-registered`, `vat-reporting-period`, `vat-timing`, `vat-registration-start`, `vat-registration-end`. The command requires the same workspace preconditions as IF-CFG-002. Only the specified property is updated. Unknown `<key>` produces exit code 2 with a deterministic usage error. Value validation is the same as for the batch form.

**VAT timing.** The `vat_timing` property (CLI: `--vat-timing`, key: `vat-timing`) selects which date determines VAT period allocation. Allowed values: `performance` (suoriteperuste — allocation by delivery/performance date), `invoice` (laskutusperuste — allocation by the period in which the customer is charged), `cash` (maksuperuste — allocation by payment date for sales and purchases). Cash-based VAT applies only to domestic supplies; under Finnish rules, cash basis is available only when annual turnover does not exceed the eligibility threshold (500 000 EUR per Vero guidance), and VAT must be reported no later than 12 months after delivery or performance even if payment has not been received. When switching from cash to performance or invoice basis, previously unpaid sales must be reported in the next open VAT period. See [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv).

**VAT reporting period.** The `vat_reporting_period` property (CLI: `--vat-reporting-period`, key: `vat-reporting-period`) accepts `monthly`, `quarterly`, or `yearly`. It represents the **current** (or default) reporting period length for the entity. Under Finnish rules, the default is monthly; quarterly is allowed when turnover is below the threshold (100 000 EUR); yearly is allowed when turnover is below the lower threshold (30 000 EUR). Primary producers and visual artists (when not running other VAT-taxable business) typically have a yearly VAT period regardless of turnover. See [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos). Bus-config does not define the full sequence of VAT period boundaries; when the period length changes within a year (e.g. monthly → yearly → quarterly), or when there are transition or non-standard periods (e.g. 4-month transition, 18-month first period), the actual period list is owned and defined by the [bus-vat](./bus-vat) module.

**VAT registration dates.** Optional `vat_registration_start` (CLI: `--vat-registration-start`, key: `vat-registration-start`) and `vat_registration_end` (CLI: `--vat-registration-end`, key: `vat-registration-end`) are dates in `YYYY-MM-DD` form. They record when the entity became VAT registered or ceased to be registered. The [bus-vat](./bus-vat) module uses these as inputs when it builds or interprets the sequence of VAT periods (including partial first or last periods, and any non-standard period lengths). Bus-config only stores the dates; it does not compute period boundaries. See [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos).

Usage examples:

```bash
bus config init
bus config init --base-currency=SEK --vat-registered=true
bus config init --vat-reporting-period=yearly --vat-timing=cash
bus config set --base-currency=EUR --vat-registered=true
bus config set vat-timing cash
bus config set vat-reporting-period yearly
bus config set base-currency SEK
bus config set fiscal-year-start 2024-01-01
bus config set vat-registration-start 2025-03-15
```

### Data Design

The module owns **workspace configuration** only: `datapackage.json` at the workspace root. The descriptor contains both the Frictionless resource manifest and BusDK workspace-level configuration via the `busdk.accounting_entity` extension. The `init` command creates the file or ensures the `busdk.accounting_entity` subtree exists; it accepts the same optional accounting-entity flags as `set` so that initial values can be set from the start (any flag overrides the default for that property when creating or adding the subtree). The `set` command (batch or per-property) updates only the properties specified in an existing workspace. The module does not create or modify domain datasets (accounts, entities, journals, etc.); those are owned by other modules. User-level preferences (e.g. default agent runtime) are owned by the modules that use them and are stored via [bus-preferences](./bus-preferences) under each module’s namespace.

### Assumptions and Dependencies

Bus Config depends on the [bus-data](./bus-data) Go library for creating the empty `datapackage.json` when the file is missing; it MUST use the library interface only, not the `bus data` CLI. Bus Config depends on the standard workspace layout for workspace commands: the effective workspace root is the directory where `datapackage.json` is expected. It assumes the `bus` dispatcher is available when invoked. When invoked by bus-init during bootstrap, bus-config init runs before any domain module init so that the descriptor exists for modules that read it.

### Security Considerations

The module only reads and writes the workspace descriptor. Access controls are handled at the repository and filesystem level.

### Observability and Logging

Command results are written to standard output when applicable; diagnostics and warnings are written to standard error with deterministic messages.

### Error Handling and Resilience

Invalid usage or missing preconditions (e.g. `datapackage.json` not found, or `busdk.accounting_entity` missing for `set`) result in a non-zero exit and a concise error on stderr.

### Testing Strategy

Command-level tests exercise `bus config init` (with and without accounting-entity flags) and `bus config set` (batch and per-property forms) against fixture workspaces and verify that the descriptor is created or updated as specified, that init flags set initial values when creating the subtree, that idempotency and precondition checks behave as required, and that invalid flag values on init yield exit 2.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Existing workspaces that already have `datapackage.json` with `busdk.accounting_entity` are unchanged; they can use `bus config set` from the new module instead of the previous `bus init configure` command.

### Risks

Not Applicable beyond the need for deterministic, repeatable behavior when reading and writing the descriptor.

### Glossary and Terminology

**Workspace configuration:** the contents of `datapackage.json` at the workspace root, including the BusDK extension `busdk.accounting_entity`.

**Accounting entity settings:** the set of properties (base currency, fiscal year, VAT registration, VAT reporting period, VAT timing, optional VAT registration start/end) that apply to the whole workspace and are read by other modules.

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
- [bus-agent module SDD](./bus-agent)
- [Initialize repo](../workflow/initialize-repo)
- [Layout principles](../layout/layout-principles)
- [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti (cash basis, timing)](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv)
- [Vero: Arvonlisäveron verokausi ja sen muutokset (reporting period, thresholds)](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos)

### Document control

Title: bus-config module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-CFG`  
Version: 2026-02-15  
Status: Draft  
Last updated: 2026-02-15  
Owner: BusDK development team
