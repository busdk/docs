## bus-invoices

### Introduction and Overview

Bus Invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the journal.

### Requirements

FR-INV-001 Invoice datasets. The module MUST store invoice headers and lines as schema-validated datasets with stable invoice identifiers. Acceptance criteria: invoice rows validate against schemas and reject inconsistent totals.

FR-INV-002 CLI surface for invoice lifecycle. The module MUST provide commands to initialize, add, list, validate, and render invoices. Acceptance criteria: `init`, `add`, `list`, and `pdf` are available and fail deterministically on invalid inputs.

NFR-INV-001 Auditability. Invoice corrections MUST be recorded as new records and linked to attachments and journal postings. Acceptance criteria: corrections do not overwrite existing records and references remain traceable.

### System Architecture

Bus Invoices owns invoice header and line datasets and integrates with the ledger by optionally writing journal postings. It relies on entities, accounts, VAT reference data, and attachments for traceability.

### Key Decisions

KD-INV-001 Invoice data is canonical repository data. Invoice headers and lines are stored as datasets so they remain reviewable and exportable.

### Component Design and Interfaces

Interface IF-INV-001 (module CLI). The module exposes `bus invoices` with subcommands `init`, `add`, `list`, and `pdf` and follows BusDK CLI conventions for deterministic output and diagnostics.

The design spec also documents invoice-line operations as `bus invoices <invoice-id> add` and `bus invoices <invoice-id> validate`, which append and validate line items for a specific invoice.

Documented parameters for `bus invoices add` are `--type <sales|purchase>`, `--invoice-id <id>`, `--invoice-date <YYYY-MM-DD>`, `--due-date <YYYY-MM-DD>`, and `--customer <name>`. Documented parameters for `bus invoices <invoice-id> add` are `--desc <text>`, `--quantity <number>`, `--unit-price <number>`, `--revenue-account <account-name>`, and `--vat-rate <percent>`. Documented parameters for `bus invoices pdf` are `<invoice-id>` as a positional argument and `--out <path>`. Documented parameters for `bus invoices list` include a deterministic filter surface: `--type <sales|purchase>`, `--status <status>`, `--month <YYYY-M>`, `--from <YYYY-MM-DD>`, `--to <YYYY-MM-DD>`, `--due-from <YYYY-MM-DD>`, `--due-to <YYYY-MM-DD>`, `--counterparty <entity-id>`, and `--invoice-id <id>`. Date filters apply to the invoice date in the header dataset, while `--due-from` and `--due-to` apply to the due date. `--month` selects the calendar month and is mutually exclusive with `--from` or `--to`. `--from` and `--to` may be used together or independently and are inclusive bounds, and the same inclusivity applies to `--due-from` and `--due-to`. `--status` matches the header status value exactly as stored, typically values like unpaid or paid. `--counterparty` matches the invoice header counterparty identifier exactly as stored, typically aligned with `bus entities` identifiers. `--invoice-id` matches the stable invoice identifier exactly. When multiple filters are supplied, they are combined with logical AND so every returned row satisfies every filter.

Usage examples:

```bash
bus invoices add --type sales --invoice-id 1001 --invoice-date 2026-01-15 --due-date 2026-02-14 --customer "Acme Corp"
bus invoices 1001 add --desc "Consulting, 10h @ EUR 100/h" --quantity 10 --unit-price 100 --revenue-account "Consulting Revenue" --vat-rate 25.5
```

```bash
bus invoices pdf 1001 --out tmp/INV-1001.pdf
bus invoices list --status unpaid
```

### Data Design

The module reads and writes invoice header and line datasets in the repository root, such as `sales-invoices.csv` and `sales-invoice-lines.csv`, with JSON Table Schemas stored beside each dataset.

### Assumptions and Dependencies

Bus Invoices depends on reference data from `bus entities`, `bus accounts`, and VAT reference datasets. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Invoice datasets and rendered PDFs may contain sensitive information and should be protected by repository access controls. Evidence links are preserved through attachments metadata.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover invoice validation and posting integration, and command-level tests exercise `add`, line item additions, `list`, `validate`, and `pdf` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic invoice data handling.

### Glossary and Terminology

Invoice header: the dataset row describing invoice metadata and totals.  
Invoice line: the dataset row describing a line item linked to an invoice header.

### See also

End user documentation: [bus-invoices CLI reference](../modules/bus-invoices)  
Repository: https://github.com/busdk/bus-invoices

For invoice dataset layout and workflow details, see [Invoices area](../layout/invoices-area) and [Add a sales invoice](../workflow/create-sales-invoice).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-attachments">bus-attachments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-pdf">bus-pdf</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Document control

Title: bus-invoices module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-INVOICES`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
Change log: 2026-02-07 — Reframed the module page as a short SDD with command surface, parameters, and usage examples. 2026-02-07 — Defined the deterministic filter surface for `bus invoices list`. 2026-02-07 — Moved module SDDs under `docs/sdd` and linked to end user CLI references.
