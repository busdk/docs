# BuSDK Design Document

Modular CLI-First Business Development Toolkit (CSV + Frictionless Data + Git)

This design document has been split into topic-focused specs under `spec/`, with **one semantic topic per file**.

## Accounting workflow (current planned modules)

BusDK is designed for year-round bookkeeping in a dedicated Git repo: CSV datasets are validated by Frictionless Table Schemas and every data change is committed alongside its supporting evidence. The core dispatcher is [`bus`](https://github.com/busdk/bus) and the workflow below reflects the current set of planned modules in the BusDK org.

- Set up a Git repository for the bookkeeping year and install `bus` plus the module binaries you will use.
- Define master data: chart of accounts with [`bus accounts`](https://github.com/busdk/bus-accounts), counterparties with [`bus entities`](https://github.com/busdk/bus-entities), and periods with [`bus period`](https://github.com/busdk/bus-period).
- Treat evidence as data: archive invoices, receipts, VAT exports, and bank files with [`bus attachments`](https://github.com/busdk/bus-attachments) and reference those IDs from other records.
- Record activity: invoices with [`bus invoices`](https://github.com/busdk/bus-invoices), ledger postings with [`bus journal`](https://github.com/busdk/bus-journal), and assets with [`bus assets`](https://github.com/busdk/bus-assets) as they occur.
- Reconcile regularly: import bank feeds with [`bus bank`](https://github.com/busdk/bus-bank), match and reconcile with [`bus reconcile`](https://github.com/busdk/bus-reconcile), then fill gaps via [`bus invoices`](https://github.com/busdk/bus-invoices) or [`bus journal`](https://github.com/busdk/bus-journal).
- Close each period: validate with [`bus validate`](https://github.com/busdk/bus-validate), compute VAT with [`bus vat`](https://github.com/busdk/bus-vat), lock with [`bus period`](https://github.com/busdk/bus-period), and generate reports with [`bus reports`](https://github.com/busdk/bus-reports).
- At year end, repeat the close flow, ensure assets and VAT are complete, and tag the final state.

For the full narrative, see [`spec/workflow/accounting-workflow-overview.md`](https://github.com/busdk/docs/blob/main/spec/workflow/accounting-workflow-overview.md).

## Spec index

- **Overview**: [spec/00-overview.md](https://github.com/busdk/docs/blob/main/spec/00-overview.md)
- **Design goals and requirements**: [spec/01-design-goals.md](https://github.com/busdk/docs/blob/main/spec/01-design-goals.md)
- **System architecture**: [spec/02-architecture.md](https://github.com/busdk/docs/blob/main/spec/02-architecture.md)
- **Data format and storage**: [spec/03-data-formats-and-storage.md](https://github.com/busdk/docs/blob/main/spec/03-data-formats-and-storage.md)
- **CLI tooling and workflow**: [spec/04-cli-workflow.md](https://github.com/busdk/docs/blob/main/spec/04-cli-workflow.md)
- **Integration and future interfaces**: [spec/05-integration-future-interfaces.md](https://github.com/busdk/docs/blob/main/spec/05-integration-future-interfaces.md)
- **Extensibility model**: [spec/06-extensibility-model.md](https://github.com/busdk/docs/blob/main/spec/06-extensibility-model.md)
- **Data directory layout**: [spec/07-data-directory-layout.md](https://github.com/busdk/docs/blob/main/spec/07-data-directory-layout.md)
- **Example end-to-end workflow**: [spec/08-example-workflow.md](https://github.com/busdk/docs/blob/main/spec/08-example-workflow.md)
- **References and external foundations**: [spec/09-references.md](https://github.com/busdk/docs/blob/main/spec/09-references.md)

