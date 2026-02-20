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

For a step-by-step authoring guide, see [`.bus` script files (writing and execution guide)](../cli/bus-script-files).

This feature is fully open source under the MIT license, and source code is already available.

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
- `--transaction <provider>`: `none` (default), `git`, `snapshot`, or `copy`.
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

# 2024-02-29 Bank erp-bank-26246
bank add transactions --set bank_txn_id=erp-bank-26246 --set import_id=erp-bank-2024 --set booked_date=2024-02-29 --set value_date=2024-02-29 --set amount=-861.6800000000 --set currency=EUR --set counterparty_name='Qred Visa' --set counterparty_iban='' --set reference='411050319' --set message='700 / TILISIIRTO / 240229593619234599' --set end_to_end_id=erp-e2e-26246 --set source_id='bank_row:26246'

journal add --date 2024-02-29 --desc 'Bank erp-bank-26246 Qred Visa lyhennys' --debit 2949=861.68 --credit 1910=861.68 --source-id bank_row:26246:journal:1
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

### Notes

- Atomicity is configurable. Default provider is `none` (fast, no workspace-level rollback).
- Git-based atomicity is optional, not required.
- Prefer `.bus` extension for deterministic recognition.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus (dispatcher)](../sdd/bus)
- [`.bus` script files (writing and execution guide)](../cli/bus-script-files)
- [CLI command structure](../cli/command-structure)
- [Standard global flags](../cli/global-flags)
