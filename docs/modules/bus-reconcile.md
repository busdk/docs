# bus-reconcile

Bus Reconcile links bank transactions to invoices or journal entries, allocates
payments (partials, splits, fees) with audit trails, and stores reconciliation
state as schema-validated CSV datasets.

## How to run

Run `bus reconcile` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes reconciliation datasets in the reconciliation area, uses
bank data from [`bus bank`](./bus-bank) and invoices from
[`bus invoices`](./bus-invoices), and relies on JSON Table
Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes reconciliation CSVs and allocation details, and emits diagnostics for
unmatched items or invalid allocations.

## Finnish compliance responsibilities

Bus Reconcile MUST link bank transactions to invoices or journal entries with stable reconciliation IDs, and it MUST preserve allocation history for partials, splits, and fees without overwriting prior state. It MUST provide audit-trail references from reconciled items back to vouchers and evidence.

See [Finnish bookkeeping and tax-audit compliance](../spec/compliance/fi-bookkeeping-and-tax-audit).

## Integrations

It feeds status updates back to [`bus invoices`](./bus-invoices)
and reporting modules, and connects bank data with ledger postings in
[`bus journal`](./bus-journal).

## See also

Repository: ./modules/bus-reconcile

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-bank](./bus-bank) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-budget](./bus-budget)
<!-- busdk-docs-nav end -->
