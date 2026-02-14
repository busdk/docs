---
title: bus-pdf — render PDFs from JSON render models
description: bus pdf renders deterministic PDFs from structured JSON input.
---

## `bus-pdf` — render PDFs from JSON render models

### Synopsis

`bus pdf --data <file> --out <path> [--overwrite] [-C <dir>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus pdf` renders deterministic PDFs from structured JSON input. It does not read or write BusDK datasets; it is used to produce archival PDFs (e.g. invoices) that can then be registered as attachments. Template selection is specified in the render model.

### Options

`--data <file>` (or `--data @-` for stdin) supplies the JSON render model. `--out <path>` is the output PDF path. `--overwrite` allows overwriting an existing file. Global flags are defined in [Standard global flags](../cli/global-flags). For help, run `bus pdf --help`.

### Files

Reads a JSON render model from a file or stdin. Writes only the specified PDF output. Does not modify workspace datasets.

### Exit status

`0` on success. Non-zero on invalid usage or rendering failure.

### Development state

**Value promise:** Render PDFs from JSON (e.g. invoice data) so [bus-invoices](./bus-invoices) can produce `bus invoices pdf` and other modules can emit documents from workspace data.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview) (invoice PDF generation).

**Completeness:** 60% (Stable) — render from file implemented and covered by unit tests; stdin (`--data @-`) not yet covered by command-level test.

**Use case readiness:** Accounting workflow: 60% — render from file verified; command-level test for `render --data @-` would complete the invoice-pdf step.

**Current:** Unit tests in `cmd/bus-pdf/run_test.go`, `internal/render/render_test.go`, and `internal/templates/` prove run, render, and template behavior. No e2e; command-level test for `render --data @-` is in PLAN.

**Planned next:** Command-level test for `render --data @-`.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-invoices](./bus-invoices) uses this for `bus invoices pdf`.

See [Development status](../implementation/development-status).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-vat">bus-vat</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing">bus-filing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [Module SDD: bus-pdf](../sdd/bus-pdf)
- [Layout: Invoice PDF storage](../layout/invoice-pdf-storage)

