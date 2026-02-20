---
title: bus accounts — manage the chart of accounts
description: "CLI reference for bus accounts: init, list, add, set, validate, and sole-proprietor; chart of accounts as schema-validated repository data and stable identifiers for downstream modules."
---

## Overview

### Synopsis

`bus accounts init [-C <dir>] [global flags]`  
`bus accounts list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus accounts add --code <account-id> --name <account-name> --type <asset|liability|equity|income|expense> [-C <dir>] [global flags]`  
`bus accounts set --code <account-id> [--name <account-name>] [--type <asset|liability|equity|income|expense>] [-C <dir>] [global flags]`  
`bus accounts validate [-C <dir>] [global flags]`  
`bus accounts sole-proprietor withdrawal|investment --equity-code <code> --cash-code <code> --amount <amount> [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus accounts` maintains the chart of accounts as schema-validated repository data.
It enforces uniqueness and valid account types so downstream modules can rely on stable identifiers.

For Finnish statutory statements in [bus-reports](./bus-reports), this module also owns the account-to-statement mapping dataset contract.

### Commands

`init` creates baseline accounts datasets and schemas. If they already exist in full, `init` warns and exits 0 without changing anything. If they exist only partially, `init` fails and does not modify files.

`list` prints the current chart in deterministic order. `add` creates a new account and fails if `--code` already exists. `set` updates an existing account by `--code` and changes only attributes you provide, such as `--name` or `--type`. `validate` checks both data rows and `accounts.schema.json`, including malformed schema-level definitions.

`sole-proprietor` emits balanced double-entry lines for owner withdrawal (`withdrawal`) and owner investment (`investment`). It requires `--equity-code`, `--cash-code`, and `--amount`, does not modify `accounts.csv`, and outputs TSV lines that can be used with `bus journal add`.

### Options

`add` requires `--code <account-id>`, `--name <account-name>`, and `--type <asset|liability|equity|income|expense>`.

`set` requires `--code <account-id>` and supports `--name <account-name>` and `--type <asset|liability|equity|income|expense>`.

`sole-proprietor withdrawal|investment` requires `--equity-code <code>`, `--cash-code <code>`, and `--amount <positive number>`.

Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus accounts --help` or `bus accounts --help sole-proprietor`.

### Choosing account type: Finnish numbering convention (practical guide)

The following is a **practical convention** used by many Finnish bookkeeping setups to choose the BusDK `--type` value when running `bus accounts add`. It is not a legal requirement and BusDK does not enforce any national numbering scheme. Organizations may customize numbering; when in doubt, follow the chart used in the previous year or your accountant’s guidance.

Many Finnish charts use the first digit (or leading digits) to group accounts by balance-sheet vs income-statement categories. You can use that pattern as a default heuristic to map account codes to BusDK types.

**1xxx — assets (`asset`).** Codes starting with 1 are typically asset accounts. Common subgroups: 10xx intangible assets; 11xx tangible assets and depreciation accumulations; 13xx receivables; 14xx cash, bank, and payment-provider accounts.

**2xxx — liabilities (`liability`).** Codes starting with 2 are typically liability accounts. Common subgroups: 20xx trade payables; 21xx VAT payable/receivable settlement accounts; 22xx–26xx other short- or long-term liabilities; 29xx private drawings or investment accounts for sole proprietors, depending on the firm’s practice.

**3xxx — equity (`equity`).** Codes starting with 3 are typically equity. In sole-proprietorship bookkeeping, owner’s equity and prior-year results are often in 3xxx; practices vary, so align with your accountant’s chart.

For sole proprietors, use `bus accounts sole-proprietor withdrawal` or `bus accounts sole-proprietor investment` to produce balanced TSV lines (code, side, amount) that you can feed into `bus journal add`; the command does not read or write the chart of accounts.

**4xxx — income.** Codes starting with 4 are typically income. VAT-rate-specific sales accounts (e.g. 4010, 4040, 4050) are common; exact numbering varies by chart.

**5xxx–7xxx — expenses (`expense`).** Codes starting with 5, 6, or 7 are typically expenses. Common subgroups include purchases, services, rent, marketing, travel, office, telecom, banking fees, insurance, accounting/legal, and depreciation.

**8xxx–9xxx — financial and result/summary accounts.** These ranges are often used for financial income/expense and for result or summary accounts. As a conservative default: 80xx–81xx are often financial income or expense — map them to `income` or `expense` according to their meaning. Many 9xxx “result” and “summary” accounts are used for reporting or closing rather than day-to-day posting; if you include them, still assign a BusDK type (`income` or `expense`) consistent with their meaning. BusDK does not enforce a specific national numbering scheme.

**Rules of thumb.** Prefer consistency over perfection and use the same mapping logic across your chart.
If in doubt, follow the previous-year chart or your accountant’s guidance.
When migrating from code/name-only ledgers, assign `type` explicitly.

### Write path and field coverage

The CLI surface covers the core lifecycle needed for scripts and UIs to create, update, and validate accounts. `bus accounts add` creates a new account and fails if that account code already exists; `bus accounts set` updates an existing account by code. Both commands refuse to write rows that would violate schema or invariants.

If your `accounts.csv` schema includes additional reporting and control columns (for example `ledger_category_id` and `is_active`), those fields are currently maintained by editing `accounts.csv` directly and then validating with `bus accounts validate` (and, for whole-workspace checks, `bus validate`). This keeps the authoritative dataset explicit while avoiding documentation that implies unsupported flags exist.

For Finnish statutory reports, account-to-line mapping is maintained in `report-account-mapping.csv` with beside-the-table schema `report-account-mapping.schema.json`.
Minimum fields are `layout_id`, `account_code`, `statement_target`, `layout_line_id`, and `normal_side` (optional `rollup_rule`).
The mapping is deterministic per selected layout and consumed by [bus-reports](./bus-reports).

### Files

`accounts.csv` and its beside-the-table schema `accounts.schema.json` in the accounts area are the core chart datasets. For statutory statement mapping, the module also owns `report-account-mapping.csv` and `report-account-mapping.schema.json`. Schemas must be valid Frictionless Table Schema documents so that bus-data and other BusDK modules (for example bus-journal and bus-reports) can parse and use them without errors. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `accounts/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Examples

```bash
bus accounts init
bus accounts add --code 3000 --name "Sales income" --type income
bus accounts set --code 3000 --name "Domestic sales income"
bus accounts list --format tsv --output ./out/accounts.tsv
bus accounts sole-proprietor withdrawal --equity-code 2010 --cash-code 1910 --amount 2500
```

### Exit status

`0` on success. Non-zero on errors, including invalid usage, row-level schema violations, or an invalid or malformed schema document.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus accounts add --code 4100 --name "Service revenue" --type income
accounts add --code 4100 --name "Service revenue" --type income

# same as: bus accounts set --code 4100 --name "Service revenue FI"
accounts set --code 4100 --name "Service revenue FI"

# same as: bus accounts sole-proprietor investment --equity-code 2010 --cash-code 1910 --amount 1000
accounts sole-proprietor investment --equity-code 2010 --cash-code 1910 --amount 1000
```


### Development state

**Value promise:** Manage the chart of accounts as schema-validated workspace data so downstream modules and reports can rely on stable account identifiers and types.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 70% — chart lifecycle and sole-proprietor verified by e2e and unit tests; user can complete define-master-data and produce owner withdrawal/investment lines for journal.

**Use case readiness:** Accounting workflow: 70% — chart lifecycle and sole-proprietor verified; define-master-data step completable. Sale invoicing: 70% — chart for income/VAT accounts verified. Finnish payroll handling: 70% — chart for wage expense, withholding, net payable verified.

**Current:** Init/add/set/list/validate and sole-proprietor flows are test-verified, including global-flag behavior.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-accounts](../sdd/bus-accounts).

**Planned next:** Define and own report-account-mapping schema contract (FR-ACC-006) for [bus-reports](./bus-reports) fi-* layouts (PLAN.md); advances compliance and reporting. Document where bus journal add regression test is maintained or add when [bus-journal](./bus-journal) is available; advances accounting workflow.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-journal](./bus-journal) consumes account codes for postings; [bus-reports](./bus-reports) consumes account mapping for fi-* statutory layouts; [bus-loans](./bus-loans) validates account IDs when reference datasets exist; accounting workflow uses accounts as master data.

See [Development status](../implementation/development-status).

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
- [Module SDD: bus-reports](../sdd/bus-reports)
- [Module SDD: bus-accounts](../sdd/bus-accounts)
- [Accounts layout: Accounts area](../layout/accounts-area)
