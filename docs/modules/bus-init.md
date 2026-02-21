---
title: bus-init — initialize a new BusDK workspace
description: bus init creates workspace configuration (datapackage.json) by default; domain module inits run only when you pass per-module flags.
---

## `bus-init` — initialize a new BusDK workspace

### Synopsis

`bus init [defaults | all] [--no-accounts] [--no-entities] [--no-period] [--no-journal] [--no-invoices] [--no-vat] [--no-attachments] [--no-bank] [--no-budget] [--no-assets] [--no-inventory] [--no-loans] [--no-payroll] [--accounts] [--entities] [--period] [--journal] [--invoices] [--vat] [--attachments] [--bank] [--budget] [--assets] [--inventory] [--loans] [--payroll] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`

Run `bus init` or `bus init defaults` for config only; run `bus init all` for the full baseline (use `--no-<name>` to exclude modules); or pass one or more per-module flags to include only those modules’ baselines. All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`. To create or update accounting entity settings after init, use [bus config](./bus-config).

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus init` always runs `bus config init` so `datapackage.json` and accounting entity settings exist.

With no subcommand (or `defaults`) and no module flags, it stops after config init.

With subcommand `all`, it runs config init and then all thirteen module inits (optionally excluding some with `--no-<name>`).

With selected module flags (without `all`), it runs only those modules in deterministic order.

Each module owns its own datasets and schemas. `bus init` itself does not perform Git or network operations.

### Commands

**Initialize the workspace.** Effective root is current directory or `-C` / `--chdir`.

The command always runs `bus config init` first.

With no subcommand (or `defaults`) and no module flags, only config init runs.

With subcommand `all`, all thirteen data-owning module inits run in deterministic order (minus `--no-<name>` exclusions).

With explicit module flags, only selected modules run in deterministic order.

Success depends on exit codes of executed steps. `bus init` does not validate a fixed baseline-file list afterward.

### Subcommands and module-include flags

**Subcommands** select a named module set so that set names do not clash with module names (e.g. a future `bus init sheets` can denote a sheets-related set without conflicting with the bus-sheets module).

`defaults` (or no subcommand with no module flags) runs only `bus config init`, creating `datapackage.json` and accounting entity settings but no domain datasets. `all` runs config init and then all thirteen data-owning module inits in order. You can exclude modules with `--no-<name>`, for example `bus init all --no-payroll`. When the subcommand is not `all`, `--no-<name>` flags are ignored.

**Per-module flags** (below) add individual modules when you do not use the `all` subcommand. Each also has a matching `--no-<name>` that excludes that module when used with `bus init all`. With no subcommand and no flags (or subcommand `defaults`), only `bus config init` runs.

The module flags are `--accounts`, `--entities`, `--period`, `--journal`, `--invoices`, `--vat`, `--attachments`, `--bank`, `--budget`, `--assets`, `--inventory`, `--loans`, and `--payroll`. Each flag runs that module’s `init` after config init. When several flags are provided, they run in deterministic order.

When multiple flags are given, module inits run in the order listed above. To get the full baseline (all data-owning modules), use `bus init all`.

**Examples.** `bus init` or `bus init defaults` creates only `datapackage.json` and accounting entity settings. `bus init --accounts --entities --journal` creates config, then the accounts, entities, and journal baselines in that order. `bus init all` creates the full baseline (config plus all thirteen data-owning modules). `bus init all --no-payroll` creates the full baseline except payroll.

### Global flags

These flags apply to `init`. They match the [standard global flags](../cli/global-flags) shared by most BusDK modules. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are treated as positional arguments (extra positional arguments for `init` are invalid).

`-h` and `--help` print help to stdout and exit 0. `-V` and `--version` print tool name and version and exit 0.

`-v` and `--verbose` increase diagnostics on stderr and can be repeated. `-q` and `--quiet` suppress normal output and keep only errors. Quiet and verbose cannot be combined; that is usage error exit 2.

`-C <dir>` and `--chdir <dir>` set the effective workspace directory used by `bus config init` and module init steps. `-o <file>` and `--output <file>` redirect normal output to a file under that effective directory. If output and quiet are both set, quiet wins and no output file is written.

`--color <auto|always|never>` controls colored human-facing stderr output. `--no-color` is the same as `--color=never`.

Command results (e.g. help or version) are written to stdout. Diagnostics, progress, and error messages are written to stderr so that scripts can capture results without mixing in human-oriented text.

### Init: step order and baseline files

The command always runs `bus config init` first.

That step ensures `datapackage.json` exists and adds accounting entity settings.

Each selected module step is implemented by that module’s own `init` command.

If a module baseline already exists in full, that module warns and exits 0. If baseline exists partially, that module fails without modifying files.

The tool depends on `bus` dispatcher being available in `PATH`.

The initial `datapackage.json` is created by `bus config init` and follows the [workspace configuration](../data/workspace-configuration) shape. Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, and fiscal year and VAT registration set as documented in the data package extension. You can adjust these afterward with [bus config configure](./bus-config).

### Examples

```bash
bus init all --no-payroll --no-loans
bus init --accounts --entities --period --journal
bus init defaults
```

### Files

The command invokes `bus config init` (which creates or ensures `datapackage.json`) and, when module flags are supplied, each selected domain module’s init so that those modules’ datasets and schema files appear in the workspace root. With no module flags, only `datapackage.json` is created. Bus init does not write any files directly; it only orchestrates the sequence. Success is determined by each step’s exit code, not by a post-hoc check of baseline paths.

### Exit status and errors

Exit 0 on success. Non-zero in these cases:

Invalid usage returns exit `2`, for example unknown flags, invalid flag values, quiet+verbose conflicts, or extra positional arguments.

Missing dispatcher returns exit `1` when `bus` is not found in `PATH`.

If any module init step fails, `bus init` stops immediately and returns that failure. If a module exits `2` for compatibility/version reasons, the command reports that the module must be upgraded and stops.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus init --help
init --help

# same as: bus init -V
init -V

# config only
init defaults

# selected modules
init --accounts --entities --period --journal
```


### Development state

**Value promise:** Bootstrap a BusDK workspace with config only or with a full baseline (config plus all 13 data-owning module inits) so users can complete the “create repo and baseline” step deterministically.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview) (step 1: create repo and baseline).

**Completeness:** 70% — User can run config-only or full-baseline init; e2e and unit tests verify step order, exclusions, and global flags.

**Use case readiness:** Accounting workflow: 70% — Config-only and full baseline (subcommand `all` or `--all`) verified; step order and `--no-<module>` exclusions proven by tests.

**Current:** `tests/e2e.sh` verifies config-only (no subcommand or `defaults`), subcommand `all` and `all --no-payroll`, per-module flags, `-C`/`--output`/`--quiet`, missing bus and step-failure diagnostics, and extra-positional rejection. `internal/businit/run_test.go` covers config-only, `--all` and subcommand `all`/`defaults`, exclusions, step failure and exit-code-2 upgrade message, and `internal/cli/flags_test.go` covers flag parsing (`-vv`, `--`, quiet+verbose, color, subcommand parsing).

**Planned next:** Help text that lists each per-module flag and each `--no-<module>` explicitly (PLAN.md; FR-INIT-005 acceptance). Advances SDD/help completeness, not a new journey step.

**Blockers:** None known.

**Depends on:** Orchestrates [bus-config](./bus-config) and each domain module’s init; no direct code dependency.

**Used by:** The [bus](./bus) dispatcher invokes this when users run `bus init`.

See [Development status](../implementation/development-status).

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
