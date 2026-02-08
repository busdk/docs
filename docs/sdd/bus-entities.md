## bus-entities

### Introduction and Overview

Bus Entities maintains counterparty reference datasets as schema-validated repository data, normalizes identity details, and provides stable entity identifiers for linking across modules.

### Requirements

FR-ENT-001 Entity registry. The module MUST store entity reference data with stable identifiers and schema validation. Acceptance criteria: entity rows validate against schemas and expose stable identifiers for use in other datasets.

FR-ENT-002 CLI surface for reference data. The module MUST provide commands to initialize, list, and add entities. Acceptance criteria: `init`, `list`, and `add` are available under `bus entities`.

NFR-ENT-001 Auditability. Entity records MUST remain stable across the retention period when referenced by vouchers, invoices, or bank data. Acceptance criteria: identifiers are stable and corrections are append-only.

### System Architecture

Bus Entities owns the entities/reference datasets and provides stable identifiers to other modules. It integrates with invoices, bank imports, reconciliation, VAT, and attachments through shared identifier references.

### Key Decisions

KD-ENT-001 Entity data is a shared reference dataset. Counterparty identifiers are stored as repository data and reused across modules.

### Component Design and Interfaces

Interface IF-ENT-001 (module CLI). The module exposes `bus entities` with subcommands `init`, `list`, and `add` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `add` command accepts entity identity parameters. Documented parameters are `--id <entity-id>` and `--name <display-name>`, with no positional arguments. The `list` command accepts no module-specific filters and returns the full entity registry in stable identifier order.

Usage examples:

```bash
bus entities init
bus entities list
```

```bash
bus entities add --id ENT-ACME --name "Acme Corp"
```

### Data Design

The module reads and writes entity datasets in the entities/reference area, with JSON Table Schemas stored beside each dataset.

### Assumptions and Dependencies

Bus Entities depends on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Entity reference data may include sensitive personal or business details and should be protected by repository access controls. Corrections are recorded as new rows.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover entity validation and identifier stability, and command-level tests exercise `init`, `add`, and `list` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic reference data handling.

### Glossary and Terminology

Entity: a counterparty or reference subject represented as a stable identifier in workspace datasets.  
Entity registry: the dataset set storing entity identifiers and metadata.

### See also

End user documentation: [bus-entities CLI reference](../modules/bus-entities)  
Repository: https://github.com/busdk/bus-entities

For reference data organization and schema expectations, see [Data package organization](../data/data-package-organization) and [Table schema contract](../data/table-schema-contract).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-accounts">bus-accounts</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-period">bus-period</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-entities module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-ENTITIES`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
