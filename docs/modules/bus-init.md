## bus-init

### Name

`bus init` — initialize a new BusDK workspace.

### Synopsis

`bus init [options]`  
`bus init init [options]`  
`bus init configure [options]`

Running `bus init` with no subcommand runs the bootstrap (same as `bus init init`). All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`.

### Description

`bus init` bootstraps a new workspace by writing workspace-level configuration and by running each module’s `init` command in a deterministic sequence. Each module owns its own datasets and schemas; `bus init` does not perform Git or network operations. The result is the standard workspace layout with baseline datasets and schemas, plus an initial `datapackage.json` that stores [accounting entity](../master-data/accounting-entity/index) settings for the workspace as BusDK metadata.

`bus init configure` updates accounting entity settings in an existing workspace `datapackage.json`. The workspace must already contain `datapackage.json` with a `busdk.accounting_entity` object (created by `bus init`). Only the properties you pass via flags are changed; others remain unchanged.

### Commands

`init` (or no subcommand) — Bootstrap a new workspace. The effective workspace root is the current directory, or the directory given by `-C` / `--chdir`. The command runs eight module inits in this order: accounts, entities, period, journal, invoices, vat, attachments, bank. After all steps complete, it verifies that every required baseline file exists; if any path is missing, the command fails and reports the first missing path. Neither `init` nor `configure` accepts extra positional arguments — anything after the subcommand is rejected with a usage error.

`init configure` — Edit accounting entity settings (base currency, fiscal year boundaries, VAT registration, VAT reporting cadence) in the workspace `datapackage.json`. Requires an existing workspace that already has `datapackage.json` and a `busdk.accounting_entity` object.

### Global flags

These flags apply to both `init` and `configure`. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are treated as positional arguments (and for `init` and `configure`, extra positionals are invalid).

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored.
- **`-v`**, **`--verbose`** — Send verbose progress and diagnostics to stderr. You can repeat the flag (e.g. `-vv` or `--verbose --verbose`) to increase verbosity. Verbose output does not change what is written to stdout or to the file given by `--output`.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, nothing is written to stdout and no output file is created or written even if `--output` is given; only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage and exits with code 2.
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory for the command. All workspace paths (e.g. `datapackage.json`, module datasets) are resolved relative to this directory. If the directory does not exist or is not accessible, the command exits with code 1 and a clear error on stderr.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The path is relative to the effective working directory (after `-C`). The file is created or truncated. Errors and diagnostics still go to stderr. If both `--output` and `--quiet` are used, quiet wins: no output is written to the file.
- **`--color <mode>`** — Control colored output for human-facing messages on stderr. `<mode>` must be one of `auto`, `always`, or `never`. `auto` uses color only when stderr is a terminal; `always` forces color; `never` disables it. An invalid value (e.g. `neon`) is a usage error and exits with code 2.
- **`--no-color`** — Same as `--color=never`. If both are present, color is disabled.

Command results (e.g. help or version) are written to stdout. Diagnostics, progress, and error messages are written to stderr so that scripts can capture results without mixing in human-oriented text.

### Init: step order and baseline files

Bootstrap runs exactly eight steps in order: accounts, entities, period, journal, invoices, vat, attachments, bank. Each step is implemented by the corresponding module (e.g. `bus accounts init`, `bus entities init`). The tool depends on the `bus` dispatcher being available in your `PATH`; if `bus` is not found, the command exits with a clear “bus dispatcher not found in PATH” error.

When all steps have completed, the command verifies that every required baseline file exists in the workspace. The required paths are: `datapackage.json`; `accounts.csv` and `accounts.schema.json`; `entities.csv` and `entities.schema.json`; `attachments.csv` and `attachments.schema.json`; `journals.csv` and `journals.schema.json`; `sales-invoices.csv`, `sales-invoices.schema.json`, `sales-invoice-lines.csv`, `sales-invoice-lines.schema.json`; `purchase-invoices.csv`, `purchase-invoices.schema.json`, `purchase-invoice-lines.csv`, `purchase-invoice-lines.schema.json`; `vat-rates.csv`, `vat-rates.schema.json`, `vat-reports.csv`, `vat-reports.schema.json`, `vat-returns.csv`, `vat-returns.schema.json`; `periods.csv` and `periods.schema.json`; `bank-imports.csv`, `bank-imports.schema.json`, `bank-transactions.csv`, `bank-transactions.schema.json`. If any of these is missing, the command fails and reports the first missing path (e.g. “missing required path accounts.csv”). Verification runs after all module inits; it does not change or create files.

The initial `datapackage.json` created by bootstrap follows the [workspace configuration](../data/workspace-configuration) shape. Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, and fiscal year and VAT registration set as documented in the data package extension. You can adjust these afterward with `bus init configure`.

### Configure: options and behavior

`bus init configure` updates only the fields you pass. Omit a flag to leave that property unchanged. The following flags map to [accounting entity](../master-data/accounting-entity/index) properties in `datapackage.json`:

- **`--base-currency <code>`** — ISO 4217 currency code. Must be uppercase (e.g. `EUR`, `SEK`). Lowercase or invalid codes are a usage error (exit 2).
- **`--fiscal-year-start <date>`** — Fiscal year start in `YYYY-MM-DD` form. Slash or other formats are invalid and yield a usage error.
- **`--fiscal-year-end <date>`** — Fiscal year end in `YYYY-MM-DD` form. Same validation as start.
- **`--vat-registered <true|false>`** — Exactly `true` or `false`. Any other value (e.g. `maybe`) is a usage error.
- **`--vat-reporting-period <period>`** — Allowed values are `monthly` and `quarterly`. Other values (e.g. `yearly`) are invalid and exit with a usage error.

Configure requires an existing workspace. If `datapackage.json` is missing in the effective workspace directory, the command fails with “datapackage.json not found”. If the file exists but does not contain a `busdk.accounting_entity` object (e.g. a minimal package with no BusDK extension), it fails with “missing busdk.accounting_entity”. In both cases the message is on stderr and the exit code is non-zero.

### Files

Bootstrap creates or overwrites workspace-level `datapackage.json` and invokes each module’s init so that datasets and schema files appear in the workspace root as listed above. The `configure` subcommand only updates the `busdk.accounting_entity` subtree in `datapackage.json`; it does not create or remove files other than that in-place update.

### Exit status and errors

Exit 0 on success. Non-zero in these cases:

- **Invalid usage (exit 2)** — Unknown or invalid flag value (e.g. invalid `--color`, invalid `--base-currency` or date or `--vat-reporting-period`), combining `--quiet` and `--verbose`, or extra positional arguments for `init` or `configure`. The tool prints a short usage-style error to stderr.
- **Missing bus dispatcher (exit 1)** — `bus` is not found in `PATH`. Message: “bus dispatcher not found in PATH”.
- **Module init failure (exit non-zero)** — A module’s `init` command fails. The tool stops immediately after that step and reports “step failed: bus *module* init” (with the actual module name) on stderr. It does not run later steps.
- **Module compatibility (exit non-zero)** — A module exits with code 2, indicating a version or compatibility issue. The tool reports that the module “must be upgraded” and stops.
- **Missing baseline path (exit non-zero)** — After all module inits, one of the required baseline files is missing. The first missing path is reported (e.g. “missing required path accounts.csv”).
- **Configure preconditions (exit non-zero)** — `configure` was run in a directory without `datapackage.json` or without `busdk.accounting_entity`; see above.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-data">bus-data</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Module SDD: bus-init](../sdd/bus-init)
- [Layout: Layout principles](../layout/layout-principles)
- [Workflow: Initialize repo](../workflow/initialize-repo)

