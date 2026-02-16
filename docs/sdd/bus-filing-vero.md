---
title: bus-filing-vero — Vero export bundles from validated data (SDD)
description: Bus Filing Vero converts validated workspace data into Vero export bundles from the canonical VAT and report layout, using path accessors and no extra preprocessing.
---

## bus-filing-vero — Vero export bundles from validated data

### Introduction and Overview

Bus Filing Vero converts validated workspace data into Vero export bundles, applying Vero-specific packaging rules and metadata while keeping bundle structure deterministic and auditable.

### Requirements

FR-VERO-001 Vero bundle generation. The module MUST produce Vero-ready bundle directories or archives from validated data and VAT outputs. Acceptance criteria: outputs include manifests and hashes and validate internal consistency.

FR-VERO-002 VAT traceability. The module MUST retain references to underlying postings, vouchers, and VAT summaries. Acceptance criteria: bundles include VAT summaries and reference identifiers back to source datasets.

NFR-VERO-001 Deterministic export. Bundle contents MUST be deterministic so exports remain verifiable. Acceptance criteria: manifests and hashes are stable for identical inputs.

NFR-VERO-002 Path resolution for upstream data. The module MUST resolve paths to VAT outputs and report outputs via the owning modules’ Go library path accessors ([bus-vat](../sdd/bus-vat) IF-VAT-002 and the equivalent for reports). It MUST NOT hardcode directory names (e.g. `reports/`, `vat/`) or file names that differ from what `bus vat init` and the reports module produce. Acceptance criteria: after `bus vat init` (and report generation where required), export runs without requiring manual creation of directories or preprocessing; path resolution uses library APIs only.

### System Architecture

Bus Filing Vero is invoked through `bus filing vero` and consumes validated datasets, VAT outputs, and reports produced by other modules. It produces a Vero-specific export bundle.

### Key Decisions

KD-VERO-001 Vero export is a target-specific specialization. The module focuses only on Vero packaging and relies on shared validation and reporting outputs.

KD-VERO-002 Consume canonical layout only. Bus-filing-vero consumes VAT and report data in the layout produced by [bus vat](../sdd/bus-vat) and the reports module. It does not define or require a separate directory structure (e.g. a dedicated `vat/` or `reports/` tree) that those modules do not produce. Required pre-export layout is therefore: workspace initialized with `bus vat init` (and report outputs generated when the bundle requires them), with no extra preprocessing or manual directory creation.

### Component Design and Interfaces

Interface IF-VERO-001 (module CLI). The module is invoked as `bus filing vero` and follows BusDK CLI conventions for deterministic output and diagnostics.

Module-specific parameters are not defined in the current design spec and must be provided by the module help output for a pinned version.

Usage example:

```bash
bus filing vero
```

### Data Design

The module reads validated datasets, VAT outputs, and report outputs and writes Vero-specific bundle directories or archives with manifests and hashes.

**Required pre-export layout.** Inputs MUST be in the canonical layout produced by upstream modules. VAT datasets and their beside-the-table schemas live at the workspace root as defined by [bus-vat](../sdd/bus-vat) (see [VAT area](../layout/vat-area)); the module does not expect VAT data under a `vat/` subdirectory. Report outputs live at the location defined by the reports module. Paths to VAT and report files MUST be resolved via those modules’ Go library path accessors only. No preprocessing or manual creation of `reports/` or `vat/` directories is required: a workspace that has run `bus config init`, `bus invoices init`, and `bus vat init` (and report generation when the bundle requires reports) must be sufficient for export to run, subject to missing-data diagnostics that refer to the actual paths provided by the accessors.

### Assumptions and Dependencies

Bus Filing Vero depends on `bus filing` orchestration, `bus period` closed data, and outputs from [bus vat](../sdd/bus-vat) and the reports module. VAT and report file locations and schema naming are defined by the owning modules; bus-filing-vero does not define or require a different layout (KD-VERO-002, NFR-VERO-002). Missing prerequisites result in deterministic diagnostics that reference the paths resolved via the owning modules’ APIs. Impact if false: requiring a layout that upstream modules do not produce blocks end-to-end export after standard init and report/VAT generation.

### Security Considerations

Vero bundles contain sensitive financial data and must be protected by repository access controls. Manifests and hashes must remain intact for verifiability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to bundle paths and missing prerequisites.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Missing prerequisites or invalid bundles exit non-zero without partial output.

### Testing Strategy

Unit tests cover bundle assembly rules, and command-level tests exercise Vero exports against fixture workspaces with known outputs.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Bundle structure changes are handled by updating the module and documenting the new bundle format.

### Risks

**Implementation alignment with path contract (2026-02-16).** The current implementation can fail with “required directory missing: reports” or “missing schema for vat-rates.csv: vat-rates.schema.json” when the workspace has been initialized only with `bus config init`, `bus invoices init`, and `bus vat init`. That indicates the implementation does not yet resolve VAT (and possibly report) paths via the owning modules’ path accessors and may expect directory or schema layouts those modules do not produce. Until the implementation aligns with NFR-VERO-002 and KD-VERO-002, export remains blocked for the standard init-and-export flow; the design is the target state and implementation changes are required.

### Open Questions

OQ-VERO-001 Vero export parameters. Define the complete parameter set for `bus filing vero` so the command surface is deterministic.

### Glossary and Terminology

Vero bundle: an export package formatted for Finnish Vero filing requirements.  
Manifest: a deterministic listing and checksum set for bundle contents.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing-prh">bus-filing-prh</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../integration/index">Integration and future interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-vat module SDD](./bus-vat) (path accessors, canonical VAT layout)
- [VAT area (layout)](../layout/vat-area)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [Master data: Sales invoices](../master-data/sales-invoices/index)
- [Master data: Purchase invoices](../master-data/purchase-invoices/index)
- [End user documentation: bus-filing-vero CLI reference](../modules/bus-filing-vero)
- [Repository](https://github.com/busdk/bus-filing-vero)
- [VAT reporting and payment](../workflow/vat-reporting-and-payment)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)

### Document control

Title: bus-filing-vero module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-FILING-VERO`  
Version: 2026-02-17  
Status: Draft  
Last updated: 2026-02-17  
Owner: BusDK development team  
