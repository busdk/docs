---
title: bus accounts — manage the chart of accounts
description: "CLI reference for bus accounts: init, list, add, set, and validate the chart of accounts; schema-validated repository data and stable identifiers for downstream modules."
---

## Overview

### Synopsis

`bus accounts init [-C <dir>] [global flags]`  
`bus accounts list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus accounts add --code <account-id> --name <account-name> --type <asset|liability|equity|income|expense> [-C <dir>] [global flags]`  
`bus accounts set --code <account-id> [--name <account-name>] [--type <asset|liability|equity|income|expense>] [-C <dir>] [global flags]`  
`bus accounts validate [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus accounts` maintains the chart of accounts as schema-validated repository data. It enforces uniqueness and allowed account types so downstream modules can rely on stable account identifiers.

### Commands

- `init` creates the baseline accounts datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `list` prints the current chart of accounts in deterministic order.
- `add` creates a new account. It fails (non-zero exit, diagnostic on stderr, no change to the dataset) if an account with the same `--code` already exists. To change an existing account, use `set`.
- `set` modifies an existing account identified by `--code`. It updates only the attributes you supply (for example `--name` or `--type`). It fails if no account with that code exists.
- `validate` checks the accounts datasets against their schemas.

### Options

The `add` command requires `--code <account-id>`, `--name <account-name>`, and `--type <asset|liability|equity|income|expense>`. The `set` command requires `--code <account-id>` to identify the account and accepts optional `--name` and `--type` to update those attributes. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus accounts --help`.

### Choosing account type: Finnish numbering convention (practical guide)

The following is a **practical convention** used by many Finnish bookkeeping setups to choose the BusDK `--type` value when running `bus accounts add`. It is not a legal requirement and BusDK does not enforce any national numbering scheme. Organizations may customize numbering; when in doubt, follow the chart used in the previous year or your accountant’s guidance.

Many Finnish charts use the first digit (or leading digits) to group accounts by balance-sheet vs income-statement categories. You can use that pattern as a default heuristic to map account codes to BusDK types.

**1xxx — assets (`asset`).** Codes starting with 1 are typically asset accounts. Common subgroups: 10xx intangible assets; 11xx tangible assets and depreciation accumulations; 13xx receivables; 14xx cash, bank, and payment-provider accounts.

**2xxx — liabilities (`liability`).** Codes starting with 2 are typically liability accounts. Common subgroups: 20xx trade payables; 21xx VAT payable/receivable settlement accounts; 22xx–26xx other short- or long-term liabilities; 29xx private drawings or investment accounts for sole proprietors, depending on the firm’s practice.

**3xxx — equity (`equity`).** Codes starting with 3 are typically equity. In sole-proprietorship bookkeeping, owner’s equity and prior-year results are often in 3xxx; practices vary, so align with your accountant’s chart.

For sole proprietors, owner withdrawals (yksityisotto) and owner investments (yksityissijoitus) are posted with `bus journal add` using equity and cash/bank accounts from this chart; an optional helper command may be added later.

**4xxx — income.** Codes starting with 4 are typically income. VAT-rate-specific sales accounts (e.g. 4010, 4040, 4050) are common; exact numbering varies by chart.

**5xxx–7xxx — expenses (`expense`).** Codes starting with 5, 6, or 7 are typically expenses. Common subgroups include purchases, services, rent, marketing, travel, office, telecom, banking fees, insurance, accounting/legal, and depreciation.

**8xxx–9xxx — financial and result/summary accounts.** These ranges are often used for financial income/expense and for result or summary accounts. As a conservative default: 80xx–81xx are often financial income or expense — map them to `income` or `expense` according to their meaning. Many 9xxx “result” and “summary” accounts are used for reporting or closing rather than day-to-day posting; if you include them, still assign a BusDK type (`income` or `expense`) consistent with their meaning. BusDK does not enforce a specific national numbering scheme.

**Rules of thumb.** Prefer consistency over perfection: use the same mapping logic across your chart. If in doubt, follow the chart used in the previous year or the one your accountant uses. When migrating from Excel or ledger headers that only have code and name, you must assign `type` explicitly — BusDK needs it for reporting and validation.

### Write path and field coverage

The CLI surface covers the core lifecycle needed for scripts and UIs to create, update, and validate accounts. `bus accounts add` creates a new account and fails if that account code already exists; `bus accounts set` updates an existing account by code. Both commands refuse to write rows that would violate schema or invariants.

If your `accounts.csv` schema includes additional reporting and control columns (for example `ledger_category_id` and `is_active`), those fields are currently maintained by editing `accounts.csv` directly and then validating with `bus accounts validate` (and, for whole-workspace checks, `bus validate`). This keeps the authoritative dataset explicit while avoiding documentation that implies unsupported flags exist.

### Files

`accounts.csv` and its beside-the-table schema `accounts.schema.json` in the accounts area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `accounts/` folder). Path resolution is owned by this module; other tools obtain the path via this module’s API (see [Data path contract](../sdd/modules#data-path-contract-for-read-only-cross-module-access)).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value promise:** Manage the chart of accounts as schema-validated workspace data so downstream modules and reports can rely on stable account identifiers and types.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 60% — init, add (all five types), set, list, validate and init contract verified by e2e and unit tests; user can complete the “define master data” chart step.

**Use case readiness:** Accounting workflow: 60% — init, add, set, list, validate and init contract verified; e2e covers full chart workflow. Finnish payroll handling: 60% — chart of accounts for wage expense, withholding, net payable verified by same e2e and unit tests.

**Current:** `tests/e2e_bus_accounts.sh` proves init (creates files, idempotent when both exist, fails when inconsistent or only CSV), add (asset, income, expense; dry-run no write), set (modify, fail when missing, dry-run), list (deterministic TSV, `--output`, `--format tsv`, `--quiet` no stdout/output file), validate, `-C` (invalid chdir and nested workdir), help/version, `--`, invalid `--format`/`--color`/quiet+verbose, and add `--help` documents `--type`. `run_test.go` covers init (creates, idempotent, both-exist-inconsistent, CSV-from-schema, CSV-without-schema), list, add (success, duplicate key, dry-run, missing required), set (modify in place, fail when no account, dry-run, require `--code`), validate, missing schema/CSV, schema parse/field/enum/PK/FK, usage. `run_set_test.go` covers set args and updateAccountCSV. `run_flags_test.go` covers help/version ignore args, quiet, quiet+verbose invalid, invalid color, unknown format, chdir, output. `run_workspace_test.go` covers non-Git, MERGE_HEAD, conflict markers. `run_property_test.go` covers list permutation and add appends (all five types). `internal/cli/help_test.go` and `internal/cli/flags_test.go` cover help and flag parsing. `internal/storage/storage_test.go`, `internal/validate/validate_test.go`, `internal/accounts/accounts_test.go`, and `run_helpers_test.go` cover storage, validation, TSV sort, and workdir/color.

**Planned next:** Optional sole-proprietor withdrawal/investment helper (balanced entry from recommended accounts); advances accounting workflow. See [Development status](../implementation/development-status).

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-loans](./bus-loans) validates account IDs when reference datasets exist; accounting workflow uses accounts as master data.

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
- [Module SDD: bus-accounts](../sdd/bus-accounts)
- [Accounts layout: Accounts area](../layout/accounts-area)

