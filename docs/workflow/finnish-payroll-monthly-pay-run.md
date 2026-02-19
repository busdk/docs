---
title: Finnish payroll handling (monthly pay run)
description: "Run monthly payroll for a small company: prerequisites, employee register, pay run with pay date, balanced posting intent for wages and withholdings, and how postings feed the journal and bank reconciliation."
---

## Finnish payroll handling (monthly pay run)

This workflow describes the bookkeeping core of running payroll in a small company: ensuring the chart of accounts, accounting entity, and periods are in place; maintaining the employee register; running payroll for a month with a chosen pay date; producing balanced posting intent for wages and withholdings; and feeding those postings into the journal and later into bank and reconciliation steps. The journey is expressed in BusDK datasets and `bus payroll` commands so that salary and tax entries stay traceable and double-entry consistent.

### Prerequisites

Payroll depends on the same master data as the rest of the accounting workflow. The [chart of accounts](../master-data/chart-of-accounts/index) must include the accounts used for wage expense, withholding payables, and net pay (and, where applicable, employer-side costs). The [accounting entity](../master-data/accounting-entity/index) and [accounting periods](../master-data/accounting-periods/index) must be configured so that the payroll month and pay date fall within an open period. Alice ensures these are in place using [`bus accounts`](../modules/bus-accounts), [`bus entities`](../modules/bus-entities), and [`bus period`](../modules/bus-period) before setting up employees or running payroll.

### Employee register and payroll run data

Payroll datasets include employees, payruns, payments, and posting-account mappings at workspace root. The [employees](../master-data/employees/index) records store employee identity, entity reference, dates, gross pay, withholding rate, and ledger accounts. These accounts are used to produce balanced posting lines.

Use `bus payroll validate` to check that the full payroll dataset is internally consistent before exporting postings.

### Exporting postings for a month

In the current module release, postings are produced by exporting a selected final payrun:

```bash
bus payroll validate
bus payroll export pr-001
```

`export` produces deterministic posting CSV lines for journal import workflows. The export keeps payroll-to-journal traceability explicit through payrun and employee identifiers in each row.

### From posting intent to journal and bank

The posting output from `bus payroll export` is intended to be consumed by the journal. Alice (or a script) appends the posting lines to the workspace journal dataset using [`bus journal add`](../modules/bus-journal) or an equivalent append path so that payroll appears in the same ledger as invoices and other transactions. Once in the journal, payroll postings participate in [trial balance](../modules/bus-reports) and period close like any other entries. When net pay is later paid from the company bank account, that bank transaction is imported with [`bus bank import`](../modules/bus-bank) and can be matched or reconciled against the payroll-related journal entries using [`bus reconcile`](../modules/bus-reconcile), keeping the link between pay run, ledger, and bank statement explicit.

### Scope: what works today versus planned

Today the [bus-payroll](../modules/bus-payroll) module implements `validate` and `export`. Integration tests in the module repository prove that validation succeeds for complete payroll datasets and that export produces deterministic CSV posting lines for a given run; global flags (including `-C`, `-o`, `-q`, `-v`, `--color`, `--format`) are covered by unit and integration tests. The end-to-end journey from empty workspace through employee register and monthly run to journal append is not yet first-class in this module, because commands such as `init`, `run`, `list`, and employee maintenance are still planned. In practice you can maintain payroll CSV and schema files (by hand or by another tool), run `bus payroll validate` to check consistency, and run `bus payroll export <run-id>` to obtain posting CSV for manual or scripted journal append.

Planned extensions include first-class `init`, `run`, `list`, and `employee` command surfaces, deeper employer-cost handling, and integration with authority filing (for example tax and pension reporting). Those are out of scope for this workflow page; the [Development status](../implementation/development-status#finnish-payroll-handling-monthly-pay-run) table summarizes current readiness per module for this journey.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./year-end-close">Year-end close (closing entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Example end-to-end workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evolution-over-time">Evolution over time (extending the model)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-payroll module](../modules/bus-payroll)
- [Employees master data](../master-data/employees/index)
- [Payroll runs master data](../master-data/payroll-runs/index)
- [Accounting workflow overview](./accounting-workflow-overview)
- [Development status](../implementation/development-status)
