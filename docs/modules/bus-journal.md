---
title: bus-journal — post and query ledger journal entries
description: bus journal is the authoritative ledger module for BusDK. Use it to add balanced entries, inspect account activity, import legacy journals, and automate classified or template-based postings.
---

## `bus-journal` — post and query ledger journal entries

`bus journal` maintains the authoritative double-entry ledger for a workspace. If a row should become accounting, this is the module that writes it.

Use it for manual entries, replay-safe automated postings, account activity review, legacy journal import, and bank-driven posting automation. Closed or locked periods are rejected automatically.

### Common tasks

Create the journal datasets:

```bash
bus journal init
```

Post one simple manual entry:

```bash
bus journal add \
  --date 2026-01-31 \
  --desc "January rent" \
  --debit 6300=1200.00 \
  --credit 1910=1200.00
```

Post replay-safe automation rows with a stable source key:

```bash
bus journal add \
  --date 2026-01-31 \
  --desc "Payroll January" \
  --debit 5000=4200.00 \
  --credit 1910=4200.00 \
  --source-system payroll \
  --source-id 2026-01 \
  --if-missing
```

Check balances and inspect one account’s movement:

```bash
bus journal balance --as-of 2026-03-31
bus journal --format tsv account-activity --account 1910 --period 2026 --opening exclude
```

Import a legacy ledger CSV through a deterministic import profile:

```bash
bus journal import \
  --profile fi-ledger-legacy \
  --file ./legacy/daybook.csv \
  --source-id-from "Source Ref"
```

Generate bank-driven posting proposals and then apply them:

```bash
bus journal -o ./out/journal-proposals.tsv classify bank --profile ./rules.yml
bus journal classify apply --proposal ./out/journal-proposals.tsv
```

Post recurring VAT-split entries from a template:

```bash
bus journal template post \
  --template-file ./templates.yml \
  --template office_24 \
  --date 2026-01-15 \
  --gross 124.00 \
  --desc "Office supplies"
```

### Synopsis

`bus journal init [-C <dir>] [global flags]`  
`bus journal add --date <YYYY-MM-DD> [--desc <text>] [--source-id <key>] [--if-missing] --debit <account>=<amount> ... --credit <account>=<amount> ... [-C <dir>] [global flags]`  
`bus journal add --bulk-in <file|-> [-C <dir>] [global flags]`  
`bus journal balance [--as-of <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus journal account-activity --account <code[,code]> [--period <id>] [--from-date <YYYY-MM-DD>] [--to-date <YYYY-MM-DD>] [--opening <all|exclude|only>] [--top <n>] [-C <dir>] [global flags]`  
`bus journal import --profile <name> --file <path> [--source-id-from <column>] [--mapping-profile <name>] [--header-row <n>] [--map <field=header|column>] ... [-C <dir>] [global flags]`  
`bus journal classify <subcommand> ...`  
`bus journal template <post|apply> ...`

### What most users do with this module

`init` prepares the journal datasets and schemas.

`add` is the normal command for manual postings and for simple automation. It requires a balanced debit and credit set.

`balance` is the fastest way to answer “what is the balance as of this date?”.

`account-activity` is the best review tool when one account needs explanation. It shows movement rows together with voucher and source identifiers.

`import` is for legacy journal or day-book migration work where you want deterministic mapping rather than hand-posting old history.

`classify` is the bank-to-journal workflow. It can generate proposals from bank rows, apply approved proposals, learn candidate rules from earlier postings, and handle suspense or loan-split flows.

`template` is the recurring-entry helper. It is useful when one kind of supplier charge repeats with the same VAT logic over and over again.

### Important behavior

Entries must be balanced. If debit and credit totals differ, the command fails.

Accounts can be given as codes or as account names that already exist in the chart of accounts.

Visible voucher numbers follow the shared workspace ID policy when configured in [bus-config](./bus-config). Without a workspace override, the default visible voucher format is a yearly sequence such as `V-2026-000001`, while technical transaction IDs remain machine-friendly.

`--source-id` plus optional `--source-system` makes replay-safe posting possible. This is the simplest way to avoid duplicate automated postings.

The workspace storage format is handled automatically. Users normally do not need different journal commands for CSV and `PCSV-1`.

### A simple monthly flow

One common flow looks like this:

```bash
bus journal add --date 2026-01-31 --desc "Insurance" --debit 6400=350.00 --credit 1910=350.00
bus journal balance --as-of 2026-01-31
bus reports trial-balance --as-of 2026-01-31
```

If the journal lines come from bank automation instead of manual entry, the flow often becomes:

```bash
bus bank import --file ./statements/2026-01.csv
bus journal -o ./out/proposals.tsv classify bank --profile ./rules.yml
bus journal classify apply --proposal ./out/proposals.tsv
bus reports day-book --period 2026-01 --format pdf -o ./out/day-book-2026-01.pdf
```

### Output and flags

These commands use [Standard global flags](../cli/global-flags). The most important detail is that `--format` is mainly for `balance` and `account-activity`. Commands that write data, such as `add`, `import`, `classify apply`, and `template post`, are about mutation rather than report formatting.

Use `--dry-run` before `import`, `classify apply`, `template post`, or `template apply` when you want to preview the effect without writing.

For the full option list, run `bus journal --help`.

### Files

This module owns `journals.csv`, period journal files such as `journal-2026.csv`, and journal dimension tables at the workspace root.

### Exit status

`0` on success. Non-zero on invalid usage, unbalanced postings, schema violations, missing accounts, or attempts to post into closed or locked periods.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus journal add --date 2026-01-31 --desc "Bank fee" --debit 6570=12.50 --credit 1910=12.50
journal add --date 2026-01-31 --desc "Bank fee" --debit 6570=12.50 --credit 1910=12.50

# same as: bus journal --format tsv account-activity --account 1910 --period 2026
journal --format tsv account-activity --account 1910 --period 2026

# same as: bus journal template apply --template-file ./templates.yml --bank-csv ./bank.csv
journal template apply --template-file ./templates.yml --bank-csv ./bank.csv
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Module reference: bus-journal](../modules/bus-journal)
- [Module reference: bus-config](../modules/bus-config)
- [Module reference: bus-reports](../modules/bus-reports)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Design: Double-entry ledger](../design-goals/double-entry-ledger)
