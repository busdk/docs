## bus-budget

### Introduction and Overview

Bus Budget maintains budget datasets keyed by account and period, validates them against schemas and the chart of accounts, and produces budget versus actual variance outputs.

### Requirements

FR-BUD-001 Budget datasets. The module MUST store budgets as schema-validated repository data keyed by account and period. Acceptance criteria: budgets validate against schemas and reference valid account identifiers.

FR-BUD-002 Variance reporting. The module MUST compute budget versus actual variance outputs from budgets and journal data. Acceptance criteria: `bus budget report` emits deterministic output with stable ordering.

NFR-BUD-001 Reproducibility. Budget outputs MUST be reproducible from stored budgets and journal actuals. Acceptance criteria: variance results are derived from repository data without external dependencies.

### System Architecture

Bus Budget owns the budgeting area datasets and produces variance outputs by reading journal actuals and accounts. It integrates with `bus reports` and management reporting workflows.

### Key Decisions

KD-BUD-001 Budgets are stored as repository datasets. Budget intent is recorded as data so variance outputs remain deterministic and reviewable.

### Component Design and Interfaces

Interface IF-BUD-001 (module CLI). The module exposes `bus budget` with subcommands `init`, `add`, `set`, and `report` and follows BusDK CLI conventions for deterministic output and diagnostics.

Documented parameters include `bus budget report --year <YYYY>` and `bus budget report --period <period>`. Documented parameters for `bus budget add` are `--account <account-id>`, `--year <YYYY>`, `--period <MM|Qn>`, and `--amount <decimal>`, with no positional arguments. Documented parameters for `bus budget set` are the same, and `set` is defined as an upsert keyed by `(account, year, period)` that replaces the existing row for that key or inserts a new row when none exists.

Usage examples:

```bash
bus budget init
bus budget report --year 2026
```

### Data Design

The module reads and writes budget datasets in the budgeting area, such as `budgets.csv`, with JSON Table Schemas stored beside each dataset.

### Assumptions and Dependencies

Bus Budget depends on valid account references from `bus accounts` and actuals from `bus journal`. If referenced datasets or schemas are missing, the module fails with deterministic diagnostics.

### Security Considerations

Budget datasets are repository data and should be protected by the same access controls as the rest of the workspace. Budgets remain separate from statutory records but still require audit-friendly handling.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover budget validation and variance calculation, and command-level tests exercise `init`, `add`, `set`, and `report` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic and audit-friendly budget data.

### Glossary and Terminology

Budget dataset: the repository table that records planned amounts by account and period.  
Variance report: derived output comparing budgeted and actual amounts.

### See also

Repository: https://github.com/busdk/bus-budget

For budget dataset layout and variance workflow context, see [Budget area](../layout/budget-area) and [Budgeting and budget vs actual](../workflow/budgeting-and-budget-vs-actual).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-reconcile">bus-reconcile</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-payroll">bus-payroll</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-budget module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-BUDGET`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples.
