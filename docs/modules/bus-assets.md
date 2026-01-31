## bus-assets

Bus Assets keeps a fixed-asset register as schema-validated CSV datasets,
generates depreciation schedules with clear audit trails, and produces
depreciation postings for [`bus journal`](./bus-journal) and
period close tooling.

### How to run

Run `bus assets` … and use `--help` for
available subcommands and arguments.

### Data it reads and writes

It reads and writes fixed asset register datasets in the assets area, with each
JSON Table Schema stored beside its CSV dataset.

### Outputs and side effects

It writes updated register and schedule CSVs, emits depreciation postings or
posting suggestions for the journal, and provides validation and reconciliation
diagnostics.

### Integrations

It posts to [`bus journal`](./bus-journal) and participates in
[`bus period`](./bus-period) closing workflows, using
[`bus accounts`](./bus-accounts) for account mapping and
reporting.

### See also

Repository: ./modules/bus-assets

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-loans">bus-loans</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
