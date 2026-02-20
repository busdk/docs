---
title: bus-pdf — render PDFs from JSON render models
description: bus pdf renders deterministic PDFs from a JSON render model; template and content are chosen in the JSON so callers like bus-invoices can drive rendering with a single payload.
---

## `bus-pdf` — render PDFs from JSON render models

### Synopsis

`bus pdf --data <file> --out <path> [--overwrite] [-C <dir>] [--color <mode>] [-v] [-q] [-h] [-V]`

### Description

Command names follow [CLI command naming](../cli/command-naming).

`bus pdf` renders deterministic PDFs from structured JSON input.
It does not read BusDK datasets directly.
It accepts a render model via `--data <file>` or `--data @-` (stdin).

Callers such as [bus-invoices](./bus-invoices) load workspace data and pass a single JSON payload to this module.
Output PDFs can then be registered as attachments.

Template selection is inside the render model via the `template` field (template id or repository-relative template path).
There is no separate CLI template flag.
Built-in templates are **fi-invoice-a4** and **plain-a4**.

For Finnish regulated TASE/tuloslaskelma PDFs, use [bus-reports](./bus-reports) with `--format pdf` (see [Regulated report PDFs (TASE and tuloslaskelma)](../implementation/regulated-report-pdfs)).

### Render model

The JSON render model must include top-level `template`.
The value can be a template identifier or repository-relative template path.
The module uses this value to select the template for rendering.

For invoice PDFs, payload must conform to invoice render-model schema (header, lines, totals/VAT as applicable).
Full schema details are in [Module SDD: bus-pdf](../sdd/bus-pdf).

### Options

`--data <file>` (or `--data @-`) supplies the JSON render model.
`--out <path>` sets output PDF path.
`--overwrite` allows replacing an existing file.

If output file exists and `--overwrite` is not set, command fails with a clear diagnostic.

Global flags are defined in [Standard global flags](../cli/global-flags). For help, run `bus pdf --help`.

### Files

Reads a JSON render model from a file or stdin. Writes only the specified PDF output. Does not read or write workspace datasets.

### Examples

```bash
bus pdf --data ./render/invoice-1001.json --out ./out/invoice-1001.pdf --overwrite
cat ./render/invoice-1002.json | bus pdf --data @- --out ./out/invoice-1002.pdf --overwrite
```

### Exit status

`0` on success. Non-zero on invalid usage or rendering failure.


### Using from `.bus` files

Inside a `.bus` file, write this module target without the `bus` prefix.

```bus
# same as: bus pdf --data ./render/invoice-2001.json --out ./out/invoice-2001.pdf --overwrite
pdf --data ./render/invoice-2001.json --out ./out/invoice-2001.pdf --overwrite

# same as: bus pdf --data ./render/invoice-2002.json --out ./out/invoice-2002.pdf
pdf --data ./render/invoice-2002.json --out ./out/invoice-2002.pdf
```


### Development state

**Value promise:** Render deterministic PDFs from JSON (e.g. invoice data) so [bus-invoices](./bus-invoices) can produce `bus invoices pdf` and other modules can emit documents from workspace data.

**Use cases:** [Accounting workflow](../workflow/accounting-workflow-overview) (step [Generate invoice PDF and register attachment](../workflow/generate-invoice-pdf-and-register-attachment)), [Sale invoicing](../workflow/sale-invoicing).

**Completeness:** 70% — Render step test-verified; user can produce PDF from file or stdin; `bus invoices pdf` not yet in [bus-invoices](./bus-invoices).

**Use case readiness:** Generate invoice PDF and register attachment: 70% — render verified; `bus invoices pdf` not in [bus-invoices](./bus-invoices). Sale invoicing (sending invoices to customers): 70% — PDF step verified; `bus invoices pdf` not in [bus-invoices](./bus-invoices).

**Current:** Rendering from file/stdin, template resolution, overwrite behavior, determinism, and global-flag handling are test-verified.
Detailed test matrix and implementation notes are maintained in [Module SDD: bus-pdf](../sdd/bus-pdf).

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
