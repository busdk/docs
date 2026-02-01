## bus-reports

Bus Reports reads journal entries and reference data to compute reports,
verifies integrity and balances before emitting reports, and outputs reports in
text and structured formats.

### How to run

Run `bus reports` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `trial-balance`: Emit trial balance outputs for a period or as-of date.
- `general-ledger`: Emit general ledger outputs with account detail.
- `profit-and-loss`: Emit profit and loss (income statement) outputs.
- `balance-sheet`: Emit balance sheet outputs.

### Data it reads and writes

It reads journal data from [`bus journal`](./bus-journal) and
accounts from [`bus accounts`](./bus-accounts), optionally uses
budget data from [`bus budget`](./bus-budget), and uses JSON
Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes report outputs (text, CSV, or JSON) to stdout or files and emits
diagnostics for integrity or balance issues.

### Finnish compliance responsibilities

Bus Reports MUST generate financial statement outputs that are fully derivable from journal data without manual rewriting, and it MUST include or reference the basis for report line items so postings and vouchers remain traceable. It MUST support report sets needed for tax-audit packs, including trial balance, general ledger, profit and loss, and balance sheet, and it SHOULD support KPA and PMA formats when the user’s entity size requires them.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It consumes data from [`bus journal`](./bus-journal),
[`bus accounts`](./bus-accounts), and
[`bus budget`](./bus-budget), and feeds
[`bus filing`](./bus-filing) and management reporting
workflows.

### See also

Repository: https://github.com/busdk/bus-reports

For reporting workflow context and data integrity expectations, see [Accounting workflow overview](../workflow/accounting-workflow-overview) and [Append-only and soft deletion](../data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-vat">bus-vat</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing">bus-filing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
