---
title: bus-config — create and update workspace configuration
description: bus config owns workspace-level configuration stored in datapackage.json at the workspace root.
---

## bus-config

### Name

`bus config` — create and update workspace configuration.

### Synopsis

`bus config init [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus config configure [--base-currency <code>] [--fiscal-year-start <YYYY-MM-DD>] [--fiscal-year-end <YYYY-MM-DD>] [--vat-registered <true|false>] [--vat-reporting-period <monthly|quarterly>] [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus config set agent <runtime>`  
`bus config get agent [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`

All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`. The `set agent` and `get agent` commands operate on user-level bus configuration and do not require a workspace.

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus config` owns workspace-level configuration stored in `datapackage.json` at the workspace root and user-level bus configuration stored in a dedicated config file. The workspace file holds [accounting entity](../master-data/accounting-entity/index) settings (base currency, fiscal year boundaries, VAT registration, VAT reporting cadence) as BusDK metadata so other modules can read them without duplicating settings in row-level datasets. The user-level bus configuration holds preferences that apply across invocations, such as the default agent runtime used by [bus agent](./bus-agent) and [bus dev](./bus-dev); that preference is read and written by the bus-agent module through the bus-config library so that the chosen agent is saved in bus configuration.

`bus config init` creates or ensures `datapackage.json` with a valid `busdk.accounting_entity` object. When the file already has that object, init prints a warning and does nothing. [bus init](./bus-init) always runs `bus config init` first; when you pass module-include flags (e.g. `--accounts`, `--journal`), it then runs each selected domain module’s init. You can also run `bus config init` on its own when you need only the workspace descriptor.

`bus config configure` updates accounting entity settings in an existing workspace `datapackage.json`. The workspace must already contain `datapackage.json` with a `busdk.accounting_entity` object. Only the properties you pass via flags are changed; others remain unchanged.

`bus config set agent <runtime>` saves the default agent runtime to bus configuration. The value is persisted so that [bus agent](./bus-agent) and [bus dev](./bus-dev) use that runtime when you do not pass `--agent` or set a session variable. `<runtime>` must be one of `cursor`, `codex`, `gemini`, or `claude`; any other value is invalid usage (exit 2). You do not need to be in a workspace to set or get the default agent.

`bus config get agent` prints the current default agent from bus configuration to stdout. If none is set, the command may print nothing or a documented sentinel; see `bus config get agent --help` for the current behavior.

### Commands

`init` — Create or ensure `datapackage.json` at the effective workspace root with a `busdk.accounting_entity` object. If the file is missing or does not contain that object, it is created or updated with default values. If it already contains `busdk.accounting_entity`, the command prints a warning to stderr and exits 0 without modifying the file. No extra positional arguments are accepted.

`configure` — Edit accounting entity settings (base currency, fiscal year boundaries, VAT registration, VAT reporting cadence) in the workspace `datapackage.json`. Requires an existing workspace that already has `datapackage.json` and a `busdk.accounting_entity` object. Only the flags you provide are applied. No extra positional arguments are accepted.

`set agent <runtime>` — Save the default agent runtime to bus configuration. The [bus-agent](./bus-agent) and [bus-dev](./bus-dev) modules read this value via the bus-config library when no per-command or session preference is set. `<runtime>` must be one of `cursor`, `codex`, `gemini`, or `claude`. Does not require a workspace.

`get agent` — Print the current default agent from bus configuration to stdout. Does not require a workspace.

### Global flags

These flags apply to both `init` and `configure`. They match the [standard global flags](../cli/global-flags) shared by most BusDK modules. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are treated as positional arguments (and for `init` and `configure`, extra positionals are invalid).

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

`bus config init` creates `datapackage.json` when it is missing, or adds the `busdk.accounting_entity` subtree when the file exists but does not yet have it. The initial shape follows [workspace configuration](../data/workspace-configuration). Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, and fiscal year and VAT registration as documented in the data package extension. You can adjust these afterward with `bus config configure`.

### Configure: options and behavior

`bus config configure` updates only the fields you pass. Omit a flag to leave that property unchanged. The following flags map to [accounting entity](../master-data/accounting-entity/index) properties in `datapackage.json`:

- **`--base-currency <code>`** — ISO 4217 currency code. Must be uppercase (e.g. `EUR`, `SEK`). Lowercase or invalid codes are a usage error (exit 2).
- **`--fiscal-year-start <date>`** — Fiscal year start in `YYYY-MM-DD` form. Slash or other formats are invalid and yield a usage error.
- **`--fiscal-year-end <date>`** — Fiscal year end in `YYYY-MM-DD` form. Same validation as start.
- **`--vat-registered <true|false>`** — Exactly `true` or `false`. Any other value is a usage error.
- **`--vat-reporting-period <period>`** — Allowed values are `monthly` and `quarterly`. Other values (e.g. `yearly`) are invalid and exit with a usage error.

Configure requires an existing workspace. If `datapackage.json` is missing in the effective workspace directory, the command fails with “datapackage.json not found”. If the file exists but does not contain a `busdk.accounting_entity` object (e.g. a minimal package with no BusDK extension), it fails with “missing busdk.accounting_entity”. In both cases the message is on stderr and the exit code is non-zero.

### Files

The module reads and writes `datapackage.json` at the workspace root for workspace configuration and a dedicated user-level config file for bus configuration (e.g. default agent). The `init` subcommand creates the workspace file or ensures the `busdk.accounting_entity` subtree exists. The `configure` subcommand updates only that subtree in place. The `set agent` and `get agent` commands read and write the user-level bus configuration file; the exact path is documented in the [module SDD](../sdd/bus-config).

### Exit status and errors

Exit 0 on success. Non-zero in these cases:

- **Invalid usage (exit 2)** — Unknown or invalid flag value (e.g. invalid `--color`, invalid `--base-currency` or date or `--vat-reporting-period`), combining `--quiet` and `--verbose`, or extra positional arguments for `init` or `configure`. The tool prints a short usage-style error to stderr.
- **Configure preconditions (exit non-zero)** — `configure` was run in a directory without `datapackage.json` or without `busdk.accounting_entity`; see above.

---

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
- [bus-agent CLI reference](./bus-agent)
- [bus-dev CLI reference](./bus-dev)
- [Workflow: Initialize repo](../workflow/initialize-repo)
