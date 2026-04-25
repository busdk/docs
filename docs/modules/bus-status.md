---
title: bus-status — workspace readiness and close-state status
description: bus status shows whether a workspace is ready for normal work, whether evidence links are complete, and whether a year-end close still has blockers.
---

## `bus-status` — workspace readiness and close-state status

`bus status` is the quick health check for a BusDK workspace. Use it when you want to know whether the core datasets exist, whether evidence links are missing, or whether a close still has blockers before you start producing reports.

### Common tasks

Check whether the workspace has the minimum datasets and whether the latest period looks ready:

```bash
bus status readiness
```

Check evidence coverage for one year and fail the command if anything is still missing:

```bash
bus status evidence-coverage --year 2026 --strict
```

Ask for a machine-readable close review report for a Finnish year-end close:

```bash
bus status close-readiness --year 2026 --compliance fi --format json \
  -o ./out/close-readiness-2026.json
```

### Synopsis

`bus status readiness [--year <YYYY>] [--strict] [--compliance [fi]] [-C <dir>] [-f <text|json|tsv>] [-o <file>] [global flags]`  
`bus status evidence-coverage [--year <YYYY>] [--strict] [-C <dir>] [-f <text|json|tsv>] [-o <file>] [global flags]`  
`bus status close-readiness --year <YYYY> [--strict] [--compliance [fi]] [-C <dir>] [-f <text|json|tsv>] [-o <file>] [global flags]`

### Commands

`readiness` is the fastest general check. It tells you whether core datasets such as accounts, journal, and periods are present, what the latest period is, and whether the workspace looks ready for close-related work.

`evidence-coverage` focuses on audit evidence. It reports how many rows in journal, bank, sales, and purchase scopes have evidence links and which IDs are still missing links.

`close-readiness` is the higher-level year-end view. It combines artifact presence, evidence coverage, period close state, VAT filing parity, and deterministic blocker rows into one report.

`vm` and `containers` are AI Platform aggregate status views. They use the
domain-owned Go clients from [bus-vm](./bus-vm) and
[bus-containers](./bus-containers), so `bus-status` provides the status UX
without owning those HTTP API contracts.

### What the output tells you

`readiness` includes fields such as `accounts_ready`, `journal_ready`, `periods_ready`, `latest_period`, `latest_state`, and `close_flow_ready`. This is the command to use when you want a fast “is this workspace basically ready?” answer.

`evidence-coverage` summarizes `total_rows`, `linked_rows`, and `missing_rows` by scope. The detailed rows give you the missing identifiers you need to fix, such as `source_id`, `voucher_id`, `bank_txn_id`, or `invoice_id`.

`close-readiness` adds blocker rows and reason codes. This is the command to use before close, evidence-pack generation, or filing preparation when you want a single machine-readable answer about what still blocks the process.

### Options users typically need

`--year <YYYY>` scopes the check to one fiscal year. `--strict` turns warnings into a failing exit status, which is useful in scripts and CI. `--compliance` or `--compliance fi` adds legal/compliance demand evaluation for Finnish close checks. `-f json` is the easiest output choice for automation, and `-f text` is usually the easiest for interactive review.

These commands use [Standard global flags](../cli/global-flags). In practice the most useful ones here are `-C` for choosing a workspace, `-o` for saving JSON output, and `-f` for switching between `text`, `tsv`, and `json`.

### Typical workflow

Many users run these commands in a simple sequence:

```bash
bus status readiness --year 2026
bus status evidence-coverage --year 2026
bus status close-readiness --year 2026 --compliance fi
bus status --token-file .bus/auth/ai-token vm --format json
bus status --token-file .bus/auth/ai-token containers --format json
```

If `close-readiness` still reports blockers, the blocker rows usually tell you whether to continue in [bus-attachments](./bus-attachments), [bus-bank](./bus-bank), [bus-journal](./bus-journal), [bus-reconcile](./bus-reconcile), or [bus-reports](./bus-reports).

### Examples

```bash
bus status readiness
bus status readiness --year 2026 --format json --output ./out/status.json
bus status evidence-coverage --year 2026 --format text
bus status close-readiness --year 2026 --compliance fi --strict
bus status -C ./workspace readiness --format tsv
bus status --api-url https://ai.hg.fi --token "$BUS_AI_TOKEN" vm --format json
bus status --api-url https://ai.hg.fi --token "$BUS_AI_TOKEN" containers --format json
```

### Exit status

`0` on success. Non-zero on invalid usage, evaluation errors, or `--strict` runs that find failing gates or blockers.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus status readiness --format json
status readiness --format json

# same as: bus status evidence-coverage --year 2026 --strict
status evidence-coverage --year 2026 --strict

# same as: bus status close-readiness --year 2026 --compliance fi --format json
status close-readiness --year 2026 --compliance fi --format json
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-validate">bus-validate</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module reference: bus-status](../modules/bus-status)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Module reference: bus-attachments](../modules/bus-attachments)
- [Module reference: bus-bank](../modules/bus-bank)
- [Module reference: bus-journal](../modules/bus-journal)
- [Module reference: bus-reconcile](../modules/bus-reconcile)
- [Module reference: bus-reports](../modules/bus-reports)
- [Standard global flags](../cli/global-flags)
