## bus-payroll

### Name

`bus payroll` — run payroll and generate postings.

### Synopsis

`bus payroll <command> [options]`  
`bus payroll employee add [options]`  
`bus payroll employee list`

### Description

`bus payroll` maintains employee and payroll run datasets, validates payroll totals, and produces journal posting outputs for wages and withholdings. Data is schema-validated and append-only for auditability.

### Commands

- `init` creates the baseline payroll datasets and schemas.
- `run` runs payroll for a month and produces postings.
- `list` lists payroll runs.
- `employee add` adds an employee record.
- `employee list` lists employees in stable identifier order.

### Options

`run` accepts `--month <YYYY-MM>`, `--run-id`, `--pay-date <YYYY-MM-DD>`. `employee add` accepts `--employee-id`, `--entity`, `--start-date`, `--end-date` (optional), `--gross`, `--withholding-rate`, `--wage-expense`, `--withholding-payable`, `--net-payable`. For global flags and command-specific help, run `bus payroll --help`.

### Files

Payroll datasets and their beside-the-table schemas in the payroll area.

### Exit status

`0` on success. Non-zero on errors, including invalid usage or schema violations.

### See also

Module SDD: [bus-payroll](../sdd/bus-payroll)  
Workflow: [Accounting workflow overview](../workflow/accounting-workflow-overview)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-budget">bus-budget</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-inventory">bus-inventory</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
