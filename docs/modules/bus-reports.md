## bus-reports

Bus Reports reads journal entries and reference data to compute reports,
verifies integrity and balances before emitting reports, and outputs reports in
text and structured formats.

### How to run

Run `bus reports` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads journal data from [`bus journal`](./bus-journal) and
accounts from [`bus accounts`](./bus-accounts), optionally uses
budget data from [`bus budget`](./bus-budget), and uses JSON
Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes report outputs (text, CSV, or JSON) to stdout or files and emits
diagnostics for integrity or balance issues.

### Finnish compliance responsibilities

Bus Reports MUST generate financial statement outputs that can be traced back to ledger postings, and it MUST include or reference the basis for report line items to demonstrate the audit trail. It SHOULD support KPA and PMA formats when the user’s entity size requires them.

See [Finnish bookkeeping and tax-audit compliance](../spec/compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It consumes data from [`bus journal`](./bus-journal),
[`bus accounts`](./bus-accounts), and
[`bus budget`](./bus-budget), and feeds
[`bus filing`](./bus-filing) and management reporting
workflows.

### See also

Repository: https://github.com/busdk/bus-reports

For reporting workflow context and data integrity expectations, see [Accounting workflow overview](../spec/workflow/accounting-workflow-overview) and [Append-only and soft deletion](../spec/data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-vat">bus-vat</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing">bus-filing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
