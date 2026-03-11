---
title: bus-vat — compute, review, and export VAT periods
description: bus vat computes VAT totals for reporting periods, validates VAT data, supports invoice, journal, and reconcile-based modes, and produces filing and review outputs.
---

## `bus vat` — compute, review, and export VAT periods

`bus vat` is the VAT engine for a BusDK workspace. Use it to validate VAT-related data, compute period totals, review how those totals were formed, export VAT period artifacts, and compare filed totals against replayed totals.

The command can work from invoices, from journal rows, or from reconcile-based payment evidence depending on your workflow and accounting basis.

### Common tasks

Create the baseline VAT datasets:

```bash
bus vat init
```

Validate VAT data and compute a normal monthly report from invoice data:

```bash
bus vat validate
bus vat report --period 2026-01
```

Run a journal-driven report when invoice data is incomplete:

```bash
bus vat report --period 2026-01 --source journal
```

Run a cash-basis report from reconcile evidence:

```bash
bus vat report --period 2026-01 --source reconcile --basis cash
```

Export a VAT period artifact and review it as PDF:

```bash
bus vat export --period 2026Q1
bus vat -f pdf --output vat-review-2026Q1.pdf review --period 2026Q1
```

Generate Finnish filing payload values and a row-level trace:

```bash
bus vat fi-file --period 2026-01 --payload-format json
bus vat explain --period 2026-01 --format tsv
```

Import already-filed totals from outside BusDK and compare them against replayed totals:

```bash
bus vat filed-import --period 2026-01 --file ./authority-2026-01.csv
bus vat filed-diff --period 2026-01 --threshold-cents 0
```

Create a starter CSV when you need to import already-filed totals later:

```bash
bus vat filed-template --period 2026-01 > vat-filed-template.csv
```

### Synopsis

`bus vat init [-C <dir>] [global flags]`  
`bus vat validate [-C <dir>] [global flags]`  
`bus vat report --period <period> [-C <dir>] [global flags]`  
`bus vat export --period <period> [-C <dir>] [global flags]`  
`bus vat fi-file --period <period> [-C <dir>] [global flags]`  
`bus vat explain --period <period> [-C <dir>] [global flags]`  
`bus vat review --period <period> [-C <dir>] [global flags]`  
`bus vat period-profile <list|import> [-C <dir>] [global flags]`  
`bus vat filed-import --period <period> --file <path> [-C <dir>] [global flags]`  
`bus vat filed-diff --period <period> [-C <dir>] [global flags]`  
`bus vat filed-template --period <period> [-C <dir>] [global flags]`

### Which mode should you use?

| If your VAT evidence mainly comes from... | Start with... |
| --- | --- |
| invoice headers and lines | default mode |
| journal rows | `--source journal` |
| reconcile-linked payment evidence on cash basis | `--source reconcile --basis cash` |

Workspace defaults from [bus-config](./bus-config) can decide the normal VAT period cadence and default source/basis when you omit those flags.

### Which command should you use?

`validate` checks VAT master data and mode-specific inputs.

`report` computes totals for a period.

`export` writes a period export artifact for filing workflows.

`review` creates a more human-facing support packet.

`fi-file` gives you filing-field payload values for Finnish workflows.

`explain` is the audit trace when you need to know exactly how a filing value was formed.

`filed-import` and `filed-diff` are the commands to use when official filed totals already exist and you want deterministic replay comparison inside the workspace.

`filed-template` gives you a starter file when you want to collect authority-filed totals in the right shape before `filed-import`.

### Typical workflows

For a normal accrual-based monthly flow:

```bash
bus vat validate
bus vat report --period 2026-01
bus vat export --period 2026-01
```

For a journal-first or migrated workspace:

```bash
bus vat validate --source journal
bus vat report --period 2026-01 --source journal
bus vat export --period 2026-01 --source journal
```

For a cash-basis workflow tied to payment evidence:

```bash
bus vat report --period 2026-01 --source reconcile --basis cash
bus vat review --period 2026-01 --source reconcile --basis cash
```

### Important behavior

`report`, `export`, `filed-import`, `filed-diff`, and `filed-template` accept either `--period` or `--from` and `--to`. Do not combine those two styles in the same command.

`fi-file`, `explain`, and `review` also accept `--period-profile` for named reporting windows. That profile selection is an alternative to `--period` or `--from` and `--to`, not an extra filter on top.

In reconcile-plus-cash mode, coverage matters. If payment evidence is incomplete, the command can fail unless you explicitly allow partial coverage.

Journal-driven mode can use `vat-account-mapping.csv` for direction and rate fallback when the journal itself does not carry all VAT-specific fields.

`filed-diff` is the cleanest control command when you want to prove that replayed totals match already-filed totals exactly.

`review --format pdf` works only for the full packet. If you want a single section such as `summary` or `explain`, use `tsv`, `json`, or `csv` instead.

`review --section coverage` is only available in reconcile-plus-cash mode, because that section is built from payment-evidence coverage metrics.

### Files

This module owns the VAT master, report, return, and filed-evidence datasets at the workspace root. It also writes period-specific return and filed-evidence files when those commands are used.

### Output and flags

These commands use [Standard global flags](../cli/global-flags). In practice:

Use `report` for fast TSV output, `fi-file` for filing payloads, `explain` for trace output, and `review` when you want a more readable package, including PDF.

Use `--dry-run` for `init`, `export`, and `filed-import` when you want to preview file creation without writing.

For the full command and mode matrix, run `bus vat --help`.

### Exit status

`0` on success. Non-zero on invalid usage, VAT mapping violations, missing required evidence, or filed-diff threshold breaches.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus vat report --period 2026-01 --source journal
vat report --period 2026-01 --source journal

# same as: bus vat export --period 2026-01 --source reconcile --basis cash --min-sales-coverage 0.95 --min-purchase-coverage 0.90 --max-unmatched-cash-rows 5
vat export --period 2026-01 --source reconcile --basis cash --min-sales-coverage 0.95 --min-purchase-coverage 0.90 --max-unmatched-cash-rows 5

# same as: bus vat filed-diff --period 2026-01 --threshold-cents 0
vat filed-diff --period 2026-01 --threshold-cents 0
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-validate">bus-validate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-config (VAT configuration reference)](./bus-config)
- [Workspace configuration](../data/workspace-configuration)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Module reference: bus-vat](../modules/bus-vat)
- [Workflow: VAT reporting and payment](../workflow/vat-reporting-and-payment)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [Finnish closing checklist and reconciliations](../compliance/fi-closing-checklist-and-reconciliations)
