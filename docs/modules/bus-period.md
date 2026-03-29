---
title: bus-period — manage accounting periods and year rollover
description: bus period creates accounting periods, opens and closes them, locks and reopens them with audit metadata, and can generate opening entries from a prior workspace.
---

## `bus period` — manage accounting periods and year rollover

`bus period` controls when the books are open for posting and when they are closed or locked. Use it to create periods, move them through their lifecycle, and generate opening balances for a new year from a prior workspace.

If a period is not open, normal journal posting should not continue there. This module is what keeps that timeline explicit and reviewable.

### Common tasks

Create the period control dataset:

```bash
bus period init
```

Create and open the first month of a new year:

```bash
bus period add --period 2026-01 --retained-earnings-account 3200
bus period open --period 2026-01
```

List current periods and validate the control data:

```bash
bus period list
bus period validate
```

Close and then lock a finished period:

```bash
bus period close --period 2026-01 --post-date 2026-01-31
bus period lock --period 2026-01
```

Reopen a closed period for a controlled correction window:

```bash
bus period reopen \
  --period 2026-01 \
  --reason "Correction to January accrual" \
  --approved-by reviewer@example.com
```

Generate opening balances for the new year from a prior workspace:

```bash
bus period opening \
  --from ../books-2025 \
  --as-of 2025-12-31 \
  --post-date 2026-01-01 \
  --period 2026-01 \
  --equity-account 3200
```

### Synopsis

`bus period init [-C <dir>] [global flags]`  
`bus period add --period <YYYY|YYYY-MM|YYYYQn> [--start-date <YYYY-MM-DD>] [--end-date <YYYY-MM-DD>] [--retained-earnings-account <code>] [-C <dir>] [global flags]`  
`bus period open --period <YYYY|YYYY-MM|YYYYQn> [-C <dir>] [global flags]`  
`bus period close --period <YYYY|YYYY-MM|YYYYQn> [--post-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus period lock --period <YYYY|YYYY-MM|YYYYQn> [-C <dir>] [global flags]`  
`bus period reopen --period <YYYY|YYYY-MM|YYYYQn> --reason <text> --approved-by <id> [--voucher-id <id>]... [--max-open-days <n>] [-C <dir>] [global flags]`  
`bus period set --period <YYYY|YYYY-MM|YYYYQn> --retained-earnings-account <code> [-C <dir>] [global flags]`  
`bus period list [--history] [-C <dir>] [global flags]`  
`bus period validate [-C <dir>] [global flags]`  
`bus period opening --from <path> --as-of <YYYY-MM-DD> --post-date <YYYY-MM-DD> --period <YYYY|YYYY-MM|YYYYQn> [options] [-C <dir>] [global flags]`

### Period lifecycle

The normal lifecycle is:

`future` → `open` → `closed` → `locked`

If a correction is needed, `reopen` creates a controlled exception path from a closed period. After the corrections, you close it again.

`list` shows the effective current state. `list --history` is the command to use when you want to see the full append-only timeline of changes.

### Which command should you use?

Use `add` when the period does not exist yet.

Use `open` when posting work should begin.

Use `close` when the period’s result should be closed and closing artifacts written.

Use `lock` when the period should no longer be reopened casually.

Use `set` to repair or define the retained-earnings account for a period.

Use `opening` when you are rolling a workspace into a new fiscal year and want one deterministic opening entry from the prior year’s closing balances.

### Important details

Supported period identifiers are `YYYY`, `YYYY-MM`, and `YYYYQn`.

Each period needs a retained-earnings account. If you omit it on `add`, the default is `3200`.

`close` automatically creates the closing mechanics for the period, including the result transfer to retained earnings.

`opening` expects the target period to already exist and be open.

`reopen` can also record one or more `--voucher-id` values when you want the reopen window tied to specific correction vouchers.

Storage mode for period-owned datasets is resolved through shared `bus-data` policy handling. If no explicit workspace, module, or resource storage policy exists, `bus period` uses ordinary CSV by default. `PCSV-1` remains an opt-in storage choice and is not selected by private module-specific `_pcsv` parsing.

### Typical workflow

A common year-start flow is:

```bash
bus period init
bus period add --period 2026-01 --retained-earnings-account 3200
bus period open --period 2026-01
bus journal init
bus period opening \
  --from ../books-2025 \
  --as-of 2025-12-31 \
  --post-date 2026-01-01 \
  --period 2026-01
```

For a normal monthly close:

```bash
bus period validate
bus reports trial-balance --as-of 2026-01-31
bus period close --period 2026-01 --post-date 2026-01-31
bus period lock --period 2026-01
```

### Files

This module owns `periods.csv` and `periods.schema.json` at the workspace root. When you close a period, it also writes review artifacts under `periods/<period-id>/`, including `close_entries.csv` and `opening_balances.csv`.

### Output and flags

These commands use [Standard global flags](../cli/global-flags). `list` is the main read/report command. `--dry-run` is especially useful for `add`, `open`, `close`, `reopen`, `set`, and `opening` when you want to preview period-control changes.

For the full flag details, run `bus period --help`.

### Exit status

`0` on success. Non-zero on invalid usage, invalid state transitions, missing periods, invalid retained-earnings accounts, or opening-generation failures.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus period add --period 2026-01 --retained-earnings-account 3200
period add --period 2026-01 --retained-earnings-account 3200

# same as: bus period open --period 2026-01
period open --period 2026-01

# same as: bus period close --period 2026-01 --post-date 2026-01-31
period close --period 2026-01 --post-date 2026-01-31
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-vendors">bus-vendors</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Accounting periods](../master-data/accounting-periods/index)
- [Module reference: bus-period](../modules/bus-period)
- [Module reference: bus-journal](../modules/bus-journal)
- [Workflow: Year-end close (closing entries)](../workflow/year-end-close)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
