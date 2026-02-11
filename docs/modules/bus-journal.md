## bus-journal

### Name

`bus journal` — post and query ledger journal entries.

### Synopsis

`bus journal <command> [options]`

### Description

`bus journal` maintains the authoritative ledger as append-only journal entries. It enforces balanced debits and credits and respects period close and lock boundaries. Other modules post into the journal; this CLI adds entries and reports balances.

### Commands

- `init` creates the journal index and baseline period datasets and schemas. If they already exist in full, `init` prints a warning to stderr and exits 0 without changing anything. If they exist only partially, `init` fails with an error and does not modify any file.
- `add` appends a balanced transaction (one or more debit and credit lines).
- `balance` prints account balances as of a given date.

### Options

`add` accepts `--date <YYYY-MM-DD>`, `--desc <text>`, and repeatable `--debit <account>=<amount>` and `--credit <account>=<amount>`. At least one debit and one credit are required; total debits must equal total credits. `balance` accepts `--as-of <YYYY-MM-DD>`. For global flags and command-specific help, run `bus journal --help`.

### Files

Journal index `journals.csv` at repository root and period journal files (e.g. `2026/journals/2026-journal.csv`) with beside-the-table schemas.

### Exit status

`0` on success. Non-zero on invalid usage, unbalanced postings, or schema or period violations.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bank">bus-bank</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Module SDD: bus-journal](../sdd/bus-journal)
- [Layout: Journal area](../layout/journal-area)
- [Design: Double-entry ledger](../design-goals/double-entry-ledger)

