## bus-pdf

### Introduction and Overview

Bus PDF renders deterministic, template-based PDF documents from structured input data, enabling BusDK workspaces to produce archival-friendly artifacts without modifying accounting datasets.

### Requirements

FR-PDF-001 Deterministic rendering. The module MUST render PDFs deterministically from JSON input. Acceptance criteria: identical inputs yield byte-stable outputs when template and rendering settings are unchanged.

FR-PDF-002 Controlled file output. The module MUST write PDFs only to the specified output path and must not modify workspace datasets. Acceptance criteria: only the requested PDF file is created or overwritten when allowed.

NFR-PDF-001 Auditability. Rendered documents MUST remain readable for the full retention period. Acceptance criteria: output PDFs are deterministic and compatible with standard PDF readers.

### System Architecture

Bus PDF is a standalone rendering module that reads JSON input and writes a PDF file. It integrates with other modules by consuming prepared render models and emitting the resulting file for attachment registration.

### Key Decisions

KD-PDF-001 Rendering is external to domain datasets. PDF outputs are derived artifacts and do not alter canonical bookkeeping datasets.

### Component Design and Interfaces

Interface IF-PDF-001 (module CLI). The module is invoked as `bus pdf` and follows BusDK CLI conventions for deterministic output and diagnostics.

Documented parameters are `--data <file>` (or `--data @-` for stdin), `--out <path>`, and `--overwrite` to allow overwriting an existing file.
Template selection is explicit and part of the render model. Each render model references exactly one template by repository-relative path, and the renderer uses only that template for the run. Multiple templates are supported by storing multiple template directories in the repository data and selecting the desired one in the render model; the module does not auto-discover or switch templates based on content.

Usage example:

```bash
bus pdf --data invoice-render.json --out tmp/INV-1001.pdf --overwrite
```

### Data Design

The module reads JSON render models from a file or stdin and writes a PDF file to the specified output path. It does not read or write any BusDK datasets.

### Assumptions and Dependencies

Bus PDF depends on a deterministic render template and a valid JSON input model. Invalid input results in deterministic diagnostics.

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

Render model: the JSON input that describes the content to be rendered into a PDF.  
Derived artifact: a file output generated from canonical datasets without modifying them.

### See also

End user documentation: [bus-pdf CLI reference](../modules/bus-pdf)  
Repository: https://github.com/busdk/bus-pdf

For PDF storage conventions and layout expectations, see [Invoice PDF storage](../layout/invoice-pdf-storage) and [Layout principles](../layout/layout-principles).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-invoices">bus-invoices</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-journal">bus-journal</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-pdf module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-PDF`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
