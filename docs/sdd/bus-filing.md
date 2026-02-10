## bus-filing

### Introduction and Overview

Bus Filing produces deterministic filing bundles from validated workspace data, assembles manifests and checksums, and delegates target-specific formats to filing target modules.

### Requirements

FR-FIL-001 Filing bundle generation. The module MUST assemble filing bundles from validated, closed-period data. Acceptance criteria: `bus filing` produces deterministic bundle directories or archives.

FR-FIL-002 Target delegation. The module MUST delegate target-specific formats to `bus filing prh` and `bus filing vero`. Acceptance criteria: target subcommands are invoked through `bus filing` and share a consistent bundle structure.

NFR-FIL-001 Auditability. Filing bundles MUST preserve an auditable trail from reports back to vouchers and evidence. Acceptance criteria: bundles include required datasets, schemas, and metadata and remain internally consistent.

### System Architecture

Bus Filing orchestrates export bundle creation by reading validated datasets and reports and invoking target-specific modules. It depends on closed periods and validated data.

### Key Decisions

KD-FIL-001 Filing bundles are deterministic exports. Export bundles include manifests and hashes so they remain verifiable over time.

### Component Design and Interfaces

Interface IF-FIL-001 (module CLI). The module exposes `bus filing` with subcommands `prh`, `vero`, and `tax-audit-pack` and follows BusDK CLI conventions for deterministic output and diagnostics.

Module-specific parameters for `prh`, `vero`, and `tax-audit-pack` are not defined in the current design spec and must be provided by the module help output for a pinned version.

Usage example:

```bash
bus filing tax-audit-pack
```

### Data Design

The module reads validated datasets and reports and writes export bundle directories or archives containing dataset snapshots, schemas, and manifests.

### Assumptions and Dependencies

Bus Filing depends on `bus validate` and `bus period` outputs and on target-specific modules for PRH and Vero formats. If prerequisites are missing, the module fails with deterministic diagnostics.

### Security Considerations

Filing bundles may contain sensitive financial data and must be protected by repository access controls. Export outputs must remain tamper-evident through manifests and hashes.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to bundle paths and missing prerequisites.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Missing prerequisites or invalid bundles exit non-zero without partial output.

### Testing Strategy

Unit tests cover bundle assembly logic, and command-level tests exercise `tax-audit-pack` and target delegation against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Bundle structure changes are handled by updating the module and documenting the new bundle format.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly exports.

### Open Questions

OQ-FIL-001 Bundle parameterization. Define the complete parameter set for `tax-audit-pack` and target-specific exports so the command surface is deterministic.

### Glossary and Terminology

Filing bundle: an export directory or archive containing datasets, schemas, and manifests for authority filing.  
Tax-audit pack: a filing bundle optimized for audit review.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-pdf">bus-pdf</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-filing-prh">bus-filing-prh</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Master data: Master data (business objects)](../master-data/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: VAT treatment](../master-data/vat-treatment/index)
- [End user documentation: bus-filing CLI reference](../modules/bus-filing)
- [Repository](https://github.com/busdk/bus-filing)
- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Year-end close (closing entries)](../workflow/year-end-close)

### Document control

Title: bus-filing module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-FILING`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
