---
title: bus-init — initialize a new BusDK workspace
description: bus init creates workspace configuration (datapackage.json) by default; domain module inits run only when you pass per-module flags.
---

## bus-init

### Name

`bus init` — initialize a new BusDK workspace.

### Synopsis

`bus init [--all] [--no-accounts] [--no-entities] [--no-period] [--no-journal] [--no-invoices] [--no-vat] [--no-attachments] [--no-bank] [--no-budget] [--no-assets] [--no-inventory] [--no-loans] [--no-payroll] [--accounts] [--entities] [--period] [--journal] [--invoices] [--vat] [--attachments] [--bank] [--budget] [--assets] [--inventory] [--loans] [--payroll] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`

Running `bus init` creates or ensures workspace configuration. By default only workspace configuration is created (`datapackage.json` and [accounting entity](../master-data/accounting-entity/index) settings); no domain datasets are created. Pass `--all` to include every data-owning module, or one or more module flags to include only those modules’ baselines. All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`. To create or update accounting entity settings after init, use [bus config](./bus-config).

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus init` always runs `bus config init` so that `datapackage.json` and accounting entity settings exist. With no module flags and no `--all`, it stops there. When you pass `--all` or one or more module-include flags ( `--accounts`, `--entities`, `--period`, `--journal`, `--invoices`, `--vat`, `--attachments`, `--bank`, `--budget`, `--assets`, `--inventory`, `--loans`, `--payroll`), it then runs each selected module’s `init` in that order. Each module owns its own datasets and schemas; `bus init` does not perform Git or network operations. To change accounting entity settings afterward, use `bus config configure`.

### Commands

**Initialize the workspace.** The effective workspace root is the current directory, or the directory given by `-C` / `--chdir`. The command always runs `bus config init` first. With no module-include flags and no `--all`, it runs only that step and exits; the workspace then has `datapackage.json` but no domain datasets. When `--all` is supplied, it runs all thirteen data-owning module inits in order. When one or more module flags are supplied (and not `--all`), it then runs each selected module’s `init` in this order: accounts, entities, period, journal, invoices, vat, attachments, bank, budget, assets, inventory, loans, payroll (only the modules whose flag was passed are run, in this order). Success is determined only by the exit codes of the steps that run. The command does not check for a fixed list of baseline paths afterward; each module is responsible for creating its own files and for failing its init if it cannot. The command does not accept extra positional arguments — anything after the subcommand is rejected with a usage error.

### Module-include flags

**`--all`** — Run all thirteen data-owning module inits after config init (same as passing every per-module flag below). If you pass `--all` together with other module flags, `--all` takes precedence and all modules are initialized. You can exclude specific modules by adding the corresponding **`--no-<name>`** flag (e.g. `--no-payroll`, `--no-budget`); for example, `bus init --all --no-payroll` initializes config and all data-owning modules except payroll. When `--all` is not present, `--no-<name>` flags are ignored.

Each per-module flag below includes that module’s baseline in the init sequence; each also has a matching `--no-<name>` that excludes that module when used with `--all` (e.g. `--no-accounts`, `--no-payroll`). With no flags and no `--all`, only `bus config init` runs.

- **`--accounts`** — Run `bus accounts init` after config init (chart of accounts).
- **`--entities`** — Run `bus entities init` after config init (counterparties).
- **`--period`** — Run `bus period init` after config init (period control).
- **`--journal`** — Run `bus journal init` after config init (journal index).
- **`--invoices`** — Run `bus invoices init` after config init (sales and purchase invoices).
- **`--vat`** — Run `bus vat init` after config init (VAT reference data and reports).
- **`--attachments`** — Run `bus attachments init` after config init (evidence index).
- **`--bank`** — Run `bus bank init` after config init (bank imports and transactions).
- **`--budget`** — Run `bus budget init` after config init (budget dataset; optional for statutory bookkeeping).
- **`--assets`** — Run `bus assets init` after config init (fixed-asset register and depreciation datasets).
- **`--inventory`** — Run `bus inventory init` after config init (item master and movement datasets).
- **`--loans`** — Run `bus loans init` after config init (loan register and event datasets).
- **`--payroll`** — Run `bus payroll init` after config init (employee and payroll run datasets).

When multiple flags are given, module inits run in the order listed above. To get the full baseline (all data-owning modules), use `bus init --all`.

**Examples.** `bus init` with no flags creates only `datapackage.json` and accounting entity settings. `bus init --accounts --entities --journal` creates config, then the accounts, entities, and journal baselines in that order. `bus init --all` creates the full baseline (config plus all thirteen data-owning modules). `bus init --all --no-payroll` creates the full baseline except payroll.

### Global flags

These flags apply to `init`. They match the [standard global flags](../cli/global-flags) shared by most BusDK modules. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are treated as positional arguments (extra positional arguments for `init` are invalid).

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Help lists each module-include flag, `--all`, and the `--no-<name>` exclusion flags, and states that with no module flags only workspace configuration is initialized. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored.
- **`-v`**, **`--verbose`** — Send verbose progress and diagnostics to stderr. You can repeat the flag (e.g. `-vv` or `--verbose --verbose`) to increase verbosity. Verbose output does not change what is written to stdout or to the file given by `--output`.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, nothing is written to stdout and no output file is created or written even if `--output` is given; only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage and exits with code 2.
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory for the command. All workspace paths (e.g. `datapackage.json`, module datasets) are resolved relative to this directory. The same directory is used when invoking `bus config init` and each module’s `init`. If the directory does not exist or is not accessible, the command exits with code 1 and a clear error on stderr.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The path is relative to the effective working directory (after `-C`). The file is created or truncated. Errors and diagnostics still go to stderr. If both `--output` and `--quiet` are used, quiet wins: no output is written to the file.
- **`--color <mode>`** — Control colored output for human-facing messages on stderr. `<mode>` must be one of `auto`, `always`, or `never`. `auto` uses color only when stderr is a terminal; `always` forces color; `never` disables it. An invalid value (e.g. `neon`) is a usage error and exits with code 2.
- **`--no-color`** — Same as `--color=never`. If both are present, color is disabled.

Command results (e.g. help or version) are written to stdout. Diagnostics, progress, and error messages are written to stderr so that scripts can capture results without mixing in human-oriented text.

### Init: step order and baseline files

The command always runs `bus config init` first. With no module-include flags and no `--all`, it stops after that; the workspace then has only `datapackage.json` and accounting entity settings. When `--all` is supplied, it runs all thirteen data-owning module inits in order. When one or more module flags are supplied (and not `--all`), it then runs each selected module’s `init` in order: accounts, entities, period, journal, invoices, vat, attachments, bank, budget, assets, inventory, loans, payroll (only the modules whose flag was passed). Each step is implemented by the corresponding module (e.g. `bus config init`, `bus accounts init`). Each module’s `init` creates its baseline data only when absent; if the data already exists in full, the module prints a warning and does nothing; if the data exists only partially, the module fails with an error and does not modify any file. The tool depends on the `bus` dispatcher being available in your `PATH`; if `bus` is not found, the command exits with a clear “bus dispatcher not found in PATH” error. When every invoked command exits with code 0, the run is complete. The command does not verify a fixed list of baseline paths afterward; each module owns its datasets and schemas and is responsible for failing its init if it cannot create them.

The initial `datapackage.json` is created by `bus config init` and follows the [workspace configuration](../data/workspace-configuration) shape. Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, and fiscal year and VAT registration set as documented in the data package extension. You can adjust these afterward with [bus config configure](./bus-config).

### Files

The command invokes `bus config init` (which creates or ensures `datapackage.json`) and, when module flags are supplied, each selected domain module’s init so that those modules’ datasets and schema files appear in the workspace root. With no module flags, only `datapackage.json` is created. Bus init does not write any files directly; it only orchestrates the sequence. Success is determined by each step’s exit code, not by a post-hoc check of baseline paths.

### Exit status and errors

Exit 0 on success. Non-zero in these cases:

- **Invalid usage (exit 2)** — Unknown or invalid flag value (e.g. invalid `--color`), combining `--quiet` and `--verbose`, or extra positional arguments for `init`. The tool prints a short usage-style error to stderr.
- **Missing bus dispatcher (exit 1)** — `bus` is not found in `PATH`. Message: “bus dispatcher not found in PATH”.
- **Module init failure (exit non-zero)** — A module’s `init` command fails. The tool stops immediately after that step and reports “step failed: bus *module* init” (with the actual module name) on stderr. It does not run later steps.
- **Module compatibility (exit non-zero)** — A module exits with code 2, indicating a version or compatibility issue. The tool reports that the module “must be upgraded” and stops.
---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-config">bus-config</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus-init](../sdd/bus-init)
- [bus-config CLI reference](./bus-config)
- [Layout: Layout principles](../layout/layout-principles)
- [Workflow: Initialize repo](../workflow/initialize-repo)
