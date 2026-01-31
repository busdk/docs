## bus-bank

Bus Bank imports bank statement CSVs into schema-validated datasets, matches
transactions to invoices, entities, and accounts, and emits balanced journal
entries for posting into the ledger.

### How to run

Run `bus bank` … and use `--help` for available
subcommands and arguments.

### Data it reads and writes

It reads and writes bank statement and import datasets in the bank area, uses
reference data from [`bus entities`](./bus-entities),
[`bus accounts`](./bus-accounts), and
[`bus invoices`](./bus-invoices), and stores each JSON Table
Schema beside its CSV dataset.

### Outputs and side effects

It writes normalized bank transaction CSVs, produces journal postings for
[`bus journal`](./bus-journal), and emits matching and
reconciliation diagnostics.

### Finnish compliance responsibilities

Bus Bank MUST preserve source statement identifiers and transaction references from bank evidence. It MUST link each bank transaction to vouchers and resulting journal postings when reconciled, and it MUST retain original bank statement evidence via attachments metadata.

See [Finnish bookkeeping and tax-audit compliance](../spec/compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It feeds [`bus reconcile`](./bus-reconcile) with matched
transaction context and posts to [`bus journal`](./bus-journal),
affecting [`bus reports`](./bus-reports).

### See also

Repository: ./modules/bus-bank

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-loans](./bus-loans) · **Index:** [Modules](./) · **Next:** [bus-reconcile](./bus-reconcile)
<!-- busdk-docs-nav end -->
