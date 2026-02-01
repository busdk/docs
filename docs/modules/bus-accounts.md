## bus-accounts

Bus Accounts maintains the chart of accounts as schema-validated CSV datasets.
It enforces uniqueness and allowed account types (asset, liability, equity,
income, expense) and provides consistent account references for downstream
modules.

### How to run

Run `bus accounts` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `init`: Create the accounts datasets and schemas in the accounts area.
- `list`: List chart of accounts entries with optional filters or output formats.
- `add`: Append a new account row to the chart of accounts.

### Data it reads and writes

It reads and writes `accounts.csv` (and optional related references) in the
accounts area, with each JSON Table Schema stored beside its CSV dataset.

### Outputs and side effects

It writes updated CSV datasets when you add or change accounts and emits
validation and integrity diagnostics to stdout/stderr.

### Finnish compliance responsibilities

Bus Accounts MUST maintain stable account identifiers that remain traceable across schema evolution, and it MUST preserve the chart of accounts as repository data for the full retention period. It MUST keep account metadata suitable for the methods description and for the dataset list required in Finnish bookkeeping.

### Integrations

It is used by [`bus journal`](./bus-journal),
[`bus reports`](./bus-reports),
[`bus budget`](./bus-budget),
[`bus invoices`](./bus-invoices),
[`bus bank`](./bus-bank),
[`bus assets`](./bus-assets),
[`bus loans`](./bus-loans), and
[`bus payroll`](./bus-payroll) for account mapping.

### See also

Repository: https://github.com/busdk/bus-accounts

For account dataset layout and schema expectations, see [Accounts area](../layout/accounts-area) and [Table schema contract](../data/table-schema-contract).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-entities">bus-entities</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
