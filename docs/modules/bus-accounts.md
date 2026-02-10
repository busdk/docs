## bus-accounts

### Name

`bus accounts` — manage the chart of accounts.

### Synopsis

`bus accounts <command> [options]`

### Description

`bus accounts` maintains the chart of accounts as schema-validated repository data. It enforces uniqueness and allowed account types so downstream modules can rely on stable account identifiers.

### Commands

- `init` creates the baseline accounts datasets and schemas.
- `list` prints the current chart of accounts in deterministic order.
- `add` adds a new account record.
- `validate` checks the accounts datasets against their schemas.

### Options

The `add` command accepts `--code <account-id>`, `--name <account-name>`, and `--type <asset|liability|equity|income|expense>`. For global flags and command-specific help, run `bus accounts --help`.

### Files

`accounts.csv` and its beside-the-table schema `accounts.schema.json` in the accounts area.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bfl">bus-bfl</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-entities">bus-entities</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-accounts](../sdd/bus-accounts)
- [Accounts layout: Accounts area](../layout/accounts-area)

