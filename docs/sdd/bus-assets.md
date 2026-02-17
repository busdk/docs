---
title: bus-assets — fixed-asset register and depreciation postings (SDD)
description: Bus Assets maintains a fixed-asset register as schema-validated repository data, generates depreciation schedules with clear audit trails, and produces…
---

## bus-assets — fixed-asset register and depreciation postings

### Introduction and Overview

Bus Assets maintains a fixed-asset register as schema-validated repository data, generates depreciation schedules with clear audit trails, and produces depreciation postings for the ledger.

### Requirements

FR-AST-001 Fixed-asset register. Bus Assets MUST store asset acquisitions, disposals, and depreciation schedules as schema-validated datasets with stable identifiers. Acceptance criteria: asset records validate against their schemas and can be traced to vouchers and evidence.

FR-AST-002 Posting outputs. The module MUST produce depreciation and disposal posting outputs suitable for the journal. Acceptance criteria: posting outputs reference the originating asset record identifiers and voucher identifiers.

NFR-AST-001 Auditability. The module MUST represent corrections as new records rather than destructive edits. Acceptance criteria: asset corrections are append-only and include references to the original records.

NFR-AST-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (fixed-asset register, depreciation datasets, and their schemas). Other modules that need read-only access to asset raw file(s) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration can be supported without breaking consumers. Acceptance criteria: the library provides path accessor(s) for the asset datasets; consumers use these accessors for read-only access; no consumer hardcodes asset file names outside this module.

FR-AST-003 Depreciation cap at disposal. Accumulated depreciation used in disposal postings MUST NOT exceed the depreciable base (cost minus residual value). Acceptance criteria: for every disposal, the accumulated-depreciation amount posted to clear the depreciation account is at most cost minus residual; disposal output never shows accumulated depreciation greater than the depreciable base.

FR-AST-004 No depreciation in disposal month when fully depreciated. If an asset is already fully depreciated before the disposal month, the dispose command MUST NOT emit an additional depreciation row for the disposal month. Acceptance criteria: for an asset whose depreciation schedule is complete by the end of month M−1, disposal with date in month M produces no DEP-* posting row for period M; disposal postings use the accumulated depreciation as of the end of the last period for which depreciation was applied.

FR-AST-005 Method value schema compliance. The `add` command MUST NOT write a `method` value that fails the fixed-asset register schema. The CLI MUST either reject unsupported `--method` values with invalid-usage exit before writing, or normalize accepted aliases to the schema enum value(s) and write only the canonical value. Acceptance criteria: after `add` with any accepted `--method` token, `bus assets validate` succeeds; unsupported method tokens exit non-zero without modifying the dataset.

### System Architecture

Bus Assets owns the assets area datasets and exposes a CLI surface that writes asset registers and depreciation schedules. It integrates with the ledger by producing posting outputs for `bus journal` and relies on account references from `bus accounts`.

### Key Decisions

KD-AST-001 Asset records are canonical repository data. The asset register and depreciation schedules are stored as datasets with beside-the-table schemas for long-term reviewability.

KD-AST-002 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of asset datasets for read-only access. Write access and all asset business logic remain in this module.

### Component Design and Interfaces

Interface IF-AST-001 (module CLI). The module exposes `bus assets` with subcommands `init`, `add`, `depreciate`, and `dispose` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline fixed-asset datasets and schemas when they are absent. If all owned asset datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

The `add` command records a new asset acquisition in the fixed-asset register. It accepts `--asset-id <id>`, `--name <text>`, `--acquired <YYYY-MM-DD>`, `--cost <amount>`, `--asset-account <account-id>`, `--depreciation-account <account-id>`, `--expense-account <account-id>`, `--method <method>`, and `--life-months <number>` as required parameters, and it accepts `--in-service <YYYY-MM-DD>`, `--salvage <amount>`, `--desc <text>`, and `--voucher <voucher-id>` as optional parameters. When `--in-service` is omitted, the in-service date is the acquisition date; when `--salvage` is omitted, the salvage value is zero. Accepted `--method` values are the schema-canonical depreciation method identifiers. The only method supported by the current schema is `straight_line_monthly`. The CLI MAY accept the alias `straight-line` and normalize it to `straight_line_monthly` before writing; any other token is invalid usage and MUST be rejected before writing (FR-AST-005). The value written to the dataset MUST always be one of the schema enum values so that `bus assets validate` succeeds.

The `depreciate` command generates depreciation entries for a specific period and produces posting output for the journal. It accepts `--period <period>` as a required parameter and `--asset-id <id>` and `--post-date <YYYY-MM-DD>` as optional parameters. When `--asset-id` is present, the command scopes to a single asset; when `--post-date` is omitted, the posting date is the last date of the selected period.

The `dispose` command records an asset disposal and produces disposal postings. Required parameters: `--asset-id <id>`, `--date <YYYY-MM-DD>`, `--proceeds-account <account-id>`, `--gain-account <account-id>`, and `--loss-account <account-id>`. Optional parameters: `--proceeds <amount>`, `--desc <text>`, and `--voucher <voucher-id>`. When `--proceeds` is omitted, the proceeds amount is zero and the disposal is treated as a non-cash write-off. Gain and loss accounts are required so that disposal can post gain or loss to the correct ledger accounts. Disposal behavior: accumulated depreciation as of disposal is capped to the depreciable base (cost minus residual value) per FR-AST-003. If the asset is already fully depreciated before the disposal month, the command MUST NOT emit a depreciation row for the disposal month (FR-AST-004). The command then posts removal of the asset and accumulated depreciation, posts proceeds to the proceeds account, and posts gain or loss to the gain or loss account as appropriate.

Interface IF-AST-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to its owned data file(s) (fixed-asset register and depreciation datasets and their schemas). Given a workspace root path, the library returns the path(s); resolution MUST allow future override from workspace or data package configuration. Other modules use these accessors for read-only access only; all writes and asset logic remain in this module.

Usage examples:

```bash
bus assets init
bus assets depreciate
```

### Data Design

The module reads and writes fixed-asset datasets in the assets area, with JSON Table Schemas stored beside each CSV dataset. Master data owned by this module is stored in the workspace root only; the module does not create or use an `assets/` or other subdirectory for its datasets and schemas.

Other modules that need read-only access to asset datasets MUST obtain the path(s) from this module’s Go library (IF-AST-002). All writes and asset-domain logic remain in this module.

### Assumptions and Dependencies

Bus Assets depends on the workspace layout and schema conventions and on valid account references from `bus accounts`. If the assets datasets or schemas are missing, the module fails with deterministic diagnostics.

### Security Considerations

Asset records and schedules are repository data and should be protected by the same access controls as the rest of the workspace. Evidence links are preserved to keep the audit trail intact.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema and invariant violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover asset validation and schedule generation, and command-level tests exercise `init`, `add`, `depreciate`, and `dispose` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly asset data.

### Glossary and Terminology

Depreciable base: cost minus residual value (salvage); the maximum amount that may be depreciated over the asset's life. Accumulated depreciation must not exceed the depreciable base.  
Depreciation method: the schema-canonical identifier for the allocation method (e.g. `straight_line_monthly`). The `add` command writes only values allowed by the fixed-asset register schema; unsupported or alias tokens must be rejected or normalized before writing.  
Fixed-asset register: the dataset describing asset acquisitions, disposals, and schedules.  
Depreciation schedule: derived entries that allocate asset cost over time.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reconcile">bus-reconcile</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-loans">bus-loans</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Fixed assets](../master-data/fixed-assets/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [Master data: Documents (evidence)](../master-data/documents/index)
- [End user documentation: bus-assets CLI reference](../modules/bus-assets)
- [Repository](https://github.com/busdk/bus-assets)
- [Append-only and soft deletion](../data/append-only-and-soft-deletion)
- [Append-only auditability](../design-goals/append-only-auditability)

### Document control

Title: bus-assets module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-ASSETS`  
Version: 2026-02-17  
Status: Draft  
Last updated: 2026-02-17  
Owner: BusDK development team  
