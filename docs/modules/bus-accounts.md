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

**Value promise:** Manage the chart of accounts as schema-validated workspace data so downstream modules and reports can rely on stable account identifiers and types.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview), [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 60% — init, add (all five types), list, validate, global flags and init contract verified by e2e and unit tests; user can complete the “define master data” chart step.

**Use case readiness:** Accounting workflow: 60% — init, add, list, validate and init contract (both-files-exist / partial-existence) verified; e2e covers full chart workflow. Finnish payroll handling: 60% — chart of accounts for wage expense, withholding, net payable verified by same e2e and unit tests.

**Current:** `tests/e2e_bus_accounts.sh` proves init (creates files, idempotent when both exist, fails when inconsistent or only CSV), add (asset, revenue, expense; dry-run no write), list (deterministic TSV, `--output`, `--format tsv`, `--quiet` no stdout/output file), validate, `-C` (invalid chdir and nested workdir), help/version, `--`, invalid `--format`/`--color`/quiet+verbose, and add `--help` documents `--type`. `run_test.go` covers init (creates, idempotent, both-exist-inconsistent, CSV-from-schema, CSV-without-schema), list, add (success, duplicate key, dry-run, missing required), validate, missing schema/CSV, schema parse/field/enum/PK/FK, usage. `run_flags_test.go` covers help/version ignore args, quiet, quiet+verbose invalid, invalid color, unknown format, chdir, output. `run_workspace_test.go` covers non-Git, MERGE_HEAD, conflict markers. `run_property_test.go` covers list permutation and add appends (all five types). `internal/cli/help_test.go` and `internal/cli/flags_test.go` cover help and flag parsing. `internal/storage/storage_test.go`, `internal/validate/validate_test.go`, `internal/accounts/accounts_test.go`, and `run_helpers_test.go` cover storage, validation, TSV sort, and workdir/color.

**Planned next:** None in PLAN; all SDD items implemented and covered. Optional SDD follow-ups (e.g. income/revenue wording in schema) when applicable.

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

