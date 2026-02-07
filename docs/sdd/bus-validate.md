## bus-validate

### Introduction and Overview

Bus Validate validates all workspace datasets against their schemas, verifies cross-table integrity and double-entry invariants, and produces actionable diagnostics for invalid workspaces.

### Requirements

FR-VAL-001 Workspace validation. The module MUST validate all datasets and schemas in the workspace and enforce cross-table invariants. Acceptance criteria: schema and invariant violations produce deterministic diagnostics and non-zero exit codes.

FR-VAL-002 CLI surface for validation. The module MUST expose a deterministic validation command usable in automation. Acceptance criteria: `bus validate` runs without modifying datasets.

NFR-VAL-001 Auditability. Validation diagnostics MUST reference datasets and stable identifiers for traceability. Acceptance criteria: diagnostics cite workspace-relative paths and identifiers.

### System Architecture

Bus Validate is a cross-module validator that reads all workspace datasets and schemas and reports violations. It does not modify data and is used as a prerequisite for close and filing workflows.

### Key Decisions

KD-VAL-001 Validation is a first-class CLI workflow. Validation is explicit and deterministic rather than implicit during unrelated operations.

### Component Design and Interfaces

Interface IF-VAL-001 (module CLI). The module is invoked as `bus validate` and follows BusDK CLI conventions for deterministic output and diagnostics.

Validation scope is fixed to the full workspace datasets and schemas, including cross-table invariants. The command does not support partial validation modes or dataset selection parameters because the purpose is to confirm workspace-wide integrity as a single deterministic step.

Validation results are diagnostics. The command supports a machine-readable diagnostics format by accepting `--format text` (default) or `--format tsv`, with the selected diagnostics written to standard error. The `tsv` format emits a stable column set of `dataset`, `record_id`, `field`, `rule`, and `message` so automation can filter and join diagnostics across revisions. Standard output remains reserved for command results and is empty on success, so automation should capture diagnostics via standard error redirection. The `--output` flag does not apply because `bus validate` does not emit a result set; when present it has no effect on diagnostics.

Usage example:

```bash
bus validate
```

### Data Design

The module reads all workspace datasets and schemas and does not write to the repository.

### Assumptions and Dependencies

Bus Validate depends on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Validation does not change datasets and should not expose sensitive data beyond necessary diagnostics. Output should remain limited to dataset references and identifiers.

### Observability and Logging

Validation results are emitted as diagnostics to standard error with deterministic references to dataset paths and identifiers. Standard output remains reserved for other command results and is empty on success.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Validation failures exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover schema and invariant checks, and command-level tests exercise `bus validate` against fixture workspaces with known errors.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Validation rule changes are handled by updating the module and documenting the new rules.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic validation.

### Glossary and Terminology

Validation diagnostics: deterministic messages that cite dataset paths and identifiers for errors.  
Invariant: a cross-table rule that must hold for repository data to be valid.

### See also

End user documentation: [bus-validate CLI reference](../modules/bus-validate)  
Repository: https://github.com/busdk/bus-validate

For shared validation architecture and CLI safety behavior, see [Shared validation layer](../architecture/shared-validation-layer) and [Validation and safety checks](../cli/validation-and-safety-checks).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-inventory">bus-inventory</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-validate module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-VALIDATE`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
