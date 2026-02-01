## bus-loans

Bus Loans maintains loan master data and event logs in CSV datasets, generates
amortization schedules from contract terms, and produces journal posting
suggestions for loan activity.

The loan register also supports portfolio reporting for applications and special situations such as corporate restructuring, business reorganisation, debt adjustment, or debt restructuring.

### How to run

Run `bus loans` … and use `--help` for available
subcommands and arguments.

### Subcommands

- `init`: Create loan register datasets and schemas.
- `add`: Register a new loan contract in the loan register.
- `event`: Record loan events such as disbursements or repayments.
- `amortize`: Generate amortization schedules and posting outputs.

### Data it reads and writes

It reads and writes loan register and event datasets in the loans area, uses
reference data from [`bus accounts`](./bus-accounts) and
[`bus entities`](./bus-entities), and relies on JSON Table
Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes updated loan registers and schedules, emits posting suggestions for
[`bus journal`](./bus-journal), and provides validation
diagnostics for inconsistent terms.

### Finnish compliance responsibilities

Bus Loans MUST link loan transactions and amortization postings to dated, numbered vouchers and maintain an audit trail from postings to the underlying loan contracts and evidence.

### Integrations

It posts to [`bus journal`](./bus-journal) and influences
[`bus reports`](./bus-reports), linking to
[`bus bank`](./bus-bank) and
[`bus reconcile`](./bus-reconcile) for cash movements.

### See also

Repository: https://github.com/busdk/bus-loans

For schema expectations and append-only audit trails, see [Table schema contract](../data/table-schema-contract) and [Append-only and soft deletion](../data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-assets">bus-assets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
