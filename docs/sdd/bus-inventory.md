## bus-inventory

### Introduction and Overview

Bus Inventory maintains item master data and stock movement ledgers, validates inventory datasets with Table Schemas, and produces valuation outputs for accounting and reporting.

### Requirements

FR-INV-001 Inventory datasets. The module MUST store item and movement data as schema-validated repository datasets. Acceptance criteria: item and movement rows validate against schemas and reference valid item identifiers.

FR-INV-002 Valuation outputs. The module MUST produce valuation outputs suitable for reporting and posting. Acceptance criteria: valuation outputs reference item and movement identifiers and can be traced to vouchers.

NFR-INV-001 Auditability. Inventory corrections MUST be append-only and reference original records. Acceptance criteria: movement and valuation records are not overwritten.

### System Architecture

Bus Inventory owns inventory datasets and produces valuation outputs that can be posted into the journal. It relies on account references from `bus accounts` and integrates with `bus reports`.

### Key Decisions

KD-INV-001 Inventory is stored as repository data. Item master data and movements remain reviewable and exportable as datasets.

### Component Design and Interfaces

Interface IF-INV-001 (module CLI). The module exposes `bus inventory` with subcommands `init`, `add-item`, `record-movement`, and `valuation` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `add-item` command records a new inventory item in the item master dataset. It accepts `--item-id <id>`, `--name <text>`, `--unit <text>`, `--valuation-method <fifo|weighted-average>`, `--inventory-account <account-id>`, and `--cogs-account <account-id>` as required parameters, and it accepts `--desc <text>` and `--sku <text>` as optional parameters. The valuation method is stored on the item record and is used as the default method when computing valuation outputs.

The `record-movement` command appends a stock movement row for an item. It accepts `--item-id <id>`, `--date <YYYY-MM-DD>`, `--qty <decimal>`, and `--direction <in|out|adjust>` as required parameters, and it accepts `--unit-cost <amount>`, `--desc <text>`, and `--voucher <voucher-id>` as optional parameters. When `--direction` is `in` or `adjust`, `--unit-cost` is required and records the per-unit acquisition or adjustment cost; when `--direction` is `out` and `--unit-cost` is omitted, the cost is derived during valuation using the item's valuation method.

The `valuation` command computes valuation outputs for an as-of date. It accepts `--as-of <YYYY-MM-DD>` as a required parameter and `--item-id <id>` as an optional parameter. When `--item-id` is supplied, the output is scoped to that item; otherwise the output includes all items that have movements up to the as-of date, and valuation uses the method stored on each item record.

Usage examples:

```bash
bus inventory init
bus inventory valuation
```

### Data Design

The module reads and writes inventory item and movement datasets in the inventory area, with JSON Table Schemas stored beside each CSV dataset.

### Assumptions and Dependencies

Bus Inventory depends on the workspace layout and schema conventions and on account references from `bus accounts`. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Inventory data is repository data and should be protected by repository access controls. Evidence links remain intact to preserve auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover inventory validation and valuation logic, and command-level tests exercise `init`, `add-item`, `record-movement`, and `valuation` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic inventory data handling.

### Glossary and Terminology

Inventory item: a master data record describing a stock item.  
Stock movement: an append-only record of inventory quantity changes.

### See also

End user documentation: [bus-inventory CLI reference](../modules/bus-inventory)  
Repository: https://github.com/busdk/bus-inventory

For dataset structure and audit trail expectations, see [Table schema contract](../data/table-schema-contract) and [Append-only and soft deletion](../data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-loans">bus-loans</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-payroll">bus-payroll</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-inventory module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-INVENTORY`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
