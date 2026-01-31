## bus-period

Bus Period opens and closes accounting periods in the workspace, generates
closing and opening balance entries, and locks periods to prevent changes after
close.

### How to run

Run `bus period` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads and writes period control datasets in the period area, uses journal
data from [`bus journal`](./bus-journal) for closing
calculations, and uses JSON Table Schemas stored beside their CSV datasets.

### Outputs and side effects

It writes period datasets and closing entry outputs, and emits diagnostics
for unbalanced or invalid period closures.

### Finnish compliance responsibilities

Bus Period MUST lock closed periods and prevent edits that would break reported data. It MUST create opening and closing entries as append-only records with references, and it MUST support an annual close package containing period datasets, reports, and references.

See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

### Integrations

It consumes [`bus journal`](./bus-journal) data and may emit
postings back to it, and is required before
[`bus filing`](./bus-filing) and authority export workflows.

### See also

Repository: https://github.com/busdk/bus-period

For period close workflow context, see [Year-end close (closing entries)](../workflow/year-end-close) and [Accounting workflow overview](../workflow/accounting-workflow-overview).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-entities">bus-entities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
