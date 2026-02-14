---
title: bus-filing-prh — PRH export bundles from validated data (SDD)
description: Bus Filing PRH converts validated workspace data into PRH export bundles, applying PRH-specific packaging rules and metadata while keeping bundle structure…
---

## bus-filing-prh — PRH export bundles from validated data

### Introduction and Overview

Bus Filing PRH converts validated workspace data into PRH export bundles, applying PRH-specific packaging rules and metadata while keeping bundle structure deterministic and auditable.

### Requirements

FR-PRH-001 PRH bundle generation. The module MUST produce PRH-ready bundle directories or archives from validated, closed-period data. Acceptance criteria: outputs include manifests and hashes and validate internal consistency.

FR-PRH-002 Required content inclusion. The module MUST include required financial statements and supporting datasets. Acceptance criteria: bundles include journal, reports, voucher references, and attachments metadata as required for PRH.

NFR-PRH-001 Deterministic export. Bundle contents MUST be deterministic so exports remain verifiable. Acceptance criteria: manifests and hashes are stable for identical inputs.

### System Architecture

Bus Filing PRH is invoked through `bus filing prh` and consumes validated datasets and reports produced by other modules. It produces a PRH-specific export bundle.

### Key Decisions

KD-PRH-001 PRH export is a target-specific specialization. The module focuses only on PRH packaging and relies on shared validation and reporting outputs.

### Component Design and Interfaces

Interface IF-PRH-001 (module CLI). The module is invoked as `bus filing prh` and follows BusDK CLI conventions for deterministic output and diagnostics.

Module-specific parameters are not defined in the current design spec and must be provided by the module help output for a pinned version.

Usage example:

```bash
bus filing prh
```

### Data Design

The module reads validated datasets and report outputs and writes PRH-specific bundle directories or archives with manifests and hashes.

### Assumptions and Dependencies

Bus Filing PRH depends on `bus filing` orchestration, `bus period` closed data, and outputs from `bus reports` and `bus vat`. Missing prerequisites result in deterministic diagnostics.

### Security Considerations

PRH bundles contain sensitive financial data and must be protected by repository access controls. Manifests and hashes must remain intact for verifiability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to bundle paths and missing prerequisites.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Missing prerequisites or invalid bundles exit non-zero without partial output.

### Testing Strategy

Unit tests cover bundle assembly rules, and command-level tests exercise PRH exports against fixture workspaces with known outputs.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Bundle structure changes are handled by updating the module and documenting the new bundle format.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly exports.

### Open Questions

OQ-PRH-001 PRH export parameters. Define the complete parameter set for `bus filing prh` so the command surface is deterministic.

### Glossary and Terminology

PRH bundle: an export package formatted for Finnish PRH filing requirements.  
Manifest: a deterministic listing and checksum set for bundle contents.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-filing">bus-filing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-vero">bus-filing-vero</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [End user documentation: bus-filing-prh CLI reference](../modules/bus-filing-prh)
- [Repository](https://github.com/busdk/bus-filing-prh)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Year-end close (closing entries)](../workflow/year-end-close)

### Document control

Title: bus-filing-prh module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-FILING-PRH`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
