---
title: bus accounts — manage the chart of accounts
description: bus accounts creates and maintains the chart of accounts, validates account definitions, renders a chart-of-accounts report, and owns the account-side reporting classification files.
---

## `bus accounts` — manage the chart of accounts

`bus accounts` owns the chart of accounts for the workspace. Use it when you need to create the account table, add or rename accounts, validate the chart, or print a filing-grade `tililuettelo`.

This is also the module that owns the account-side reporting datasets used by statutory reporting workflows.

### Common tasks

Create the baseline accounts datasets:

```bash
bus accounts init
```

Add two common accounts and then validate the chart:

```bash
bus accounts add --code 1910 --name "Pankkitili" --type asset
bus accounts add --code 3000 --name "Myyntituotot" --type income
bus accounts validate
```

Rename an account without changing anything else:

```bash
bus accounts set --code 1910 --name "Pankkitili EUR"
```

List the chart in a script-friendly format:

```bash
bus accounts list --format tsv --output accounts.tsv
```

Show the first-class account-group tree:

```bash
bus accounts groups
bus accounts groups --format tsv
```

Create a printable chart-of-accounts PDF:

```bash
bus accounts report --format pdf --output tililuettelo.pdf
```

Generate suggested lines for sole-proprietor owner withdrawal or investment:

```bash
bus accounts sole-proprietor withdrawal \
  --equity-code 3000 \
  --cash-code 1910 \
  --amount 500.00
```

### Synopsis

`bus accounts init [-C <dir>] [global flags]`  
`bus accounts validate [-C <dir>] [global flags]`  
`bus accounts list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus accounts groups [-C <dir>] [-o <file>] [-f <text|tsv>] [global flags]`  
`bus accounts report [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus accounts add --code <account-id> --name <account-name> --type <asset|liability|equity|income|expense> [-C <dir>] [global flags]`  
`bus accounts set --code <account-id> [--name <account-name>] [--type <asset|liability|equity|income|expense>] [-C <dir>] [global flags]`  
`bus accounts sole-proprietor withdrawal|investment --equity-code <code> --cash-code <code> --amount <amount> [global flags]`

### Which command should you use?

`init` is the first command for a new workspace.

`add` creates a new account. `set` updates an existing one.

`validate` is the safety check before you rely on the chart in [bus-journal](./bus-journal), [bus-reports](./bus-reports), or [bus-vat](./bus-vat).

`list` is the quick machine-friendly view. `groups` is the native tree view for
first-class account groups. `report` is the accountant-facing and filing-facing
view.

`sole-proprietor` is a helper command for owner withdrawals and owner investments. It does not post anything by itself, but it gives you balanced lines that you can feed into [bus-journal](./bus-journal).

### Choosing the account type

For BusDK, every account must have one of these types:

| Type | Typical use |
| --- | --- |
| `asset` | cash, bank, receivables, fixed assets |
| `liability` | payables, loans, VAT payable |
| `equity` | share capital, retained earnings, owner’s capital |
| `income` | sales and other revenue |
| `expense` | purchases, services, wages, fees, depreciation |

If you are following a Finnish numbered chart, the common practical pattern is still useful: `1xxx` often means assets, `2xxx` liabilities, `3xxx` equity, `4xxx` income, and `5xxx` to `7xxx` expenses. BusDK does not force a national numbering scheme, but consistent typing matters because downstream modules use it.

### Reports, groups, and statutory mapping

`bus accounts init` now also creates `account-groups.csv` and
`account-groups.schema.json`. This dataset stores a stable `group_id`,
presentation `code`, group `name`, and optional `parent_group_id`. Use it for
the Finnish-style account tree instead of pretending that posting accounts are
group rows.

`bus accounts groups` prints that tree in a deterministic human-facing form.
Validation rejects:
- orphan parent references
- cyclic group chains
- sibling groups under one parent reusing the same presentation code
- account rows whose optional `group_id` points to a missing group

`report` generates a `tililuettelo` view and can include journal-derived balances.

For Finnish statutory reports, this module also owns the account classification and mapping datasets used together with [bus-reports](./bus-reports). In practice:

`report-account-classification.csv` is the place for canonical account meaning.

`report-account-mapping.csv` is the place for layout-specific overrides.

If you are just starting with statutory reporting, you usually do not edit these files first. Start with a clean chart, produce a report in [bus-reports](./bus-reports), and refine mappings only when you see a real placement problem.

### Typical workflow

For a new workspace, the flow is usually this:

```bash
bus accounts init
bus accounts add --code 1910 --name "Pankkitili" --type asset
bus accounts add --code 3000 --name "Sales income" --type income
bus accounts add --code 4000 --name "Purchases" --type expense
bus accounts validate
bus period init
bus journal init
```

### Files

The core files are `accounts.csv` and `accounts.schema.json` at the workspace root.
This module also owns:
- `account-groups.csv` and `account-groups.schema.json`
- `report-account-classification.csv` and its schema
- `report-account-mapping.csv` and its schema

### Output and flags

These commands use [Standard global flags](../cli/global-flags). In practice:

`list` is usually used with `tsv`.

`report` is where `text`, `csv`, `markdown`, and `pdf` matter most.

`add` and `set` support `--dry-run` when you want to validate a change without writing it.

For the full command and flag details, run `bus accounts --help`.

### Exit status

`0` on success. Non-zero on invalid usage, schema violations, duplicate account codes, or invalid account references.

### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus accounts add --code 4100 --name "Service revenue" --type income
accounts add --code 4100 --name "Service revenue" --type income

# same as: bus accounts set --code 4100 --name "Service revenue FI"
accounts set --code 4100 --name "Service revenue FI"

# same as: bus accounts report --format pdf --output tililuettelo.pdf
accounts report --format pdf --output tililuettelo.pdf
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-entities">bus-entities</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Module reference: bus-accounts](../modules/bus-accounts)
- [Module reference: bus-journal](../modules/bus-journal)
- [Module reference: bus-reports](../modules/bus-reports)
- [Accounts layout: Accounts area](../layout/accounts-area)
- [Finnish reporting taxonomy and account classification](../compliance/fi-reporting-taxonomy-and-account-classification)
