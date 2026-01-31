# bus-pdf

Bus PDF renders deterministic, template-based PDF documents from structured input
data, enabling BusDK workspaces to produce archival-friendly artifacts such as
invoice PDFs without modifying any accounting datasets.

## How to run

Run `bus pdf` … and use `--help` for available subcommands and arguments.

## Data it reads and writes

It reads JSON input provided via `--data <file>` or `--data @-` (stdin) and
writes PDF files to the user-specified `--out` path. It does not read or write
any BusDK CSV datasets.

## Outputs and side effects

It creates or overwrites PDF files when rendering (only overwriting when
`--overwrite` is provided) and emits validation and rendering diagnostics to
stdout/stderr. It must not create journal entries, invoices, attachments
metadata, VAT data, bank data, or any other canonical bookkeeping records.

## Integrations

It is typically invoked by [`bus invoices`](./bus-invoices) to generate sales
invoice PDFs from invoice datasets, and it may also be used by
[`bus reports`](./bus-reports) or other modules that want to
render PDF documents from a prepared JSON render model.

## See also

Repository: ./modules/bus-pdf

---

<!-- busdk-docs-nav start -->
**Prev:** [bus-invoices](./bus-invoices) · **Index:** [BusDK Design Document](../index) · **Next:** [bus-journal](./bus-journal)
<!-- busdk-docs-nav end -->
