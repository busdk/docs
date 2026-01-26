# bus-accounts

Bus Accounts maintains the chart of accounts as schema-validated CSV datasets.
It enforces uniqueness and allowed account types (asset, liability, equity,
income, expense) and provides consistent account references for downstream
modules.

## How to run

Run `bus accounts` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes `accounts.csv` (and optional related references) in the
accounts area, with each JSON Table Schema stored beside its CSV dataset.

## Outputs and side effects

It writes updated CSV datasets when you add or change accounts and emits
validation and integrity diagnostics to stdout/stderr.

## Integrations

It is used by [`bus journal`](./bus-journal),
[`bus reports`](./bus-reports),
[`bus budget`](./bus-budget),
[`bus invoices`](./bus-invoices),
[`bus bank`](./bus-bank),
[`bus assets`](./bus-assets),
[`bus loans`](./bus-loans), and
[`bus payroll`](./bus-payroll) for account mapping.

## See also

Repository: ./modules/bus-accounts
