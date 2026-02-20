---
title: "`.bus` script files — writing and execution guide"
description: "How to write deterministic .bus files, run them with bus, and understand preflight, validation, scope, and transaction behavior."
---

## `.bus` script files

`.bus` files are deterministic command files executed by `bus`. They are intended for repeatable bookkeeping runs (for example one file per month), replay, and review in version control.

If this is your first `.bus` file, use the simpler [`.bus` files — getting started step by step](./bus-script-files-getting-started) first, then return to this page.
For a practical multi-command starter that also includes `dev`, `agent`, and `run`, see [`.bus` getting started — multiple commands together](./bus-script-files-multi-command-getting-started).

This feature is available under FSL-1.1-MIT (Functional Source License 1.1, MIT Future License), and source code is already available in the BusDK repositories.

## Quick start

Create a file:

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

Busfiles are UTF-8 text. Blank lines are ignored, and lines whose first non-whitespace character is `#` are treated as comments. A trailing `\` continues the command on the next physical line. Lines ending with `.bus` are nested includes, while other lines are parsed as one command line.

## Quoting rules

`.bus` tokenization uses shell-like quoting:

whitespace splits tokens, single quotes `'...'` keep literal content, double quotes `"..."` keep literal content, and backslash `\` escapes the next character.

Not interpreted:

variable expansion (`$VAR`), command substitution (`$(...)` and backticks), pipes/redirections (`|`, `>`, `<`), and `;` command separators are not interpreted.

If any line has a tokenization error (for example unterminated quote), execution stops before running any command.

For include lines (`*.bus`), `bus` resolves and loads the referenced file and applies the same preflight rules.

When `--check` is used, modules referenced by the busfile set should provide non-mutating `--check` validation. The dispatcher also rejects clearly invalid common forms such as unbalanced `journal add` postings and malformed `bank add transactions --set` values.

## Execution model

1. Global syntax preflight across all provided `.bus` files.
2. Optional data validation (if configured and supported by modules).
3. Apply in order, fail-fast on first command failure.

This means `bus A.bus B.bus C.bus` fails with no applied changes if any file fails syntax preflight.

## Options (busfile mode)

Use these when invoking `.bus` files:

Use `--check` for validation-only runs, `--trace` to print each parsed command with `file:line`, `--scope file|batch` to choose per-file or batch apply unit, and `--transaction none|git|snapshot|copy` to choose transaction provider.

Examples:

```bash
bus --check --trace 2024-01.bus 2024-02.bus 2024-03.bus
bus --transaction git --scope batch 2024-01.bus 2024-02.bus 2024-03.bus
```

## Configuration

Defaults can come from workspace preferences and/or `datapackage.json`:

defaults include validation level (`syntax` or `data`), strict-validation behavior, transaction provider/scope, and fallback to `none` when the configured provider is unavailable.

## Error format and exit codes

Typical errors:

`2024-02.bus:17: syntax error: unterminated quote`, `2024-02.bus:23: dispatch error: unknown target "bnak"`, and `2024-01.bus:42: command failed (exit 1): journal add --date ...`.

Exit codes:

`0` means success, `1` means command execution failure, `2` means usage error, and `65` means busfile syntax/tokenization error.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-script-files-getting-started">`.bus` files — getting started step by step</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/bus">bus module reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [`.bus` files — getting started step by step](./bus-script-files-getting-started)
- [`.bus` getting started — multiple commands together](./bus-script-files-multi-command-getting-started)
- [bus module reference](../modules/bus)
- [Module SDD: bus](../sdd/bus)
- [BusDK module CLI reference](../modules/index)
