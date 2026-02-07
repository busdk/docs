## bus-assets

### Introduction and Overview

Bus Assets maintains a fixed-asset register as schema-validated repository data, generates depreciation schedules with clear audit trails, and produces depreciation postings for the ledger.

### Requirements

FR-AST-001 Fixed-asset register. Bus Assets MUST store asset acquisitions, disposals, and depreciation schedules as schema-validated datasets with stable identifiers. Acceptance criteria: asset records validate against their schemas and can be traced to vouchers and evidence.

FR-AST-002 Posting outputs. The module MUST produce depreciation and disposal posting outputs suitable for the journal. Acceptance criteria: posting outputs reference the originating asset record identifiers and voucher identifiers.

NFR-AST-001 Auditability. The module MUST represent corrections as new records rather than destructive edits. Acceptance criteria: asset corrections are append-only and include references to the original records.

### System Architecture

Bus Assets owns the assets area datasets and exposes a CLI surface that writes asset registers and depreciation schedules. It integrates with the ledger by producing posting outputs for `bus journal` and relies on account references from `bus accounts`.

### Key Decisions

KD-AST-001 Asset records are canonical repository data. The asset register and depreciation schedules are stored as datasets with beside-the-table schemas for long-term reviewability.

### Component Design and Interfaces

Interface IF-AST-001 (module CLI). The module exposes `bus assets` with subcommands `init`, `add`, `depreciate`, and `dispose` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `add` command records a new asset acquisition in the fixed-asset register. It accepts `--asset-id <id>`, `--name <text>`, `--acquired <YYYY-MM-DD>`, `--cost <amount>`, `--asset-account <account-id>`, `--depreciation-account <account-id>`, `--expense-account <account-id>`, `--method <straight-line>`, and `--life-months <number>` as required parameters, and it accepts `--in-service <YYYY-MM-DD>`, `--salvage <amount>`, `--desc <text>`, and `--voucher <voucher-id>` as optional parameters. When `--in-service` is omitted, the in-service date is the acquisition date; when `--salvage` is omitted, the salvage value is zero.

The `depreciate` command generates depreciation entries for a specific period and produces posting output for the journal. It accepts `--period <period>` as a required parameter and `--asset-id <id>` and `--post-date <YYYY-MM-DD>` as optional parameters. When `--asset-id` is present, the command scopes to a single asset; when `--post-date` is omitted, the posting date is the last date of the selected period.

The `dispose` command records an asset disposal and produces disposal postings. It accepts `--asset-id <id>`, `--date <YYYY-MM-DD>`, and `--proceeds-account <account-id>` as required parameters, and it accepts `--proceeds <amount>`, `--desc <text>`, and `--voucher <voucher-id>` as optional parameters. When `--proceeds` is omitted, the proceeds amount is zero and the disposal is treated as a non-cash write-off.

Usage examples:

```bash
bus assets init
bus assets depreciate
```

### Data Design

The module reads and writes fixed-asset datasets in the assets area, with JSON Table Schemas stored beside each CSV dataset.

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

Fixed-asset register: the dataset set describing asset acquisitions, disposals, and schedules.  
Depreciation schedule: derived entries that allocate asset cost over time.

### See also

End user documentation: [bus-assets CLI reference](../modules/bus-assets)  
Repository: https://github.com/busdk/bus-assets

For dataset invariants and audit trail expectations, see [Append-only and soft deletion](../data/append-only-and-soft-deletion) and [Append-only auditability](../design-goals/append-only-auditability).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-journal">bus-journal</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./modules">Modules (SDD)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-loans">bus-loans</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-assets module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-ASSETS`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Defined the module-specific flags and positional parameters for `add`, `depreciate`, and `dispose`. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
