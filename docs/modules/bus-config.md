---
title: bus-config — create and update workspace configuration
description: bus config owns workspace-level configuration stored in datapackage.json at the workspace root.
---

## `bus-config` — create and update workspace configuration

### Synopsis

`bus config init [--base-currency <code>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus config set [--base-currency <code>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus config set base-currency <code>`  
`bus config set fiscal-year-start <YYYY-MM-DD>`  
`bus config set fiscal-year-end <YYYY-MM-DD>`  
`bus config set vat-registered <true|false>`  
`bus config set vat-reporting-period <monthly|quarterly|yearly>`  
`bus config set vat-timing <performance|invoice|cash>`  
`bus config set vat-registration-start <YYYY-MM-DD>`  
`bus config set vat-registration-end <YYYY-MM-DD>`

All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus config` owns workspace-level configuration stored in `datapackage.json` at the workspace root. The workspace file holds [accounting entity](../master-data/accounting-entity/index) settings (base currency, fiscal year boundaries, VAT registration, VAT reporting cadence, VAT timing basis, and optional VAT registration dates) as BusDK metadata so other modules can read them without duplicating settings in row-level datasets. All VAT-related configuration keys and allowed values are defined here; [bus vat](./bus-vat) and other modules consume these settings. The **current** reporting period and registration dates are inputs; the actual sequence of VAT period boundaries (including transitions within a year, 4-month or 18-month periods, and partial first/last periods) is owned and defined by [bus vat](./bus-vat).

`bus config init` creates or ensures `datapackage.json` with a valid `busdk.accounting_entity` object. When the file is missing, it uses the bus-data library to create the empty descriptor first, then adds the accounting entity subtree. You can pass the same optional accounting-entity flags as for `set` (e.g. `--base-currency`, `--vat-registered`) so that the initial descriptor has the correct values from the start; any flag you omit uses the default for that property. When the file already has that object, init prints a warning and does nothing (flags are ignored). [bus init](./bus-init) always runs `bus config init` first; when you pass module-include flags (e.g. `--accounts`, `--journal`), it then runs each selected domain module’s init. You can also run `bus config init` on its own when you need only the workspace descriptor. To create only an empty `datapackage.json` without accounting entity settings, use [bus data init](./bus-data) instead.

`bus config set` updates accounting entity settings in an existing workspace `datapackage.json`. You can pass one or more optional flags (e.g. `bus config set --base-currency=EUR --vat-registered=true`) to change multiple properties in one call, or use the per-property form `bus config set <key> <value>` (e.g. `bus config set base-currency SEK`). Only the properties you specify are changed; others remain unchanged. The workspace must already contain `datapackage.json` with a `busdk.accounting_entity` object. Running `bus config set` with no property flags or values exits 0 without modifying the file.

To set a default agent runtime for [bus agent](./bus-agent) or [bus dev](./bus-dev), use those modules’ own commands (e.g. `bus agent set runtime <runtime>` or `bus preferences set bus-agent.runtime <runtime>`); agent preferences live in each module’s namespace in [bus-preferences](./bus-preferences).

### Commands

`init` — Create or ensure `datapackage.json` at the effective workspace root with a `busdk.accounting_entity` object. Accepts the same optional flags as `set` (batch form): `--base-currency`, `--fiscal-year-start`, `--fiscal-year-end`, `--vat-registered`, `--vat-reporting-period`, `--vat-timing`, `--vat-registration-start`, `--vat-registration-end`. When the file is missing or does not contain that object, it is created or updated; any provided flag sets that property (others use defaults). When the file already contains `busdk.accounting_entity`, the command prints a warning to stderr and exits 0 without modifying the file; flags are ignored. No extra positional arguments are accepted.

`set` — Update accounting entity settings in the workspace `datapackage.json`. Two forms are supported. (1) **Batch:** `bus config set [--base-currency <code>] [--fiscal-year-start <date>] [--fiscal-year-end <date>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly|yearly>] [--vat-timing <performance|invoice|cash>] [--vat-registration-start <YYYY-MM-DD>] [--vat-registration-end <YYYY-MM-DD>]` — only the flags you provide are applied; no flags means no change. (2) **Per-property:** `bus config set <key> <value>` where `<key>` is one of `base-currency`, `fiscal-year-start`, `fiscal-year-end`, `vat-registered`, `vat-reporting-period`, `vat-timing`, `vat-registration-start`, `vat-registration-end`. Requires an existing workspace that already has `datapackage.json` and a `busdk.accounting_entity` object. Unknown `<key>` is invalid usage (exit 2).

### Global flags

These flags apply to both `init` and `set`. They match the [standard global flags](../cli/global-flags) shared by most BusDK modules. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are treated as positional arguments (and for `init`, extra positionals are invalid; for `set`, the per-property form expects exactly `<key> <value>` after `set`).

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored.
- **`-v`**, **`--verbose`** — Send verbose progress and diagnostics to stderr. You can repeat the flag (e.g. `-vv` or `--verbose --verbose`) to increase verbosity. Verbose output does not change what is written to stdout or to the file given by `--output`.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, nothing is written to stdout and no output file is created or written even if `--output` is given; only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage and exits with code 2.
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory for the command. All workspace paths (e.g. `datapackage.json`) are resolved relative to this directory. If the directory does not exist or is not accessible, the command exits with code 1 and a clear error on stderr.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The path is relative to the effective working directory (after `-C`). The file is created or truncated. Errors and diagnostics still go to stderr. If both `--output` and `--quiet` are used, quiet wins: no output is written to the file.
- **`--color <mode>`** — Control colored output for human-facing messages on stderr. `<mode>` must be one of `auto`, `always`, or `never`. `auto` uses color only when stderr is a terminal; `always` forces color; `never` disables it. An invalid value is a usage error and exits with code 2.
- **`--no-color`** — Same as `--color=never`. If both are present, color is disabled.

Command results (e.g. help or version) are written to stdout. Diagnostics, progress, and error messages are written to stderr so that scripts can capture results without mixing in human-oriented text.

### Init: behavior and defaults

`bus config init` creates `datapackage.json` when it is missing, or adds the `busdk.accounting_entity` subtree when the file exists but does not yet have it. The initial shape follows [workspace configuration](../data/workspace-configuration). Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, `vat_timing` `performance`, and fiscal year and VAT registration as documented in the [workspace configuration](../data/workspace-configuration). You can set correct values from the start by passing the same optional flags as for `set` (e.g. `bus config init --base-currency=SEK --vat-registered=true`); omit a flag to use the default for that property. You can adjust values afterward with `bus config set`.

### Set: options and behavior

`bus config set` updates only the fields you pass. You can use the batch form with optional flags or the per-property form `bus config set <key> <value>`.

**Batch form.** Omit a flag to leave that property unchanged. The following flags map to [accounting entity](../master-data/accounting-entity/index) properties in `datapackage.json`:

- **`--base-currency <code>`** — ISO 4217 currency code. Must be uppercase (e.g. `EUR`, `SEK`). Lowercase or invalid codes are a usage error (exit 2).
- **`--fiscal-year-start <date>`** — Fiscal year start in `YYYY-MM-DD` form. Slash or other formats are invalid and yield a usage error.
- **`--fiscal-year-end <date>`** — Fiscal year end in `YYYY-MM-DD` form. Same validation as start.
- **`--vat-registered <true|false>`** — Exactly `true` or `false`. Any other value is a usage error.
- **`--vat-reporting-period <period>`** — Allowed values: `monthly`, `quarterly`, `yearly`. Under Finnish rules, quarterly is allowed when turnover is below 100 000 EUR; yearly when below 30 000 EUR or for certain primary producers and visual artists. See [workspace configuration](../data/workspace-configuration). Other values are invalid (exit 2).
- **`--vat-timing <basis>`** — Which date determines VAT period allocation: `performance` (delivery/performance date; suoriteperuste), `invoice` (period in which customer is charged; laskutusperuste), or `cash` (payment date for sales and purchases; maksuperuste). Cash basis is subject to turnover eligibility (500 000 EUR) and a 12‑month latest-allocation rule per [Vero guidance](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv). Other values are invalid (exit 2).
- **`--vat-registration-start <YYYY-MM-DD>`** — Optional. Date from which the entity is VAT registered; used for partial first VAT period. Omit to leave unchanged; set only when applicable.
- **`--vat-registration-end <YYYY-MM-DD>`** — Optional. Date on which VAT registration ends; used for partial last VAT period. Omit to leave unchanged.

**Per-property form.** `bus config set <key> <value>` where `<key>` is one of: `base-currency`, `fiscal-year-start`, `fiscal-year-end`, `vat-registered`, `vat-reporting-period`, `vat-timing`, `vat-registration-start`, `vat-registration-end`. The same value rules apply as for the batch form. Unknown `<key>` is invalid usage (exit 2).

Example: for yearly VAT reporting and cash-based timing, run `bus config set vat-reporting-period yearly` and `bus config set vat-timing cash`, or in one call `bus config set --vat-reporting-period=yearly --vat-timing=cash`.

Set requires an existing workspace. If `datapackage.json` is missing in the effective workspace directory, the command fails with “datapackage.json not found”. If the file exists but does not contain a `busdk.accounting_entity` object (e.g. a minimal package with no BusDK extension), it fails with “missing busdk.accounting_entity”. In both cases the message is on stderr and the exit code is non-zero.

### Files

The module reads and writes `datapackage.json` at the workspace root. The `init` subcommand creates the workspace file or ensures the `busdk.accounting_entity` subtree exists. The `set` subcommand updates only that subtree in place.

### Exit status and errors

Exit 0 on success. Non-zero in these cases:

- **Invalid usage (exit 2)** — Unknown or invalid flag value (e.g. invalid `--color`, invalid `--base-currency` or date or `--vat-reporting-period` on `init` or `set`), combining `--quiet` and `--verbose`, extra positional arguments for `init`, or unknown `<key>` in `bus config set <key> <value>`. The tool prints a short usage-style error to stderr.
- **Set preconditions (exit non-zero)** — `set` was run in a directory without `datapackage.json` or without `busdk.accounting_entity`; see above.

### Development state

**Value promise:** Create and update workspace configuration (`datapackage.json`) and accounting-entity settings so every BusDK workspace has a single, schema-valid source for currency, fiscal year, and VAT settings.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview).

**Completeness:** 90% — init and set (batch and per-property) verified by e2e and unit tests; idempotent init and deterministic entity updates; only set no-flags no-op (no write, no message) not yet verified.

**Use case readiness:** Accounting workflow: 90% — workspace-config step verified; user can create/update entity before domain inits; set no-flags no-op not verified.

**Current:** `tests/e2e_bus_config.sh` proves init creates `datapackage.json` with default entity and exact JSON shape, init idempotent when entity already present (warn, no write), set batch and per-property with deterministic output, precondition failures (missing file or entity), and global flags (help, version, invalid color, quiet+verbose, --output, --quiet, -C, --). `internal/run/run_test.go` covers init, set, chdir, output, quiet, and unknown subcommand. `internal/cli/flags_test.go`, `internal/config/validate_test.go`, and `internal/config/datapackage_test.go` cover flag parsing, entity validation, and datapackage read/write.

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
- [Module SDD: bus-config](../sdd/bus-config)
- [Workflow: Initialize repo](../workflow/initialize-repo)
- [Vero: Pienet yritykset voivat tilittää arvonlisäveron maksuperusteisesti](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/vahainen-liiketoiminta-on-arvonlisaverotonta/pienyrityksen-maksuperusteinen-alv)
- [Vero: Arvonlisäveron verokausi ja sen muutokset](https://vero.fi/yritykset-ja-yhteisot/verot-ja-maksut/arvonlisaverotus/ilmoitus-ja-maksuohjeet/verokauden-muutos)
