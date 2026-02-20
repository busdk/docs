---
title: bus-status — workspace readiness and close-state status
description: bus status reports deterministic workspace readiness and period close-state status for close-flow checks and automation.
---

## `bus-status` — workspace readiness and close-state status

### Synopsis

`bus status readiness [-C <dir>] [-f <text|json|tsv>] [-o <file>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus status` reports deterministic workspace readiness and period close-state status.
Use it for quick close-flow checks and CI/automation gates.

The canonical module invocation is `bus status`.
The standalone `bus-status` binary is still valid for direct script usage.

### Commands

`readiness` checks core workspace readiness and latest period close state.

### Options

`readiness` supports `-f <text|json|tsv>`, `-o <file>`, and `-C <dir>`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus status --help`.

### Output fields

`accounts_ready` reports whether `accounts.csv` and `accounts.schema.json` are present. `journal_ready` reports whether journal dataset and schema are present. `periods_ready` reports whether period dataset and schema are present. `latest_period` gives the latest period id from period control data, and `latest_state` gives the latest state (`future|open|closed|locked|...`). `close_flow_ready` is true only when core datasets exist and latest state is `closed` or `locked`.

### Examples

```bash
bus status readiness
bus status readiness --format json --output ./out/status.json
bus status -C ./workspace readiness --format tsv
```

### Exit status

`0` on success. Non-zero on invalid usage or readiness evaluation errors.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus status readiness --format json
status readiness --format json

# same as: bus status readiness --format tsv --output ./out/status.tsv
status readiness --format tsv --output ./out/status.tsv
```
