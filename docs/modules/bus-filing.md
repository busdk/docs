## bus-filing

Bus Filing produces deterministic filing bundles from workspace data, assembles
manifests, checksums, and version metadata, and delegates target-specific
formats to filing target modules.

### How to run

Run `bus filing` … and use `--help` for
available subcommands and arguments.

### Subcommands

- `prh`: Produce PRH-ready filing bundles using `bus filing prh`.
- `vero`: Produce Vero-ready filing bundles using `bus filing vero`.
- `tax-audit-pack`: Produce a tax-audit export bundle for a selected period.

### Data it reads and writes

It reads validated datasets and reports from the workspace and writes filing
bundle directories or archives.

### Outputs and side effects

It writes export bundles suitable for authority submission and emits
diagnostics for missing prerequisites or invalid bundles.

### Finnish compliance responsibilities

Bus Filing MUST produce tax-audit packs that include the journal/daybook, general ledger, subledgers, vouchers, attachments metadata, VAT summaries, chart of accounts, schemas, and the methods description, and it MUST ensure the bundle is internally consistent so totals reconcile across datasets. It MUST preserve a demonstrable audit trail within the export so postings can be traced back to vouchers and evidence.

### Integrations

It requires validated, closed periods from
[`bus validate`](./bus-validate) and
[`bus period`](./bus-period), and uses
[`bus filing prh`](./bus-filing-prh) and
[`bus filing vero`](./bus-filing-vero) for target-specific
exports.

### See also

Repository: https://github.com/busdk/bus-filing

For authority reporting context and close prerequisites, see [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit) and [Year-end close (closing entries)](../workflow/year-end-close).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reports">bus-reports</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-prh">bus-filing-prh</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
