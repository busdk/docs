---
title: bus accounts — manage the chart of accounts
description: bus accounts creates and maintains the chart of accounts, validates account definitions, renders a chart-of-accounts report, and owns the canonical account-group hierarchy.
---

## `bus accounts` — manage the chart of accounts

`bus accounts` owns the chart of accounts for the workspace. Use it when you need to create the account table, add or rename accounts, validate the chart, or print a filing-grade `tililuettelo`.

This is also the module that owns the canonical account-group hierarchy used by statutory reporting workflows.

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
bus accounts --format tsv groups
```

Explain one account's canonical group membership:

```bash
bus accounts groups explain --account 1910
```

Show one subtree with opening and closing balances:

```bash
bus accounts groups --group-id assets --as-of 2024-12-31 --opening-as-of 2024-01-01
```

Assign accounts to groups in bulk:

```bash
bus accounts groups assign --rule '1*=assets' --rule '1501=inventory_materials'
```

Add, update, or remove one group row without editing CSV by hand:

```bash
bus accounts groups add --group-id inventory --code 150 --name "Vaihto-omaisuus" --parent-group-id assets --profile bs_full
bus accounts groups set --group-id inventory --name "Aineet ja tarvikkeet" --profile bs_short
bus accounts groups delete --group-id inventory_materials
```

Create a printable chart-of-accounts PDF:

```bash
bus accounts report --format pdf --output tililuettelo.pdf
```

Show the automatic requested-date, prior-period, and opening-balance history view:

```bash
bus accounts report --as-of 2024-12-31 --format tsv
```

Override the final opening-balance column date explicitly when needed:

```bash
bus accounts report --as-of 2024-12-31 --opening-as-of 2024-01-01 --format tsv
```

Generate suggested lines for sole-proprietor owner withdrawal or investment:

```bash
bus accounts sole-proprietor withdrawal \
  --equity-code 2300 \
  --cash-code 1910 \
  --amount 500.00
```

### Synopsis

`bus accounts init [-C <dir>] [global flags]`  
`bus accounts validate [-C <dir>] [global flags]`  
`bus accounts list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus accounts groups [--group-id <group-id>] [--as-of <date>] [--opening-as-of <date>] [-C <dir>] [-o <file>] [-f <text|tsv>] [global flags]`  
`bus accounts groups explain --account <code> [-C <dir>] [-o <file>] [-f <text|tsv>] [global flags]`  
`bus accounts groups assign --rule <selector=group-id>... [-C <dir>] [global flags]`  
`bus accounts report [--as-of <date>] [--opening-as-of <date>] [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
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

### Reports and groups

`bus accounts init` now also creates `account-groups.csv` and
`account-groups.schema.json`. This dataset stores a stable `group_id`,
presentation `code`, group `name`, and optional `parent_group_id`. Use it for
the Finnish-style account tree instead of pretending that posting accounts are
group rows.

`bus accounts groups` prints that tree in a deterministic human-facing form.
It can also render one selected subtree, include opening and closing balances,
and print subgroup subtotals together with the full subtree total.
`bus accounts groups explain --account <code>` prints the canonical account to
group path for one posting account, including the code ancestry, the human
group path, and the direct `report_profiles` on the assigned group.
Validation rejects:
- orphan parent references
- cyclic group chains
- sibling groups under one parent reusing the same presentation code
- account rows whose optional `group_id` points to a missing group

Use `groups add`, `groups set`, and `groups delete` for first-class hierarchy
maintenance. Delete is safety-checked and refuses to remove a group that still
has child groups or account members.

`report` generates a `tililuettelo` view and can include journal-derived balances.
By default it shows one `Saldo` column for the selected workspace state. The
row order follows the canonical `account-groups.csv` hierarchy automatically,
so group rows with aggregated totals appear together with indented posting
accounts from `accounts.csv:group_id` without any extra report flag. In PDF
output the group rows are also styled as distinct hierarchy rows so it is easy
to tell groups from leaf accounts at a glance. When you add `--as-of`, the
report switches to explicit date-keyed balance history columns. The first
leftmost balance column is the requested document date, intermediate columns
come from prior period ends in newest-to-oldest order when the workspace has
period control data, and the final rightmost column is the fiscal-year opening
balance. `--opening-as-of` requires `--as-of` and lets you override that final
opening-balance date explicitly.
`groups assign` gives you a native way to set account-to-group membership in
bulk without hand-editing CSV rows.

For Finnish statutory reports, this module owns the only canonical reporting structure:

`account-groups.csv`

Every posting account belongs to one reporting group through `accounts.csv:group_id`.
Reports then derive their structure from that group tree. Short and full balance
sheet or profit-and-loss variants are controlled by each group's
`report_profiles`, not by separate account-to-layout override files.

This means there is no separate per-account reporting-classification file and no
layout-specific account-mapping file in the current model. The reporting tree is
configured in one place: `account-groups.csv`.

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

### Output and flags

These commands use [Standard global flags](../cli/global-flags). In practice:

`list` is usually used with `tsv`.

`report` is where `text`, `csv`, `markdown`, and `pdf` matter most.

For `groups`, prefer the canonical global-flag order `bus accounts --format tsv groups`.
That keeps command-specific flags like `--group-id` out of the trailing-global parser path.

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
