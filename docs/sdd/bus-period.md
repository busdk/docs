## bus-period

### Introduction and Overview

Bus Period opens and closes accounting periods, generates closing and opening balance entries, and locks periods to prevent changes after close.

### Requirements

FR-PER-001 Period control datasets. The module MUST store period open, close, and lock states as schema-validated repository data. Acceptance criteria: period rows validate against schemas and are append-only.

FR-PER-002 Close and lock operations. The module MUST generate closing entries and enforce period locks. Acceptance criteria: close outputs are deterministic and locked periods reject writes.

NFR-PER-001 Auditability. Period transitions MUST remain reviewable in repository history. Acceptance criteria: period control datasets preserve open and close boundaries without overwrites.

### System Architecture

Bus Period owns the period control datasets and uses journal data to generate closing entries. It integrates with validation, VAT, and reporting workflows that precede filing and exports.

### Key Decisions

KD-PER-001 Period control is recorded as repository data. Period transitions are stored in datasets so close and lock boundaries remain reviewable.

### Component Design and Interfaces

Interface IF-PER-001 (module CLI). The module exposes `bus period` with subcommands `init`, `open`, `close`, and `lock` and follows BusDK CLI conventions for deterministic output and diagnostics.

Period selection is always explicit and flag-based. The `open`, `close`, and `lock` commands accept `--period <period>` as a required parameter and do not use positional period arguments. A period identifier is a stable string in one of three forms: `YYYY` for a full-year period, `YYYY-MM` for a calendar month, or `YYYYQn` for a quarter (where `n` is 1 through 4). This mirrors period usage in other modules such as `bus vat`, `bus loans`, and `bus payroll`, which also use `--period` and `YYYY-MM` or `YYYYQn` formats rather than positional arguments.

Close generates posting output and therefore accepts one additional optional flag: `--post-date <YYYY-MM-DD>`. When `--post-date` is omitted, the closing entry date defaults to the last date of the selected period, matching the default behavior of other posting-generating commands that accept `--post-date`.

Usage examples:

```bash
bus period open --period 2026-02
bus period close --period 2026-02
```

```bash
bus period close --period 2026Q1 --post-date 2026-03-31
bus period lock --period 2026Q1
```

### Data Design

The module reads and writes `periods.csv` at the repository root, with a beside-the-table schema file. Period operations append records so period boundaries remain reviewable.

### Assumptions and Dependencies

Bus Period depends on journal datasets and on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Period locks are a control boundary and must be enforced in the module to prevent edits to closed periods. Repository access controls protect underlying data.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Close or lock violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover period state transitions and close calculations, and command-level tests exercise `open`, `close`, and `lock` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic period control.

### Glossary and Terminology

Period control dataset: the repository dataset that records period boundaries and locks.  
Period lock: a state that prevents edits to closed period data.

### See also

End user documentation: [bus-period CLI reference](../modules/bus-period)  
Repository: https://github.com/busdk/bus-period

For period close workflow context, see [Year-end close (closing entries)](../workflow/year-end-close) and [Accounting workflow overview](../workflow/accounting-workflow-overview).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-entities">bus-entities</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-attachments">bus-attachments</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-period module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-PERIOD`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Defined period identifiers and close parameters. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
