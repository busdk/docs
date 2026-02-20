---
title: bus — dispatcher and `.bus` command-file runner
description: Use bus as the single entrypoint for modules and to execute deterministic .bus command files with global syntax preflight.
---

## `bus` — dispatcher for modules and `.bus` files

### Synopsis

```bash
bus [<command> [args...]]
bus [--check] [--transaction <provider>] [--scope <scope>] [--trace] <file.bus> [<file2.bus> ...]
./file.bus
```

Use `bus` in two modes:

- Normal dispatch: `bus <module> [args...]` calls `bus-<module>` from PATH.
- Busfile mode: `bus <file>.bus [...]` executes one or more `.bus` command files.

### Description

`bus` is the single CLI entrypoint for BusDK. It does not implement accounting logic itself; it routes commands to module CLIs (`bus-journal`, `bus-bank`, and so on), and it can execute deterministic `.bus` files.

When running busfiles, `bus` always does a full syntax preflight across all provided files before executing any command. If preflight fails, nothing is executed.

For first use, start with [`.bus` files — getting started step by step](../cli/bus-script-files-getting-started), then continue with the full [`.bus` script files (writing and execution guide)](../cli/bus-script-files).

This feature is available under FSL-1.1-MIT (Functional Source License 1.1, MIT Future License), and source code is already available.

### Normal dispatch

- `bus <module> <args...>` dispatches to `bus-<module>`.
- Example: `bus journal add ...` runs `bus-journal add ...`.
- `bus run ...` is treated like any other module dispatch target.

### Busfile mode

A path is treated as a busfile when:

- it ends with `.bus`, or
- it is executable and starts with `#!/usr/bin/bus` or `#!/usr/bin/env bus`

Busfile line rules:

- Blank lines are ignored.
- Lines whose first non-whitespace character is `#` are comments.
- Lines ending with `.bus` are treated as nested busfile includes.
- Other lines are parsed as one command line using shell-like quoting.
- Variable expansion, command substitution, pipes/redirection, and `;` separators are not interpreted.

### Busfile options

These flags are interpreted only in busfile mode:

- `--check`: preflight (and optional data validation) only; do not apply changes.
  - `--check` is expected to use module-native non-mutating validation (`--check`) for dispatched commands.
  - Core dispatcher validation additionally rejects clearly invalid common patterns (for example unbalanced `journal add` postings and malformed `bank add transactions --set` values).
- `--transaction <provider>`: `none` (default), `fs`, `git`, `snapshot`, or `copy`.
- `--scope <scope>`: `file` (default) or `batch`.
- `--trace`: print `file:line` command trace before execution.

### Execution model

1. Global syntax preflight: read/tokenize all provided busfiles first.
2. Optional data validation (workspace/module support dependent).
3. Apply in order with fail-fast semantics.

Scopes:

- `file` scope (default): each file is applied independently after global preflight.
- `batch` scope: all files are one apply unit (all-or-nothing only if provider supports it).

### Exit status

- **0** — Success.
- **1** — Command execution failed.
- **2** — Usage error (invalid flags, missing file, or no subcommand in normal dispatch usage).
- **65** — Busfile syntax/tokenization error.
- **127** — Missing subcommand in normal dispatch mode (`bus-<command>` not found on PATH).

If a dispatched module returns a specific non-zero code, `bus` returns that code.

### Examples

Normal dispatch:

```bash
bus init all
bus accounts list
bus journal add --date 2024-02-29 --desc "Example" --debit 1910=10 --credit 3000=10
```

Single busfile:

```bus
#!/usr/bin/env bus

# 2024-02-29 Bank import-bank-00001
bank add transactions \
  --set bank_txn_id=import-bank-00001 \
  --set import_id=import-bank-2024 \
  --set booked_date=2024-02-29 \
  --set value_date=2024-02-29 \
  --set amount=-861.6800000000 \
  --set currency=EUR \
  --set counterparty_name='Example Vendor' \
  --set counterparty_iban='' \
  --set reference='REF-00001' \
  --set message='EXAMPLE PAYMENT MESSAGE' \
  --set end_to_end_id=import-e2e-00001 \
  --set source_id='bank_row:00001'

journal add \
  --date 2024-02-29 \
  --desc 'Bank import-bank-00001 Example Vendor payment' \
  --debit 2949=861.68 \
  --credit 1910=861.68 \
  --source-id bank_row:00001:journal:1
```

Run monthly files directly:

```bash
bus 2024-01.bus 2024-02.bus 2024-03.bus
```

Example month runner file:

```bus
#!/usr/bin/env bus

2024-01.bus
2024-02.bus
2024-03.bus
```

Check-only and trace:

```bash
bus --check --trace 2024-01.bus 2024-02.bus 2024-03.bus
```

Force transaction settings for one run:

```bash
bus --transaction git --scope batch 2024-01.bus 2024-02.bus 2024-03.bus
```

### Using from `.bus` files

`bus` is the dispatcher itself. In `.bus` files you normally call module targets directly and include other `.bus` files.

```bus
# include another .bus file
2026-02.bus

# module command line (same as: bus journal --help)
journal --help
```

### Notes

- Atomicity is configurable. Default provider is `none` (fast, no workspace-level rollback).
- Git-based atomicity is optional, not required.
- Prefer `.bus` extension for deterministic recognition.
- For robust batch safety, keep `--check` support enabled across modules referenced by your `.bus` files.
- Dispatch selection during busfile runs is automatic:
  - If an in-process module runner is available, `bus` uses it.
  - Otherwise `bus` falls back to shell lookup (`bus-<module>` on `PATH`) when enabled.
- Shell lookup can be disabled with `bus.busfile.dispatch.shell_lookup_enabled=false` in `bus-preferences` or `datapackage.json`.
- Current implementation detail: `fs` transaction mode requires in-process transaction-capable runners for all busfile targets. If any target must use external shell dispatch, `bus` either falls back to `none` (when `fallback_to_none=true`) or exits with a provider error.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus (dispatcher)](../sdd/bus)
- [`.bus` files — getting started step by step](../cli/bus-script-files-getting-started)
- [`.bus` script files (writing and execution guide)](../cli/bus-script-files)
- [CLI command structure](../cli/command-structure)
- [Standard global flags](../cli/global-flags)
