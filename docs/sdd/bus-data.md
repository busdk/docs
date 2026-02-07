## bus-data

### Introduction and Overview

Bus Data provides the shared tabular data layer for BusDK by implementing schema-validated dataset I/O and validation for workspace datasets. Its primary surface is a Go library that other modules import directly for deterministic table and schema handling.

### Requirements

FR-DAT-001 Deterministic dataset I/O. The module MUST provide deterministic read, write, and validation behavior for workspace datasets. Acceptance criteria: table reads and writes are schema-validated and refuse invalid writes.

FR-DAT-002 Library-first integration. The Go library MUST be the primary integration surface for other modules. Acceptance criteria: module integrations rely on the library rather than shelling out to the `bus data` CLI.

NFR-DAT-001 Mechanical scope. The module MUST remain a mechanical data layer and MUST NOT implement domain-specific accounting logic. Acceptance criteria: domain invariants are enforced by domain modules, not by `bus data`.

### System Architecture

Bus Data implements the workspace store interface and dataset I/O mechanics used by other modules. The CLI, if present, is a thin wrapper for inspection and validation.

### Key Decisions

KD-DAT-001 Shared library for data mechanics. Dataset I/O and schema handling are centralized in a library to keep module behavior consistent.

### Component Design and Interfaces

Interface IF-DAT-001 (data library). The module exposes a Go library interface for reading, validating, and writing tables and schemas deterministically.

Interface IF-DAT-002 (module CLI). The module exposes `bus data` as a minimal, read-only inspection CLI for workspace tables and schemas. It accepts a workspace-relative table path that points to a CSV file (for example `accounts.csv`) and resolves the schema beside the table by replacing the `.csv` suffix with `.schema.json` in the same directory. The minimal subcommands are fixed so the inspection surface is deterministic.

Subcommand `bus data list` takes no parameters and emits a deterministic TSV with columns `table_path` and `schema_path`, one row per table. A table is any `*.csv` file that has a beside-the-table schema file. Output ordering is lexicographic by `table_path` so the results are stable across machines.

Subcommand `bus data schema <table>` takes a required table path and writes the schema file content exactly as stored on disk to standard output. If the schema file is missing or unreadable, the command exits non-zero with a concise diagnostic.

Subcommand `bus data read <table>` takes a required table path, loads the beside-the-table schema, validates the table against the schema, and writes canonical CSV with a header row to standard output. It preserves the row order from the file and performs no normalization beyond validation. On validation failure, the command exits non-zero and does not emit partial output.

Usage example:

```bash
bus data --help
```

### Data Design

The module operates on workspace datasets and beside-the-table schemas (CSV plus Table Schema by default). It may update schema files and table files only when explicitly instructed.

### Assumptions and Dependencies

Bus Data depends on the workspace layout and schema conventions. If datasets or schemas are missing or invalid, the library and CLI return deterministic diagnostics.

### Security Considerations

Bus Data does not perform network or Git operations. It must preserve auditability by refusing invalid or destructive writes.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover schema parsing, deterministic read and write behavior, and validation errors. Command-level tests, if CLI commands exist, validate deterministic output and exit codes.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and library and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic data handling.

### Glossary and Terminology

Workspace store interface: the persistence boundary for deterministic table and schema operations.  
Mechanical data layer: functionality that handles storage and validation without domain rules.

### See also

End user documentation: [bus-data CLI reference](../modules/bus-data)  
Repository: https://github.com/busdk/bus-data

For the storage backend boundary and repository rules that the library implements, see [Storage backends and workspace store interface](../data/storage-backends) and [Module repository structure and dependency rules](../implementation/module-repository-structure).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./modules">Modules (SDD)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-data module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-DATA`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Defined the minimal `bus data` inspection subcommands and parameters to close OQ-DAT-001. 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
