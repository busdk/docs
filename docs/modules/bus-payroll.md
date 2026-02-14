---
title: bus-payroll — run payroll and generate postings
description: bus payroll maintains employee and payroll run datasets, validates payroll totals, and produces journal posting outputs for wages and withholdings.
---

## `bus-payroll` — run payroll and generate postings

### Synopsis

`bus payroll init [-C <dir>] [global flags]`  
`bus payroll run --month <YYYY-MM> [--run-id <id>] [--pay-date <YYYY-MM-DD>] [-C <dir>] [global flags]`  
`bus payroll list [-C <dir>] [-o <file>] [-f <format>] [global flags]`  
`bus payroll employee add --employee-id <id> --entity <entity-id> --start-date <date> [--end-date <date>] --gross <amount> --withholding-rate <rate> --wage-expense <account> --withholding-payable <account> --net-payable <account> [-C <dir>] [global flags]`  
`bus payroll employee list [-C <dir>] [-o <file>] [-f <format>] [global flags]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus payroll` maintains employee and payroll run datasets, validates payroll totals, and produces journal posting outputs for wages and withholdings. Data is schema-validated and append-only for auditability.

### Commands

- `init` creates the baseline payroll datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `run` runs payroll for a month and produces postings.
- `list` lists payroll runs.
- `employee add` adds an employee record.
- `employee list` lists employees in stable identifier order.

### Options

`run` accepts `--month <YYYY-MM>`, `--run-id`, `--pay-date <YYYY-MM-DD>`. `employee add` accepts `--employee-id`, `--entity`, `--start-date`, `--end-date` (optional), `--gross`, `--withholding-rate`, `--wage-expense`, `--withholding-payable`, `--net-payable`. Global flags are defined in [Standard global flags](../cli/global-flags). For command-specific help, run `bus payroll --help`.

### Files

Payroll datasets and their beside-the-table schemas in the payroll area. Master data for this module is stored in the workspace root only; the module does not use subdirectories (for example, no `payroll/` folder).

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### Development state

**Value promise:** Run payroll and produce postings so salary and related entries can feed the [bus-journal](./bus-journal); validate and export support a focused payroll scope.

**Use cases:** [Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run).

**Completeness:** 40% (Meaningful task, partial verification) — validate and export implemented; integration and unit tests cover flags and run. No e2e for full payroll run.

**Use case readiness:** Finnish payroll handling (monthly pay run): 40% — validate and export verified by integration tests; init, run, list, employee not implemented; no e2e for full pay-run journey.

**Current:** Integration tests in `run_test.go` prove validation of payroll datasets and deterministic export CSV for a run; unit tests in `internal/cli/flags_test.go` cover flag parsing and global flags. No e2e for full pay-run journey.

**Planned next:** Align CLI and layout with docs (init, run, list, employee); e2e for run → export → journal; README `make check`; test that `--no-color` disables color on stderr.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Standalone payroll runs; postings feed [bus-journal](./bus-journal).

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-inventory">bus-inventory</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-budget">bus-budget</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Employees](../master-data/employees/index)
- [Owns master data: Payroll runs](../master-data/payroll-runs/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Module SDD: bus-payroll](../sdd/bus-payroll)
- [Workflow: Finnish payroll handling (monthly pay run)](../workflow/finnish-payroll-monthly-pay-run)
- [Workflow: Accounting workflow overview](../workflow/accounting-workflow-overview)

