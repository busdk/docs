## bus-pdf

Bus PDF renders deterministic, template-based PDF documents from structured input
data, enabling BusDK workspaces to produce archival-friendly artifacts such as
invoice PDFs without modifying any accounting datasets.

### How to run

Run `bus pdf` … and use `--help` for available subcommands and arguments.

### Data it reads and writes

It reads JSON input provided via `--data <file>` or `--data @-` (stdin) and
writes PDF files to the user-specified `--out` path. It does not read or write
any BusDK CSV datasets.

### Outputs and side effects

It creates or overwrites PDF files when rendering (only overwriting when
`--overwrite` is provided) and emits validation and rendering diagnostics to
stdout/stderr. It must not create journal entries, invoices, attachments
metadata, VAT data, bank data, or any other canonical bookkeeping records.

### Integrations

It is typically invoked by [`bus invoices`](./bus-invoices) to generate sales
invoice PDFs from invoice datasets, and it may also be used by
[`bus reports`](./bus-reports) or other modules that want to
render PDF documents from a prepared JSON render model.

### See also

Repository: https://github.com/busdk/bus-pdf

For PDF storage conventions and layout expectations, see [Invoice PDF storage](../spec/layout/invoice-pdf-storage) and [Layout principles](../spec/layout/layout-principles).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-journal">bus-journal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
