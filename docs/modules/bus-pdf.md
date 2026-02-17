---
title: bus-pdf — render PDFs from JSON render models
description: bus pdf renders deterministic PDFs from a JSON render model; template and content are chosen in the JSON so callers like bus-invoices can drive rendering with a single payload.
---

## `bus-pdf` — render PDFs from JSON render models

### Synopsis

`bus pdf --data <file> --out <path> [--overwrite] [-C <dir>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus pdf` renders deterministic PDFs from structured JSON input. It does not read BusDK datasets; it only accepts a render model via `--data <file>` or `--data @-` (stdin). Callers such as [bus-invoices](./bus-invoices) load invoice data from workspace CSVs and build a single JSON payload that matches the schema defined by this module. Output PDFs (e.g. invoices) can be registered as attachments. The template used for rendering is chosen inside the render model via a `template` field (template identifier or repository-relative path); there is no separate CLI flag for template selection.

### Render model

The JSON render model must include a top-level `template` field: either a template identifier (e.g. `"invoices/standard"`) or a repository-relative path to the template directory. The module uses this value to select the template for the run. For invoice PDFs, the payload must conform to the invoice render model schema (header, lines, totals/VAT as applicable); the full schema is defined in the [bus-pdf module SDD](../sdd/bus-pdf).

### Options

`--data <file>` (or `--data @-` for stdin) supplies the JSON render model. `--out <path>` is the output PDF path. `--overwrite` allows overwriting an existing file; if the output file already exists and `--overwrite` is not given, the command fails with a clear diagnostic. Global flags are defined in [Standard global flags](../cli/global-flags). For help, run `bus pdf --help`.

### Files

Reads a JSON render model from a file or stdin. Writes only the specified PDF output. Does not read or write workspace datasets.

### Exit status

`0` on success. Non-zero on invalid usage or rendering failure.

### Development state

**Value promise:** Render deterministic PDFs from JSON (e.g. invoice data) so [bus-invoices](./bus-invoices) can produce `bus invoices pdf` and other modules can emit documents from workspace data.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview) (step [Generate invoice PDF and register it as evidence](../workflow/generate-invoice-pdf-and-register-attachment)), [Sale invoicing (sending invoices to customers)](../workflow/sale-invoicing).

**Completeness:** 70% — render from file and stdin, list-templates, global flags, overwrite, chdir, repo-relative template path, and optional PDF/A verified by e2e and unit tests; user can complete the PDF render step.

**Use case readiness:** [Accounting workflow](../workflow/accounting-workflow-overview) (Generate invoice PDF and register it as evidence): 70% — render step verified; `bus invoices pdf` in [bus-invoices](./bus-invoices) not yet implemented. [Sale invoicing](../workflow/sale-invoicing): 70% — PDF generation step verified; end-to-end `bus invoices pdf` not yet in [bus-invoices](./bus-invoices).

**Current:** E2E `tests/e2e_bus_pdf.sh` proves help, version, no-args exit 2, list-templates, global flags (output, quiet, format, color, `--`, chdir), render from file and stdin (`--data @-`), overwrite, reject existing output without overwrite, `--pdfa` (PDF/A-1b), fi-invoice-a4 valid/invalid, repo-relative template path, and `-vv`. Unit tests: `cmd/bus-pdf/run_test.go` (list-templates, render plain/invoice, determinism, validation, overwrite, repo-relative, chdir, output, quiet, color, format, PDFA); `internal/render/render_test.go`, `internal/render/normalize_test.go` (determinism and PDF normalization); `internal/templates/templates_test.go`, `internal/templates/invoice_test.go` (template names and invoice validation); `internal/cli/flags_test.go` (flag parsing).

**Planned next:** None in PLAN.md; optional PDF/A (`--pdfa`) already implemented and verified by e2e and unit tests.

**Blockers:** None known.

**Depends on:** None.

**Used by:** [bus-invoices](./bus-invoices) (for `bus invoices pdf`).

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

