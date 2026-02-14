---
title: bus accounts — manage the chart of accounts
description: "CLI reference for bus accounts: init, list, add, and validate the chart of accounts; schema-validated repository data and stable identifiers for downstream modules."
---

## Overview

### Synopsis

`bus accounts init [-C <dir>] [global flags]`  
`bus accounts list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus accounts add --code <account-id> --name <account-name> --type <asset|liability|equity|income|expense> [-C <dir>] [global flags]`  
`bus accounts validate [-C <dir>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus accounts` maintains the chart of accounts as schema-validated repository data. It enforces uniqueness and allowed account types so downstream modules can rely on stable account identifiers.

### Commands

- `init` creates the baseline accounts datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `list` prints the current chart of accounts in deterministic order.
- `add` adds a new account record.
- `validate` checks the accounts datasets against their schemas.

### Options

The `add` command accepts `--code <account-id>`, `--name <account-name>`, and `--type <asset|liability|equity|income|expense>`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus accounts --help`.

### Write path and field coverage

The CLI surface covers the core lifecycle needed for scripts and UIs to create and validate accounts. `bus accounts add` writes the stable account identifier, name, and type, and it refuses to write rows that would violate schema or invariants.

If your `accounts.csv` schema includes additional reporting and control columns (for example `ledger_category_id` and `is_active`), those fields are currently maintained by editing `accounts.csv` directly and then validating with `bus accounts validate` (and, for whole-workspace checks, `bus validate`). This keeps the authoritative dataset explicit while avoiding documentation that implies unsupported flags exist.

### Files

`accounts.csv` and its beside-the-table schema `accounts.schema.json` in the accounts area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `accounts/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value:** Manage the chart of accounts as schema-validated workspace data so downstream modules and reports can rely on stable account identifiers and types.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 60% (Stable) — init, add (all types), list, and validate verified by e2e; full chart-of-accounts workflow is test-backed.

**Use case readiness:** Accounting workflow: 60% — init, add (all types), list, validate verified; init contract when both files exist and help for `--type` would complete the step. Finnish payroll handling: 60% — chart of accounts for wage expense, withholding, net payable; e2e covers full workflow.

**Current:** E2e script `tests/e2e_accounts.sh` proves init creates `accounts.csv` and schema; add with asset, liability, equity, revenue, and expense types appends correct rows; list produces deterministic TSV; validate succeeds after add. Unit tests in `run_test.go`, `storage_test.go`, `validate_test.go`, `flags_test.go` cover storage, validation, flags, and help.

**Planned next:** Enforce full init contract when both files exist (validate then warn or fail); document allowed `--type` in add help; optional income/revenue alignment.

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

