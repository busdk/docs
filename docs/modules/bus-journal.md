## bus-journal

Bus Journal maintains journal entries as append-only CSV datasets, validates
schema conformance and balanced transaction invariants, and acts as the
authoritative source of ledger postings.

### How to run

Run `bus journal` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `init`: Initialize journal datasets and schemas in the repository root.
- `add`: Append a balanced journal entry to the ledger.
- `balance`: Compute balances as of a given date.

### Data it reads and writes

It reads and writes the journal index table `journals.csv` in the repository
root and the period journal files it references (for example
`2026/journals/2026-journal.csv`). It uses reference data from
[`bus accounts`](./bus-accounts) and other posting sources, and uses
JSON Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes new or updated journal entry rows and emits diagnostics for unbalanced
or invalid entries.

### Finnish compliance responsibilities

Bus Journal MUST write append-only journal entries with stable `entry_id` and `transaction_id` values, and it MUST link every entry to a `voucher_id` while preserving references to source documents or attachments. It MUST support both chronological and systematic ordering, including deterministic sequencing, and it MUST preserve links from combined postings to the underlying subledger records and vouchers. It MUST support correction entries that reference the original entry rather than overwriting it and respect period locks to prevent edits after close.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It receives postings from [`bus invoices`](./bus-invoices),
[`bus bank`](./bus-bank),
[`bus assets`](./bus-assets),
[`bus payroll`](./bus-payroll), and
[`bus loans`](./bus-loans), and serves as the foundation for
[`bus reports`](./bus-reports),
[`bus budget`](./bus-budget), and
[`bus vat`](./bus-vat).

### See also

Repository: https://github.com/busdk/bus-journal

For ledger structure and append-only expectations, see [Journal area](../layout/journal-area) and [Double-entry ledger](../design-goals/double-entry-ledger).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-pdf">bus-pdf</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-assets">bus-assets</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
