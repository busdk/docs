---
title: bus-pdf — deterministic PDF rendering from structured data (SDD)
description: Bus PDF renders deterministic, template-based PDFs from a JSON render model; defines the invoice render model schema and template selection so bus-invoices can drive rendering via a single payload.
---

## bus-pdf — deterministic PDF rendering from structured data

### Introduction and Overview

Bus PDF renders deterministic, template-based PDF documents from structured JSON input. It does not read BusDK datasets; it only accepts a render model via `--data <file>` or `--data @-` (stdin). Callers such as [bus-invoices](../modules/bus-invoices) load invoice data from workspace CSVs and build a single JSON payload that matches the schema defined by this module. The module enables BusDK workspaces to produce archival-friendly PDF artifacts without modifying accounting datasets.

Scope: defining and documenting the render model schema (including the invoice template schema), implementing template selection from the render model, and providing a stable invoice template that consumes that schema. Out of scope: reading invoice or other BusDK datasets directly; that remains the responsibility of the calling module.

### Requirements

FR-PDF-001 Deterministic rendering. The module MUST render PDFs deterministically from JSON input. Acceptance criteria: identical inputs yield byte-stable outputs when template and rendering settings are unchanged.

FR-PDF-002 Controlled file output. The module MUST write PDFs only to the specified output path and must not modify workspace datasets. Acceptance criteria: only the requested PDF file is created or overwritten when explicitly requested via `--overwrite`.

FR-PDF-003 Invoice render model schema. The module MUST define and document a stable JSON schema for the invoice template (the invoice render model) so that callers (e.g. bus-invoices) can produce the exact payload the template expects. Acceptance criteria: the schema is documented in this SDD (see Data Design) and is stable across minor releases; validation of the render model against this schema is implemented or explicitly specified.

FR-PDF-004 Template selection from render model. The module MUST read the template identifier or repository-relative path from the render model and use that template for the run. Acceptance criteria: no separate CLI flag is required to select the template; the JSON payload drives template selection so that callers can pass a single payload (e.g. `bus pdf --data @- --out <path>`).

FR-PDF-005 Invoice template. The module MUST provide a single, stable invoice template that consumes the documented invoice render model schema, renders deterministically (FR-PDF-001), and writes only to the path given by `--out` (FR-PDF-002). Acceptance criteria: the invoice template exists, is selected via the render model (e.g. `"template": "invoices/standard"` or a repository-relative path), and matches the documented invoice render model schema.

NFR-PDF-001 Auditability. Rendered documents MUST remain readable for the full retention period. Acceptance criteria: output PDFs are deterministic and compatible with standard PDF readers.

### System Architecture

Bus PDF is a standalone rendering module that reads a JSON render model (file or stdin) and writes a PDF file. Template selection is specified in the render model; the module resolves the template by identifier or repository-relative path and renders using only that template for the run. It integrates with other modules by consuming prepared render models and emitting the resulting file (e.g. for [bus-attachments](../modules/bus-attachments) registration). Callers such as bus-invoices are responsible for loading workspace data and building the render model JSON that conforms to the schema defined here.

### Key Decisions

KD-PDF-001 Rendering is external to domain datasets. PDF outputs are derived artifacts and do not alter canonical bookkeeping datasets.

KD-PDF-002 Template selection is specified in the render model. The template (e.g. invoice) is chosen inside the JSON via a `template` field (identifier or repository-relative path), not by a CLI flag. This allows callers like bus-invoices to drive the full render in one invocation with a single payload.

### Component Design and Interfaces

Interface IF-PDF-001 (module CLI). The module is invoked as `bus pdf` and follows BusDK CLI conventions for deterministic output and diagnostics.

Documented parameters are `--data <file>` (or `--data @-` for stdin), `--out <path>`, and `--overwrite`. The module MUST read the template identifier or repository-relative path from the render model (FR-PDF-004) and use that template for the run. If the output file already exists, it MUST be overwritten only when `--overwrite` is explicitly given; otherwise the command MUST fail with a clear diagnostic. This contract is stable so that bus-invoices can invoke `bus pdf --data @- --out <path> [--overwrite]` and forward the user’s overwrite intent without any additional bus-pdf behavior.

The invoice template (FR-PDF-005) consumes the invoice render model schema defined in Data Design. It MUST render that schema deterministically and write only to the path specified by `--out`. Multiple templates (e.g. for other document types) are supported by storing template directories in the repository data and selecting the desired one in the render model; the module does not auto-discover or switch templates based on content.

Usage examples:

```bash
bus pdf --data invoice-render.json --out tmp/INV-1001.pdf --overwrite
```

```bash
# Caller (e.g. bus-invoices) pipes the invoice render model JSON to stdin.
bus pdf --data @- --out tmp/INV-1001.pdf
```

### Data Design

The module reads JSON render models from a file or stdin and writes a PDF file to the specified output path. It does not read or write any BusDK datasets.

Every render model MUST include a top-level `template` field: either a template identifier (e.g. `"invoices/standard"`) or a repository-relative path to the template directory. The module uses this value to select the template for the run (FR-PDF-004).

Invoice render model schema (for the invoice template). The following shape is the stable contract that the invoice template expects and that bus-invoices (or any caller) MUST emit when producing an invoice PDF.

- **template** (required): Template identifier or repository-relative path (e.g. `"invoices/standard"`).
- **header**: Invoice header fields. At least: `invoice_id`, `number`, `issue_date`, `due_date`, `party_name`, `currency`, `status`. Names and types are defined by the module’s published schema; optional fields may be added in a backward-compatible way.
- **lines**: Array of line items. Each item includes at least: `description`, `quantity`, `unit_price`, and line amount (e.g. `amount` or `line_total`). Exact property names are part of the published schema.
- **totals / VAT**: When the template uses them: e.g. `subtotal`, `vat`, `total`. Omitted if the template does not render VAT or totals from the model.

The module MUST document this schema in full (e.g. JSON Schema or equivalent) so that bus-invoices can produce conforming JSON without ambiguity. Validation of incoming render models against this schema is required (FR-PDF-003) so that invalid payloads fail with deterministic diagnostics before any render.

### Integration with bus-invoices

[bus-invoices](../modules/bus-invoices) will implement `bus invoices pdf <invoice-id> --out <path> [--overwrite]` by loading the invoice header and lines from the workspace CSVs, building the invoice render model JSON that matches the schema defined above, and invoking bus-pdf (e.g. `bus pdf --data @- --out <path> [--overwrite]`). The caller may optionally register the resulting PDF via bus-attachments. No new overwrite or CLI behavior is required in bus-pdf; the existing `--data`, `--out`, and `--overwrite` contract (and stdin via `--data @-`) remains the interface that bus-invoices will use.

### Assumptions and Dependencies

Bus PDF depends on a deterministic render template and a valid JSON input model. Invalid input results in deterministic diagnostics. Callers are responsible for producing render models that conform to the documented schema for the chosen template.

### Security Considerations

PDF outputs may contain sensitive data and should be protected by repository access controls. Rendering must not read or write unintended files.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to the input model and output path.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Rendering failures exit non-zero without partial output.

### Testing Strategy

Unit tests cover JSON model validation and rendering determinism, and command-level tests exercise input and output behavior for `--data` and `--out`.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on standard filesystem access.

### Migration/Rollout

Not Applicable. Template changes are handled by updating the render template and documenting the new output expectations.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic render outputs.

### Glossary and Terminology

**Render model:** The JSON input that describes the content to be rendered into a PDF. It includes a `template` field (identifier or repository-relative path) and template-specific payload (e.g. header, lines, totals for the invoice template).

**Invoice render model:** The JSON shape consumed by the invoice template, as defined by the invoice render model schema in Data Design. Callers such as bus-invoices build this payload from workspace invoice data and pass it to bus-pdf via `--data`.

**Derived artifact:** A file output generated from canonical datasets without modifying them.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-vat">bus-vat</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing">bus-filing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-invoices SDD](bus-invoices)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [End user documentation: bus-pdf CLI reference](../modules/bus-pdf)
- [Repository](https://github.com/busdk/bus-pdf)
- [Invoice PDF storage](../layout/invoice-pdf-storage)
- [Layout principles](../layout/layout-principles)

### Document control

Title: bus-pdf module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-PDF`  
Version: 2026-02-17  
Status: Draft  
Last updated: 2026-02-17  
Owner: BusDK development team  
