---
title: `.bus` script files — writing and execution guide
description: How to write deterministic .bus files, run them with bus, and understand preflight, validation, scope, and transaction behavior.
---

## `.bus` script files

`.bus` files are deterministic command files executed by `bus`. They are intended for repeatable bookkeeping runs (for example one file per month), replay, and review in version control.

This feature is fully open source under the MIT license, and source code is already available in the BusDK repositories.

## Quick start

Create a file:

```bus
#!/usr/bin/env bus

# 2024-02-29 Bank erp-bank-26246
bank add transactions --set bank_txn_id=erp-bank-26246 --set import_id=erp-bank-2024 --set booked_date=2024-02-29 --set value_date=2024-02-29 --set amount=-861.6800000000 --set currency=EUR --set counterparty_name='Qred Visa' --set counterparty_iban='' --set reference='411050319' --set message='700 / TILISIIRTO / 240229593619234599' --set end_to_end_id=erp-e2e-26246 --set source_id='bank_row:26246'

journal add --date 2024-02-29 --desc 'Bank erp-bank-26246 Qred Visa lyhennys' --debit 2949=861.68 --credit 1910=861.68 --source-id bank_row:26246:journal:1
```

Run it:

```bash
bus 2024-02.bus
```

Or execute it directly if executable:

```bash
chmod +x 2024-02.bus
./2024-02.bus
```

Run multiple month files:

```bash
bus 2024-01.bus 2024-02.bus 2024-03.bus
```

Month runner script example:

```bus
#!/usr/bin/env bus

2024-01.bus
2024-02.bus
2024-03.bus
```

## File rules

- UTF-8 text.
- Blank lines are ignored.
- Lines whose first non-whitespace character is `#` are ignored.
- Lines ending with `.bus` are treated as nested busfile includes.
- Other lines are parsed as one command line.

## Quoting rules

`.bus` tokenization uses shell-like quoting:

- whitespace splits tokens
- single quotes `'...'` keep literal content
- double quotes `"..."` keep literal content
- backslash `\` escapes the next character

Not interpreted:

- variable expansion (`$VAR`)
- command substitution (`$(...)` and backticks)
- pipes and redirections (`|`, `>`, `<`)
- `;` command separators

If any line has a tokenization error (for example unterminated quote), execution stops before running any command.

For include lines (`*.bus`), `bus` resolves and loads the referenced file and applies the same preflight rules.

## Execution model

1. Global syntax preflight across all provided `.bus` files.
2. Optional data validation (if configured and supported by modules).
3. Apply in order, fail-fast on first command failure.

This means `bus A.bus B.bus C.bus` fails with no applied changes if any file fails syntax preflight.

## Options (busfile mode)

Use these when invoking `.bus` files:

- `--check`: validate only; do not apply changes.
- `--trace`: print each parsed command with `file:line`.
- `--scope file|batch`: per-file unit (`file`, default) or one batch unit (`batch`).
- `--transaction none|git|snapshot|copy`: workspace transaction provider.

Examples:

```bash
bus --check --trace 2024-01.bus 2024-02.bus 2024-03.bus
bus --transaction git --scope batch 2024-01.bus 2024-02.bus 2024-03.bus
```

## Configuration

Defaults can come from workspace preferences and/or `datapackage.json`:

- validation level (`syntax` or `data`)
- strict validation behavior
- transaction provider and scope
- fallback to `none` if configured provider is unavailable

## Error format and exit codes

Typical errors:

- `2024-02.bus:17: syntax error: unterminated quote`
- `2024-02.bus:23: dispatch error: unknown target "bnak"`
- `2024-01.bus:42: command failed (exit 1): journal add --date ...`

Exit codes:

- `0` success
- `1` command execution failed
- `2` usage error
- `65` busfile syntax/tokenization error

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./interactive-and-scripting-parity">Non-interactive use and scripting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/bus">bus module reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus module reference](../modules/bus)
- [Module SDD: bus](../sdd/bus)
- [BusDK module CLI reference](../modules/index)
