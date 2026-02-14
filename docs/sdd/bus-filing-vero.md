---
title: bus-filing-vero — Vero export bundles from validated data (SDD)
description: Bus Filing Vero converts validated workspace data into Vero export bundles, applying Vero-specific packaging rules and metadata while keeping bundle…
---

## bus-filing-vero — Vero export bundles from validated data

### Introduction and Overview

Bus Filing Vero converts validated workspace data into Vero export bundles, applying Vero-specific packaging rules and metadata while keeping bundle structure deterministic and auditable.

### Requirements

FR-VERO-001 Vero bundle generation. The module MUST produce Vero-ready bundle directories or archives from validated data and VAT outputs. Acceptance criteria: outputs include manifests and hashes and validate internal consistency.

FR-VERO-002 VAT traceability. The module MUST retain references to underlying postings, vouchers, and VAT summaries. Acceptance criteria: bundles include VAT summaries and reference identifiers back to source datasets.

NFR-VERO-001 Deterministic export. Bundle contents MUST be deterministic so exports remain verifiable. Acceptance criteria: manifests and hashes are stable for identical inputs.

### System Architecture

Bus Filing Vero is invoked through `bus filing vero` and consumes validated datasets, VAT outputs, and reports produced by other modules. It produces a Vero-specific export bundle.

### Key Decisions

KD-VERO-001 Vero export is a target-specific specialization. The module focuses only on Vero packaging and relies on shared validation and reporting outputs.

### Component Design and Interfaces

Interface IF-VERO-001 (module CLI). The module is invoked as `bus filing vero` and follows BusDK CLI conventions for deterministic output and diagnostics.

Module-specific parameters are not defined in the current design spec and must be provided by the module help output for a pinned version.

Usage example:

```bash
bus filing vero
```

### Data Design

The module reads validated datasets, VAT outputs, and report outputs and writes Vero-specific bundle directories or archives with manifests and hashes.

### Assumptions and Dependencies

Bus Filing Vero depends on `bus filing` orchestration, `bus period` closed data, and outputs from `bus vat` and `bus reports`. Missing prerequisites result in deterministic diagnostics.

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

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly exports.

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
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
