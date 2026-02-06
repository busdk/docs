## BusDK Software Design Document (SDD)

### Document control

Title: BusDK Software Design Document (SDD)  
Project: BusDK  
Document ID: `BUSDK-SDD`  
Version: 2026-02-06  
Status: Draft  
Last updated: 2026-02-06  
Owner: BusDK development team  
Change log: 2026-02-06 — Initial consolidation of the multi-page design spec into a single, deterministic SDD view. Updated acceptance criteria to reflect the documented CLI, data, and validation conventions, and expanded non-functional requirements and operational sections from source material.

### Review notes

This document consolidates the existing multi-page BusDK design spec into a single, implementation-oriented SDD structure. It is written to be citeable and reviewable without changing the intent of the underlying pages, and the acceptance criteria below are derived from the current source pages so they can be verified against documented behavior. Checklist for review: acceptance criteria are defined for all requirements with no TBDs or open questions remaining, and no unresolved conflicts are documented.

### Canonical multi-page design spec (original sources)

The canonical source material for this SDD is the existing multi-page BusDK design spec. Start from the [design spec entrypoint](./index) and follow the section indexes from there. This SDD links directly to the most relevant inner pages inline wherever it is logical for traceability.

## Introduction and Overview

BusDK (Business Development Kit), formerly known as Bus, is a modular, CLI-first toolkit for running a business, including accounting and bookkeeping. BusDK is designed for longevity, clarity, and extensibility by storing workspace datasets as transparent, human-readable text files validated by explicit schemas, and by keeping the workspace’s change history reviewable over time. This framing is defined in [Purpose and scope](./overview/purpose-and-scope) and elaborated as design goals in the [Design goals and requirements section](./design-goals/index).

The preferred default is that the workspace lives in a Git repository and that tabular datasets are stored as UTF-8 CSV with beside-the-table schemas expressed as Frictionless Data Table Schemas (JSON). Git and CSV are implementation choices, not the definition of the goal — the invariant is that the workspace datasets and their change history remain reviewable and exportable. See [Git as the canonical, append-only source of truth](./design-goals/git-as-source-of-truth), [Plain-text CSV for longevity](./design-goals/plaintext-csv-longevity), and [Schema-driven data contract (Frictionless Table Schema)](./design-goals/schema-contract).

This SDD is the single-page “source of truth” view. It complements the section pages that provide additional detail, including goals and scope, system architecture, data contracts, and workflows.

### Goals

BusDK’s design is driven by the following high-level goals.

- **G-001 Deterministic, script-friendly workflows**: the primary interface is a CLI toolchain whose behavior is predictable and automatable.
- **G-002 Reviewable repository data**: workspace datasets and their change history remain readable, diffable, and exportable over long retention periods.
- **G-003 Modular, loosely coupled components**: feature areas are implemented as independent modules that integrate through shared datasets rather than internal cross-module APIs.
- **G-004 Schema-driven data contracts**: schemas function as documentation, validation input, and compatibility guarantees across implementations.
- **G-005 Auditability through append-only discipline**: corrections are represented as additional records that preserve history rather than overwriting prior bookkeeping material.

These goals are expanded across [CLI-first](./design-goals/cli-first), [Unix-style composability](./design-goals/unix-composability), [Modularity](./design-goals/modularity), [Append-only auditability](./design-goals/append-only-auditability), and [Schema contract](./design-goals/schema-contract).

### Non-goals

BusDK deliberately does not take on responsibilities that would make outcomes discretionary or opaque.

- **NG-001**: BusDK does not execute Git commands or commit changes; Git operations are performed externally by the user or automation.
- **NG-002**: BusDK does not make discretionary accounting judgments (for example classification, valuation, or materiality decisions) on the user’s behalf.
- **NG-003**: AI assistance is an objective for workflow compatibility, not a required dependency for correctness.

## Requirements

This section defines requirements with stable identifiers. Each requirement is phrased as an invariant and paired with acceptance criteria that must be testable, derived from the documented CLI, data, and workflow conventions in the source pages.

### Functional requirements

- **FR-001 CLI-first toolchain**: BusDK MUST provide a CLI-first interface where workflows are expressed as explicit commands and produce deterministic outputs suitable for interactive use and scripting.  
  **Acceptance criteria**: The minimum required command surface for the end-to-end workflow is defined in [Minimum required command surface (end-to-end workflow)](./cli/minimum-command-surface). The CLI’s I/O and determinism conventions are specified in [Error handling, dry-run, and diagnostics](./cli/error-handling-dry-run-diagnostics), [Interactive use and scripting parity](./cli/interactive-and-scripting-parity), [Reporting and query commands](./cli/reporting-and-queries), and [Validation and safety checks](./cli/validation-and-safety-checks).  
  **Primary sources**: [CLI-first](./design-goals/cli-first), [CLI tooling and workflow](./cli/index), and [Command structure and discoverability](./cli/command-structure).

- **FR-002 Modular command surface**: BusDK MUST be organized as independent modules (typically `bus-*`) that plug into the `bus` dispatcher and operate on shared workspace datasets.  
  **Acceptance criteria**: Modules coordinate through datasets and schemas rather than calling each other’s internal APIs, and module responsibilities and dataset ownership are documented so cross-module integration is reviewable.  
  **Primary sources**: [Independent modules](./architecture/independent-modules), [Architectural overview](./architecture/architectural-overview), [Modules](./modules/index), and [Modularity](./design-goals/modularity).

- **FR-003 Workspace initialization**: BusDK MUST support a workspace bootstrap workflow where module-owned initialization creates baseline datasets and schemas without a monolithic initializer owning all files.  
  **Acceptance criteria**: The minimal “must exist after initialization” baseline is defined in [Minimal workspace baseline (after initialization)](./layout/minimal-workspace-baseline). Initialization must result in a schema-valid workspace where the end-to-end workflow can run without implicit dataset creation.  
  **Primary sources**: [Initialize a new repository](./workflow/initialize-repo), [Minimal workspace baseline (after initialization)](./layout/minimal-workspace-baseline), [Data directory layout (principles)](./layout/layout-principles), and [`bus init`](./modules/bus-init).

- **FR-004 Schema validation as a first-class workflow step**: BusDK MUST support schema-based validation and cross-table invariant checks as a repeatable step in day-to-day and period-close workflows.  
  **Acceptance criteria**: Schema validation MUST check types and referential integrity before any data mutation, and logical validation MUST enforce balanced debits and credits for transactions, valid account references, invoice totals matching line items, and VAT classification completeness when generating VAT reports. Validation failures MUST be deterministic, MUST exit non-zero, and MUST write diagnostics to standard error that cite datasets and stable identifiers. For Finnish compliance, validation MUST enforce audit-trail invariants (stable IDs, required voucher references, deterministic ordering fields) and MUST prevent changes that would break a closed period or previously reported data.  
  **Primary sources**: [Shared validation layer](./architecture/shared-validation-layer), [Validation and safety checks](./cli/validation-and-safety-checks), and [`bus validate`](./modules/bus-validate).

- **FR-005 Evidence is first-class repository data**: BusDK MUST support registering and linking supporting evidence (receipts, invoice PDFs, exports) so that datasets can reference attachment identifiers for traceability.  
  **Acceptance criteria**: Attachments MUST be registered in `attachments.csv` at the repository root with a stable `attachment_id` and immutable metadata (filename, media type, hash). Attachment files SHOULD be stored under a predictable period directory structure, and metadata MUST remain in the repository even when files are stored outside Git. Vouchers, journal entries, invoices, and bank records MUST link to attachments via `attachment_id` so the audit trail remains demonstrable.  
  **Primary sources**: [`bus attachments`](./modules/bus-attachments), [Invoice PDF storage](./layout/invoice-pdf-storage), and [Finnish bookkeeping and tax-audit compliance](./compliance/fi-bookkeeping-and-tax-audit).

### Non-functional requirements

- **NFR-001 Longevity and exportability**: Repository data MUST remain exportable and interpretable without requiring a specific runtime or proprietary storage backend.  
  **Acceptance criteria**: The default representation MUST be UTF-8 CSV with a header row, comma delimiters, ISO dates (YYYY-MM-DD), and predictable numeric formats for monetary values, paired with beside-the-table Frictionless Table Schemas. The canonical datasets MUST remain readable with general-purpose tools. If an alternative storage backend is used, it MUST preserve deterministic, schema-validated tables and MUST export back to simple tabular text formats consistent with these conventions.

- **NFR-002 Deterministic behavior**: Human-facing diagnostics and machine-facing outputs MUST be deterministic given the same repository data and configuration inputs.  
  **Acceptance criteria**: Command results MUST be written to standard output and diagnostics to standard error, with any terminal styling limited to standard error when it is a terminal. Machine-readable output modes MUST document stable formats, column sets, column order, and record ordering based on stable identifiers and explicit sort keys. Diagnostics MUST cite datasets and stable identifiers and show paths relative to the workspace root so that output remains stable across machines.

- **NFR-003 Maintainability through clear boundaries**: Module responsibilities and dataset ownership MUST be explicit so that modules can evolve independently.  
  **Acceptance criteria**: Each dataset has a clear owning module; schema changes have a documented migration path.

- **NFR-004 Reliability**: Workflows SHOULD fail fast with clear diagnostics when data contracts are violated.  
  **Acceptance criteria**: Invalid usage MUST exit with status code 2 and a concise usage error on standard error. Failures caused by repository contents, filesystem I/O, or schema and invariant violations MUST exit non-zero and include diagnostics that identify the dataset and stable identifiers involved. Commands MUST refuse to write invalid data when validation fails.

- **NFR-005 Security and access control**: Repository data MUST be protected by explicit access controls appropriate to the deployment context, and auditability MUST be preserved through append-only history.  
  **Acceptance criteria**: In single-user operation, OS-level permissions MUST be the primary security boundary. In collaborative scenarios, Git permissions and workflow controls (for example branch protections, reviews, and separation of duties) MUST be used to control who can propose and approve changes. If sensitive data must be scrubbed, it MUST be handled via an explicit redaction commit that flags the redaction rather than silently excising history.  
  **Primary sources**: [Append-only discipline and security model](./architecture/append-only-and-security), [Git as the canonical, append-only source of truth](./design-goals/git-as-source-of-truth).

- **NFR-006 Performance**: Repository operations SHOULD remain responsive for day-to-day use even as data grows.  
  **Acceptance criteria**: BusDK MUST support splitting large datasets into multiple files by time period or category so diffs remain focused and Git operations remain performant. The repository root MUST track segmented files through a stable index dataset (for example `journals.csv`) so tooling can locate period-specific files deterministically.  
  **Primary sources**: [Scaling over decades](./data/scaling-over-decades).

- **NFR-007 Scalability**: Repository data MUST remain manageable over long retention periods without losing auditability or discoverability.  
  **Acceptance criteria**: Older data MUST be archivable by tagging period-close revisions and, where needed, removing old-period files from active branches while retaining them in history for retrieval. Segmentation by period MUST preserve deterministic ordering and traceability across datasets.  
  **Primary sources**: [Scaling over decades](./data/scaling-over-decades), [CSV conventions](./data/csv-conventions).

## System Architecture

BusDK follows a “micro-tool” architecture. Each feature area is implemented as an independent CLI tool that reads and writes shared workspace datasets (tables plus schemas) stored as repository data. Modules coordinate by sharing data and by relying on an append-only revision history, rather than by calling each other’s internal APIs. The stable integration surface is the workspace datasets and their schemas, organized in a consistent directory layout. This is defined in [Architectural overview](./architecture/architectural-overview), [Independent modules](./architecture/independent-modules), and [CLI as the primary interface (controlled read/modify/write)](./architecture/cli-as-primary-interface).

The preferred default is a Git-backed repository where revisions can be reviewed and restored by external version control tooling, but the architectural goal is reviewability and exportability, not Git itself. See [Git-backed data repository (the data store)](./architecture/git-backed-data-store) and [Git as the canonical, append-only source of truth](./design-goals/git-as-source-of-truth).

## Component Design and Interfaces

### `bus` dispatcher

The `bus` dispatcher is the primary entry point for discovery and execution. It is responsible for listing available modules and routing module commands (for example `bus accounts`, `bus journal`, `bus vat`) to the corresponding module program.

The intended command surface and discoverability expectations are described in [Command structure and discoverability](./cli/command-structure) and the broader CLI conventions in [CLI tooling and workflow](./cli/index).

### Modules (`bus-*`)

Each module owns one or more datasets and their schemas, provides commands to initialize and maintain those datasets, and emits deterministic diagnostics. Modules integrate through shared conventions: stable dataset names, beside-the-dataset schema files, and documented cross-dataset references (primary keys and foreign keys).

Module responsibilities and how modules fit into the end-to-end workflow are captured in [Modules](./modules/index) and the workflow narrative starting from [Accounting workflow overview](./workflow/accounting-workflow-overview).

### External Git tooling

Git is treated as an external mechanism for recording revisions. BusDK does not commit changes and does not invoke Git commands. Workflows describe when a user should record a revision boundary (for example at period close), but the mechanism is external.

This separation is a design goal, not a workflow convenience. See [Git as the canonical, append-only source of truth](./design-goals/git-as-source-of-truth) and the operational conventions described in [Git commit conventions per operation (external Git)](./cli/automated-git-commits).

BusDK does not execute Git commands or create commits. All Git operations are performed externally by users or automation, and the CLI’s responsibility ends at deterministic read-modify-write of repository data.

## Data Design

BusDK’s canonical data model is a set of tables (“workspace datasets”) validated against explicit Table Schema definitions. Table Schemas declare fields, types, constraints, and keys (including primary keys and foreign keys where applicable). Schemas serve as documentation and as validation input, and they are a key mechanism for keeping revisions interpretable as tables evolve over time. See [Frictionless Table Schema as the contract](./data/table-schema-contract), [Schema evolution and migration](./data/schema-evolution-and-migration), and [CSV conventions](./data/csv-conventions).

Corrections are represented as additional bookkeeping that preserves history rather than overwriting prior vouchers or postings. Append-only discipline is treated as a first-class design requirement for long-term auditability. See [Append-only updates and soft deletion](./data/append-only-and-soft-deletion) and [Auditability and append-only discipline](./design-goals/append-only-auditability).

## Assumptions and Dependencies

The current design assumes a local filesystem workspace and a toolchain that can read and write structured text data. If a local filesystem is not available or accessible, BusDK cannot operate on repository data and the CLI workflows described here are not applicable.

The preferred default assumes a Git repository workspace, CSV datasets, and JSON schemas using the Frictionless Table Schema specification. If Git is not used, an alternative mechanism MUST preserve an append-only, reviewable change history. If CSV and Frictionless Table Schema are not used, an alternative storage backend MUST still provide deterministic, schema-validated tables and export back to simple, tabular text formats so the workspace datasets and their change history remain reviewable and exportable.

Workspace layout assumptions (what lives where in the repository) are defined in [Data directory layout](./layout/index), with an explicit baseline example in [Minimal example layout](./layout/minimal-example-layout).

## Security Considerations

Historical financial data is append-only, and corrections are represented as new records rather than destructive updates. In single-user operation, OS-level access control is the primary security boundary. In collaborative scenarios, Git permissions and review workflows are expected to enforce separation of duties and change approval, keeping the audit trail tamper-evident through the commit history. When redaction is necessary, it must be handled through explicit redaction commits that flag the redaction instead of silently excising history. See [Append-only discipline and security model](./architecture/append-only-and-security).

## Observability and Logging

Diagnostics and logging are designed to be deterministic and script-friendly. Commands write command results to standard output and diagnostics to standard error. Optional logging should provide visibility into validation steps and planned file changes without contaminating structured outputs. See [Error handling, dry-run, and diagnostics](./cli/error-handling-dry-run-diagnostics) and [Validation and safety checks](./cli/validation-and-safety-checks).

## Error Handling and Resilience

BusDK commands must fail with clear diagnostics when inputs are invalid or when repository data violates schema or invariants. Invalid usage exits with status code 2 and a concise usage error on standard error, while repository, filesystem, and validation failures exit non-zero with diagnostics that cite datasets and stable identifiers. Validation failures must prevent data mutation, and diagnostics must remain deterministic and citeable. See [Error handling, dry-run, and diagnostics](./cli/error-handling-dry-run-diagnostics) and [Validation and safety checks](./cli/validation-and-safety-checks).

## Testing Strategy

Not Applicable. The current design pages do not specify a testing strategy for BusDK modules or the CLI toolchain.

## Deployment and Operations

Not Applicable. The current design pages do not specify a deployment or operations model beyond the local repository workflow.

## Migration/Rollout

Schema evolution is expected and is handled through versioned schema updates and transparent migrations recorded in the repository history. Adding fields may be handled by defaulting missing historical values, while structural changes such as file splits or renames are acceptable as long as the migration is transparent and recorded. See [Schema evolution and migration](./data/schema-evolution-and-migration) and [Scaling over decades](./data/scaling-over-decades).

## Risks

Not Applicable. The current design pages do not enumerate specific project risks beyond the general need to preserve auditability and deterministic workflows.

## Glossary and Terminology

Workspace: the repository contents that hold the authoritative datasets, schemas, and supporting evidence for a bookkeeping scope (typically an accounting year).  
Repository data: the workspace datasets, schemas, and attachments stored in the repository.  
Workspace datasets: the canonical tables (typically CSV) plus their schemas that serve as the primary system of record.  
Table schema: the beside-the-table contract (Frictionless Table Schema) declaring fields, types, constraints, and keys.  
Module: an independent BusDK component (often `bus-*`) that owns specific datasets and provides commands over them.  
Change history (revision history): the reviewable history of changes to repository data, typically recorded through external version control tooling.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">BusDK design spec</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./overview/index">BusDK Design Spec: Overview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

