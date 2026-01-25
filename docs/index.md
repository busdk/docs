# BusDK Design Document

Modular CLI-First Business Development Toolkit (CSV + Frictionless Data + Git)

## Accounting workflow

BusDK is designed for year-round bookkeeping in a dedicated Git repo: CSV datasets are validated by Frictionless Table Schemas and every data change is committed alongside its supporting evidence. The core dispatcher is [`bus`](https://github.com/busdk/bus) and the workflow below reflects the current set of planned modules in the BusDK org.

- Set up a Git repository for the bookkeeping year and install `bus` plus the module binaries you will use.
- Define master data: chart of accounts with [`bus accounts`](https://github.com/busdk/bus-accounts), counterparties with [`bus entities`](https://github.com/busdk/bus-entities), and periods with [`bus period`](https://github.com/busdk/bus-period).
- Treat evidence as data: archive invoices, receipts, VAT exports, and bank files with [`bus attachments`](https://github.com/busdk/bus-attachments) and reference those IDs from other records.
- Record activity: invoices with [`bus invoices`](https://github.com/busdk/bus-invoices), ledger postings with [`bus journal`](https://github.com/busdk/bus-journal), and assets with [`bus assets`](https://github.com/busdk/bus-assets) as they occur.
- Reconcile regularly: import bank feeds with [`bus bank`](https://github.com/busdk/bus-bank), match and reconcile with [`bus reconcile`](https://github.com/busdk/bus-reconcile), then fill gaps via [`bus invoices`](https://github.com/busdk/bus-invoices) or [`bus journal`](https://github.com/busdk/bus-journal).
- Close each period: validate with [`bus validate`](https://github.com/busdk/bus-validate), compute VAT with [`bus vat`](https://github.com/busdk/bus-vat), lock with [`bus period`](https://github.com/busdk/bus-period), and generate reports with [`bus reports`](https://github.com/busdk/bus-reports).
- At year end, repeat the close flow, ensure assets and VAT are complete, and tag the final state.

For the full narrative, see [Accounting workflow overview](spec/workflow/accounting-workflow-overview).

## Spec index

- [Overview](spec/00-overview)
- [Design goals and requirements](spec/01-design-goals)
- [System architecture](spec/02-architecture)
- [Data formats and storage](spec/03-data-formats-and-storage)
- [CLI tooling and workflow](spec/04-cli-workflow)
- [Integration and future interfaces](spec/05-integration-future-interfaces)
- [Extensibility model](spec/06-extensibility-model)
- [Data directory layout](spec/07-data-directory-layout)
- [Example end-to-end workflow](spec/08-example-workflow)
- [References and external foundations](spec/09-references)

