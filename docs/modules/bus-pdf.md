---
title: bus-pdf — render PDFs from JSON render models
description: bus pdf renders deterministic PDFs from a JSON render model; template and content are chosen in the JSON so callers like bus-invoices can drive rendering with a single payload.
---

## `bus-pdf` — render PDFs from JSON render models

### Synopsis

`bus pdf --data <file> --out <path> [--overwrite] [-C <dir>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus pdf` renders deterministic PDFs from structured JSON input. It does not read BusDK datasets; it only accepts a render model via `--data <file>` or `--data @-` (stdin). Callers such as [bus-invoices](./bus-invoices) load invoice data from workspace CSVs and build a single JSON payload that matches the schema defined by this module. Output PDFs (e.g. invoices) can be registered as attachments. The template used for rendering is chosen inside the render model via a `template` field (template identifier or repository-relative path); there is no separate CLI flag for template selection. Built-in templates are **fi-invoice-a4** and **plain-a4** only. TASE and tuloslaskelma (balance sheet and income statement) PDFs for Finnish regulated reporting are produced by [bus-reports](./bus-reports) with `--format pdf` (see [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)).

### Render model

The JSON render model must include a top-level `template` field: either a template identifier (e.g. `"invoices/standard"`) or a repository-relative path to the template directory. The module uses this value to select the template for the run. For invoice PDFs, the payload must conform to the invoice render model schema (header, lines, totals/VAT as applicable); the full schema is defined in the [bus-pdf module SDD](../sdd/bus-pdf).

### Options

`--data <file>` (or `--data @-` for stdin) supplies the JSON render model. `--out <path>` is the output PDF path. `--overwrite` allows overwriting an existing file; if the output file already exists and `--overwrite` is not given, the command fails with a clear diagnostic. Global flags are defined in [Standard global flags](../cli/global-flags). For help, run `bus pdf --help`.

### Files

Reads a JSON render model from a file or stdin. Writes only the specified PDF output. Does not read or write workspace datasets.

### Examples

```bash
bus pdf --data ./render/invoice-1001.json --out ./out/invoice-1001.pdf --overwrite
```

### Exit status

`0` on success. Non-zero on invalid usage or rendering failure.

### Development state

**Value promise:** Render deterministic PDFs from JSON (e.g. invoice data) so [bus-invoices](./bus-invoices) can produce `bus invoices pdf` and other modules can emit documents from workspace data.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview) (step [Generate invoice PDF and register attachment](../workflow/generate-invoice-pdf-and-register-attachment)), [Sale invoicing](../workflow/sale-invoicing).

**Completeness:** 70% — Render step test-verified; user can produce PDF from file or stdin; `bus invoices pdf` not yet in [bus-invoices](./bus-invoices).

**Use case readiness:** Generate invoice PDF and register attachment: 70% — render verified; `bus invoices pdf` not in [bus-invoices](./bus-invoices). Sale invoicing (sending invoices to customers): 70% — PDF step verified; `bus invoices pdf` not in [bus-invoices](./bus-invoices).

**Current:** E2E `tests/e2e_bus_pdf.sh` verifies help, version, no-args exit 2, list-templates, global flags (output, quiet, format, color, `--`, chdir), render from file and stdin, default render, overwrite and reject without overwrite, `--pdfa`, fi-invoice-a4 valid/invalid payload, repo-relative template, determinism, and `-vv`. Unit tests `cmd/bus-pdf/run_test.go`, `internal/cli/flags_test.go`, `internal/render/render_test.go`, `internal/render/normalize_test.go`, `internal/templates/templates_test.go`, and `internal/templates/invoice_test.go` cover run behavior, flag parsing, render path, PDF normalization, template resolution, and invoice schema validation.

**Planned next:** None in PLAN.md; all documented requirements satisfied by current implementation.

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
- [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)

