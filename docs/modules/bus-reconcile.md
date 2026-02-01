## bus-reconcile

Bus Reconcile links bank transactions to invoices or journal entries, allocates
payments (partials, splits, fees) with audit trails, and stores reconciliation
records as schema-validated datasets.

### How to run

Run `bus reconcile` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `match`: Match bank transactions to invoices or journal entries.
- `allocate`: Record allocation details for partials, splits, and fees.
- `list`: List reconciliation records and allocation history.

### Data it reads and writes

It reads and writes reconciliation datasets in the reconciliation area, uses
bank data from [`bus bank`](./bus-bank) and invoices from
[`bus invoices`](./bus-invoices), and relies on JSON Table
Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes reconciliation CSVs and allocation details, and emits diagnostics for
unmatched items or invalid allocations.

### Finnish compliance responsibilities

Bus Reconcile MUST link bank transactions to invoices or journal entries with stable reconciliation IDs, and it MUST preserve allocation history for partials, splits, and fees without overwriting prior records. It MUST maintain chronological ordering of allocations and provide bidirectional audit-trail references from reconciled items to bank transactions, vouchers, and evidence.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It feeds status updates back to [`bus invoices`](./bus-invoices)
and reporting modules, and connects bank data with ledger postings in
[`bus journal`](./bus-journal).

### See also

Repository: https://github.com/busdk/bus-reconcile

For reconciliation workflow context, see [Import bank transactions and apply payment](../workflow/import-bank-transactions-and-apply-payment) and [Accounting workflow overview](../workflow/accounting-workflow-overview).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-bank">bus-bank</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-budget">bus-budget</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
