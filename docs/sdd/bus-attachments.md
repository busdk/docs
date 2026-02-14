---
title: bus-attachments — evidence storage and attachment metadata (SDD)
description: Bus Attachments stores evidence files and maintains attachment metadata as schema-validated repository data so other modules can link to evidence without…
---

## bus-attachments — evidence storage and attachment metadata

### Introduction and Overview

Bus Attachments stores evidence files and maintains attachment metadata as schema-validated repository data so other modules can link to evidence without embedding file paths directly in domain datasets.

### Requirements

FR-ATT-001 Attachment metadata registry. The module MUST write stable attachment identifiers and immutable metadata to `attachments.csv` with schema validation. Acceptance criteria: each added attachment has a stable identifier and hash metadata, and invalid inputs fail without modifying datasets.

FR-ATT-002 CLI surface for evidence registration. The module MUST provide commands to initialize, add, and list attachments. Acceptance criteria: `init`, `bus attachments add`, and `bus attachments list` are available and emit deterministic outputs.

FR-ATT-003 Init behavior. The module MUST provide an `init` command that creates the attachments metadata dataset and schema when they are absent. When they already exist in full, `init` MUST print a warning to standard error and exit 0 without modifying anything. When they exist only partially, `init` MUST fail with a clear error and not write any file (see [bus-init](../sdd/bus-init) FR-INIT-004). Acceptance criteria: `bus attachments init` is available; idempotent and partial-state behavior as specified.

NFR-ATT-001 Auditability. Attachment metadata MUST remain in the repository even if files are stored outside Git. Acceptance criteria: metadata rows are retained and list outputs remain deterministic.

### System Architecture

Bus Attachments owns the repository-root attachments metadata dataset and manages references to files stored under a predictable directory structure. It integrates with invoices, journal entries, bank data, and reconciliation by providing stable attachment identifiers.

### Key Decisions

KD-ATT-001 Attachment evidence is recorded as repository data. Attachment metadata remains in the workspace datasets for the full retention period.

KD-ATT-002 Attachments are a special case for file layout. Evidence files are stored under a dedicated subdirectory `./attachments/yyyy/mm/yyyymmdd-filename...` (relative to the workspace root), where `yyyy` is the four-digit year, `mm` is the two-digit month, and the filename is prefixed with an eight-digit date. The metadata dataset and schema remain at the workspace root; only the evidence files use this subdirectory.

### Component Design and Interfaces

Interface IF-ATT-001 (module CLI). The module exposes `bus attachments` with subcommands `init`, `add`, and `list` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline attachments metadata dataset and schema (`attachments.csv` and `attachments.schema.json`) when they are absent. If both already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

The `add` command accepts a positional file path plus a description parameter. Documented parameters are `<file>` as a positional argument and `--desc <text>` for the attachment description.

Usage examples:

```bash
bus attachments add tmp/INV-1001.pdf --desc "Invoice INV-1001 (PDF)"
bus attachments list
```

### Data Design

The module reads and writes `attachments.csv` in the repository root with a beside-the-table schema file. Master data (the metadata dataset and its schema) lives in the workspace root only. Evidence files are stored under `./attachments/yyyy/mm/yyyymmdd-filename...` — for example `attachments/2026/01/20260115-INV-1001.pdf` — where `yyyy` is the four-digit year, `mm` is the two-digit month, and the filename begins with an eight-digit date. This is the only BusDK layout that places operational files in a subdirectory; the path is deterministic so the metadata can reference it reliably. Each `attachment_id` is a standard UUID string in canonical form so integrations can generate or validate identifiers without guessing; the expected representation is lowercase hex with hyphens in 8-4-4-4-12 grouping.

### Assumptions and Dependencies

Bus Attachments depends on the workspace layout and schema conventions and assumes the file path provided exists and is readable. Missing files or inaccessible paths result in deterministic diagnostics.

### Security Considerations

Attachment files may contain sensitive evidence and should be protected by repository access controls. Hashes and metadata are stored to keep the audit trail verifiable.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Missing files or schema violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover metadata validation and hashing, and command-level tests exercise `add` and `list` against fixture workspaces with sample files.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly evidence handling.

### Glossary and Terminology

Attachment: an evidence file registered in `attachments.csv` and referenced by stable identifier.  
Attachment metadata: immutable details such as filename, media type, and hash.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-period">bus-period</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-invoices">bus-invoices</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Documents (evidence)](../master-data/documents/index)
- [Master data: Bookkeeping status and review workflow](../master-data/workflow-metadata/index)
- [End user documentation: bus-attachments CLI reference](../modules/bus-attachments)
- [Repository](https://github.com/busdk/bus-attachments)
- [Invoice PDF storage](../layout/invoice-pdf-storage)
- [Append-only and soft deletion](../data/append-only-and-soft-deletion)

### Document control

Title: bus-attachments module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-ATTACHMENTS`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
