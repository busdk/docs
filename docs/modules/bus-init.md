---
title: bus-init — initialize a new BusDK workspace
description: bus init bootstraps a new workspace by running bus config init first (so that datapackage.json and accounting entity settings exist), then running each…
---

## bus-init

### Name

`bus init` — initialize a new BusDK workspace.

### Synopsis

`bus init [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`  
`bus init init [-C <dir>] [-o <file>] [-v] [-q] [--color <auto|always|never>] [-h] [-V]`

Running `bus init` with no subcommand runs the bootstrap (same as `bus init init`). All paths and the workspace directory are resolved relative to the current directory unless you set `-C` / `--chdir`. To create or update workspace configuration (accounting entity settings) after bootstrap, use [bus config](./bus-config).

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus init` bootstraps a new workspace by running `bus config init` first (so that `datapackage.json` and [accounting entity](../master-data/accounting-entity/index) settings exist), then running each domain module’s `init` command in a deterministic sequence. Each module owns its own datasets and schemas; `bus init` does not perform Git or network operations. The result is the standard workspace layout with baseline datasets and schemas and an initial `datapackage.json`. To change accounting entity settings afterward, use `bus config configure`.

### Commands

`init` (or no subcommand) — Bootstrap a new workspace. The effective workspace root is the current directory, or the directory given by `-C` / `--chdir`. The command runs `bus config init` first, then eight domain module inits in this order: accounts, entities, period, journal, invoices, vat, attachments, bank. Success is determined only by those steps: when every invoked command exits with code 0, the bootstrap is complete. The command does not check for a fixed list of baseline paths afterward; each module is responsible for creating its own files and for failing its init if it cannot. The command does not accept extra positional arguments — anything after the subcommand is rejected with a usage error.

### Global flags

These flags apply to `init`. They match the [standard global flags](../cli/global-flags) shared by most BusDK modules. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are treated as positional arguments (extra positional arguments for `init` are invalid).

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0. Other flags and arguments are ignored.
- **`-v`**, **`--verbose`** — Send verbose progress and diagnostics to stderr. You can repeat the flag (e.g. `-vv` or `--verbose --verbose`) to increase verbosity. Verbose output does not change what is written to stdout or to the file given by `--output`.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, nothing is written to stdout and no output file is created or written even if `--output` is given; only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage and exits with code 2.
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory for the command. All workspace paths (e.g. `datapackage.json`, module datasets) are resolved relative to this directory. The same directory is used when invoking `bus config init` and each module’s `init`. If the directory does not exist or is not accessible, the command exits with code 1 and a clear error on stderr.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The path is relative to the effective working directory (after `-C`). The file is created or truncated. Errors and diagnostics still go to stderr. If both `--output` and `--quiet` are used, quiet wins: no output is written to the file.
- **`--color <mode>`** — Control colored output for human-facing messages on stderr. `<mode>` must be one of `auto`, `always`, or `never`. `auto` uses color only when stderr is a terminal; `always` forces color; `never` disables it. An invalid value (e.g. `neon`) is a usage error and exits with code 2.
- **`--no-color`** — Same as `--color=never`. If both are present, color is disabled.

Command results (e.g. help or version) are written to stdout. Diagnostics, progress, and error messages are written to stderr so that scripts can capture results without mixing in human-oriented text.

### Init: step order and baseline files

Bootstrap runs `bus config init` first, then eight domain module inits in order: accounts, entities, period, journal, invoices, vat, attachments, bank. Each step is implemented by the corresponding module (e.g. `bus config init`, `bus accounts init`, `bus entities init`). Each module’s `init` creates its baseline data only when absent; if the data already exists in full, the module prints a warning and does nothing; if the data exists only partially, the module fails with an error and does not modify any file. The tool depends on the `bus` dispatcher being available in your `PATH`; if `bus` is not found, the command exits with a clear “bus dispatcher not found in PATH” error. When every invoked command exits with code 0, the bootstrap is complete. The command does not verify a fixed list of baseline paths afterward; each module owns its datasets and schemas and is responsible for failing its init if it cannot create them.

The initial `datapackage.json` is created by `bus config init` and follows the [workspace configuration](../data/workspace-configuration) shape. Defaults include `profile` `tabular-data-package`, `base_currency` `EUR`, `vat_reporting_period` `quarterly`, and fiscal year and VAT registration set as documented in the data package extension. You can adjust these afterward with [bus config configure](./bus-config).

### Files

Bootstrap invokes `bus config init` (which creates or ensures `datapackage.json`) and then each domain module’s init so that datasets and schema files appear in the workspace root. Bus init does not write any files directly; it only orchestrates the sequence. Success is determined by each step’s exit code, not by a post-hoc check of baseline paths.

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
