---
title: bus-config — create and update workspace configuration
description: bus config owns workspace-level configuration stored in datapackage.json at the workspace root.
---

## `bus-config` — create and update workspace configuration

### Synopsis

`bus config init [--base-currency <code>] [--legal-form <tmi|oy|ay|ky|osk>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>] [--reporting-standard <fi-kpa|fi-pma>] [--report-language <fi>] [--income-statement-scheme <by_nature|by_function>] [--comparatives <true|false>] [--presentation-currency <EUR>] [--presentation-unit <EUR|TEUR>] [--prepared-under-pma <true|false>] [--signature-date <YYYY-MM-DD>] [--signature-signer <name[:role]> ...] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus config set [--base-currency <code>] [--legal-form <tmi|oy|ay|ky|osk>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>] [--reporting-standard <fi-kpa|fi-pma>] [--report-language <fi>] [--income-statement-scheme <by_nature|by_function>] [--comparatives <true|false>] [--presentation-currency <EUR>] [--presentation-unit <EUR|TEUR>] [--prepared-under-pma <true|false>] [--signature-date <YYYY-MM-DD>] [--signature-signer <name[:role]> ...] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus config set base-currency <code>`  
`bus config set fiscal-year-start <YYYY-MM-DD>`  
`bus config set fiscal-year-end <YYYY-MM-DD>`  
`bus config set vat-registered <true|false>`  
`bus config set vat-reporting-period <monthly|quarterly|yearly>`  
`bus config set vat-timing <performance|invoice|cash>`  
`bus config set vat-registration-start <YYYY-MM-DD>`  
`bus config set vat-registration-end <YYYY-MM-DD>`  
`bus config set reporting-standard <fi-kpa|fi-pma>`  
`bus config set report-language <fi>`  
`bus config set income-statement-scheme <by_nature|by_function>`  
`bus config set comparatives <true|false>`  
`bus config set presentation-currency <EUR>`  
`bus config set presentation-unit <EUR|TEUR>`  
`bus config set prepared-under-pma <true|false>`  
`bus config set signature-date <YYYY-MM-DD>`

All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus config` owns workspace-level configuration stored in `datapackage.json` at the workspace root.

The workspace file holds [accounting entity](../master-data/accounting-entity/index) settings (base currency, legal-form profile, fiscal year boundaries, VAT registration, VAT cadence/timing, optional VAT registration dates, and Finnish statutory reporting profile keys). Other modules read these values instead of duplicating settings in row-level datasets.

The Finnish statutory reporting profile lives under `busdk.accounting_entity.reporting_profile.fi_statutory` in the workspace descriptor.

All VAT-related configuration keys and Finnish statutory reporting-profile keys are defined here. [bus vat](./bus-vat), [bus reports](./bus-reports), and filing modules consume these settings.

The **current** reporting period and registration dates are inputs. The actual sequence of VAT period boundaries (including transitions and partial periods) is owned by [bus vat](./bus-vat).

`bus config init` creates or ensures `datapackage.json` with a valid `busdk.accounting_entity` object.

When the file is missing, it uses the bus-data library to create the empty descriptor first, then adds the accounting entity subtree.

You can pass the same optional accounting-entity flags as for `set` (for example `--base-currency`, `--vat-registered`) so the initial descriptor starts with correct values. Omitted flags use property defaults.

When the file already has that object, init prints a warning and does nothing (flags are ignored).

[bus init](./bus-init) always runs `bus config init` first. You can also run `bus config init` on its own when you only need the workspace descriptor.

`bus config set` updates accounting entity settings in an existing workspace `datapackage.json`. You can pass one or more optional flags (e.g. `bus config set --base-currency=EUR --vat-registered=true`) to change multiple properties in one call, or use the per-property form `bus config set <key> <value>` (e.g. `bus config set base-currency SEK`). Only the properties you specify are changed; others remain unchanged. The workspace must already contain `datapackage.json` with a `busdk.accounting_entity` object. Running `bus config set` with no property flags or values exits 0 without modifying the file.

To set a default agent runtime for [bus agent](./bus-agent) or [bus dev](./bus-dev), use those modules’ own commands (e.g. `bus agent set runtime <runtime>` or `bus preferences set bus-agent.runtime <runtime>`); agent preferences live in each module’s namespace in [bus-preferences](./bus-preferences).

### Commands

`init` — Create or ensure `datapackage.json` at the effective workspace root with a `busdk.accounting_entity` object. Accepts the same optional flags as `set` (batch form): `--base-currency`, `--legal-form`, `--fiscal-year-start`, `--fiscal-year-end`, `--vat-registered`, `--vat-reporting-period`, `--vat-timing`, `--vat-registration-start`, `--vat-registration-end`, `--reporting-standard`, `--report-language`, `--income-statement-scheme`, `--comparatives`, `--presentation-currency`, `--presentation-unit`, `--prepared-under-pma`, `--signature-date`, and repeatable `--signature-signer`. When the file is missing or does not contain that object, it is created or updated; any provided flag sets that property (others use defaults). When the file already contains `busdk.accounting_entity`, the command prints a warning to stderr and exits 0 without modifying the file; flags are ignored. No extra positional arguments are accepted.

`set` — Update accounting entity settings in the workspace `datapackage.json`.

Two forms are supported. Batch form is `bus config set [--base-currency ...] [--signature-signer ...]`, where only provided flags are applied and no flags means no change. Per-property form is `bus config set <key> <value>`, where `<key>` must be one of the documented accounting-entity keys.

`set` requires an existing workspace with `datapackage.json` and `busdk.accounting_entity`. Unknown `<key>` is invalid usage (exit 2).

### Global flags

These commands use [Standard global flags](../cli/global-flags). In practice, the most used here are `-C/--chdir` for workspace selection, `-o/--output` for machine output capture, and `-q`/`-v` for output control. `--quiet` and `--verbose` are mutually exclusive (usage error `2`). Results go to stdout (or `--output`), diagnostics to stderr.

### Init: behavior and defaults

`bus config init` creates `datapackage.json` when it is missing, or adds the `busdk.accounting_entity` subtree when the file exists but does not yet have it. The initial shape follows [workspace configuration](../data/workspace-configuration). Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, `vat_timing` `performance`, and fiscal year and VAT registration as documented in the [workspace configuration](../data/workspace-configuration). The Finnish statutory reporting profile defaults are `reporting_standard=fi-kpa`, `language=fi`, `income_statement_scheme=by_nature`, `comparatives=true`, `presentation_currency=EUR`, `presentation_unit=EUR`, `prepared_under_pma=false`, and an empty signature date with optional signer list. You can set correct values from the start by passing the same optional flags as for `set`; omit a flag to use the default for that property. You can adjust values afterward with `bus config set`.

### Set: options and behavior

`bus config set` updates only the fields you pass. You can use the batch form with optional flags or the per-property form `bus config set <key> <value>`.

In batch form, omit a flag to leave that property unchanged. Supported properties cover base currency, fiscal-year boundaries, VAT registration/cadence/timing, optional VAT registration date bounds, Finnish statutory reporting profile defaults, and optional statement signature metadata. All values use strict validation (for example ISO currency code and `YYYY-MM-DD` dates), and invalid values return usage error `2`.

In per-property form, `bus config set <key> <value>`, `<key>` must be one of the documented accounting-entity keys. Unknown keys return usage error `2`. Signer metadata is managed through repeatable `--signature-signer` in batch form.

Example: for yearly VAT reporting and cash-based timing, run `bus config set vat-reporting-period yearly` and `bus config set vat-timing cash`, or in one call `bus config set --vat-reporting-period=yearly --vat-timing=cash`. For Finnish statutory reporting defaults, run `bus config set --reporting-standard=fi-kpa --income-statement-scheme=by_nature --comparatives=true --signature-date=2026-03-31 --signature-signer "Board Chair:board"`.

Set requires an existing workspace. If `datapackage.json` is missing in the effective workspace directory, the command fails with “datapackage.json not found”. If the file exists but does not contain a `busdk.accounting_entity` object (e.g. a minimal package with no BusDK extension), it fails with “missing busdk.accounting_entity”. In both cases the message is on stderr and the exit code is non-zero.

### Examples

```bash
bus config init \
  --base-currency EUR \
  --fiscal-year-start 2026-01-01 \
  --fiscal-year-end 2026-12-31 \
  --vat-registered true \
  --vat-reporting-period monthly \
  --vat-timing performance
bus config set reporting-standard fi-pma
```

### Files

The module reads and writes `datapackage.json` at the workspace root. The `init` subcommand creates the workspace file or ensures the `busdk.accounting_entity` subtree exists. The `set` subcommand updates only that subtree in place. Path resolution for the workspace configuration file is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status and errors

Exit 0 on success. Non-zero in these cases:
invalid usage returns exit `2` (for example invalid flag value, unknown key, or conflicting flags), and `set` precondition failures return non-zero when `datapackage.json` or `busdk.accounting_entity` is missing.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus config set --base-currency EUR --vat-registered true --vat-reporting-period monthly
config set --base-currency EUR --vat-registered true --vat-reporting-period monthly

# same as: bus config set reporting-standard fi-pma
config set reporting-standard fi-pma
```


### Development state

**Value promise:** Create and update workspace configuration (`datapackage.json`) and accounting-entity settings so every BusDK workspace has a single, schema-valid source for currency, fiscal year, and VAT settings.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview).

**Completeness:** 90% — init and set (batch and per-property) verified by e2e and unit tests; idempotent init and deterministic entity updates; only set no-flags no-op (no write, no message) not yet verified.

**Use case readiness:** Accounting workflow: 90% — workspace-config step verified; user can create/update entity before domain inits; set no-flags no-op not verified.

**Current:** Init and set (batch and per-property), plus global-flag behavior, are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-config](../sdd/bus-config).

**Planned next:** Set with no property flags: exit 0 without writing and without printing "Updated datapackage.json." (PLAN.md); advances scriptability for the accounting workflow.

**Blockers:** None known.

**Depends on:** [bus-data](./bus-data) (Go library) for creating the empty `datapackage.json` when the file is missing.

**Used by:** [bus-init](./bus-init) runs `bus config init` first.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Workspace configuration (datapackage.json extension)](../data/workspace-configuration)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [bus-reports CLI reference](../modules/bus-reports)
- [bus-reports SDD](../sdd/bus-reports)
- [Module SDD: bus-config](../sdd/bus-config)
- [Workflow: Initialize repo](../workflow/initialize-repo)
- [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv)
- [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos)
- [PRH: Tilinpäätösilmoituksen asiakirjat kaupparekisteriin](https://www.prh.fi/fi/yrityksetjayhteisot/tilinpaatokset/ilmoituksen_liitteet.html)
- [Finlex: Kirjanpitolaki 1336/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1336)
- [Finlex: Kirjanpitoasetus 1339/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1339)
- [Finlex: Valtioneuvoston asetus 1753/2015 (PMA)](https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2015/1753)
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
