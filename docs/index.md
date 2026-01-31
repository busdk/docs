# BusDK Design Document

BusDK is a modular, CLI-first toolkit for running a business, built on open, long-lived formats and transparent, auditable workflows. The preferred default is that workspaces live in Git repositories and business data is stored as UTF-8 CSV datasets validated with Frictionless Data Table Schemas (JSON), but Git and CSV are implementation choices: the goal is that the workspace datasets and their change history remain reviewable and exportable. The system favors deterministic workflows that work for both humans and AI agents. See [busdk.com](https://busdk.com/) for a high-level overview.

Status: pre-release, under active development. Interfaces and schemas may still change.

## Accounting workflow

BusDK is designed for year-round bookkeeping in a dedicated repository workspace. The preferred default is a Git repository where the workspace datasets are stored as UTF-8 CSV validated by Frictionless Table Schemas, and every data change is committed alongside its supporting evidence. The core dispatcher is [`bus`](https://github.com/busdk/bus) and the workflow below reflects the current set of planned modules in the BusDK org.

The per-module reference pages are collected in the [Modules index](./modules/).

- Set up a Git repository for the bookkeeping year and install `bus` plus the module binaries you will use.
- Define master data: chart of accounts with [`bus accounts`](./modules/bus-accounts), counterparties with [`bus entities`](./modules/bus-entities), and periods with [`bus period`](./modules/bus-period).
- Treat evidence as data: archive invoices, receipts, VAT exports, and bank files with [`bus attachments`](./modules/bus-attachments) and reference those IDs from other records.
- Record activity: invoices with [`bus invoices`](./modules/bus-invoices), ledger postings with [`bus journal`](./modules/bus-journal), assets with [`bus assets`](./modules/bus-assets), and loans with [`bus loans`](./modules/bus-loans) as they occur.
- Reconcile regularly: import bank feeds with [`bus bank`](./modules/bus-bank), match and reconcile with [`bus reconcile`](./modules/bus-reconcile), then fill gaps via [`bus invoices`](./modules/bus-invoices) or [`bus journal`](./modules/bus-journal).
- Close each period: validate with [`bus validate`](./modules/bus-validate), compute VAT with [`bus vat`](./modules/bus-vat), lock with [`bus period`](./modules/bus-period), and generate reports with [`bus reports`](./modules/bus-reports).
- At year end, repeat the close flow, ensure assets and VAT are complete, and tag the final revision.

The loan register supports portfolio reporting for applications and special situations like corporate restructuring, business reorganisation, debt adjustment, or debt restructuring.

For the full narrative, see [Accounting workflow overview](spec/workflow/accounting-workflow-overview).

## Spec index

- [Overview](spec/overview/)
- [Design goals and requirements](spec/design-goals/)
- [System architecture](spec/architecture/)
- [Data formats and storage](spec/data/)
- [Data directory layout](spec/layout/)
- [CLI tooling and workflow](spec/cli/)
- [Example end-to-end workflow](spec/workflow/)
- [Modules](./modules/)
- [Integration and future interfaces](spec/integration/)
- [Extensibility model](spec/extensibility/)
- [Finnish bookkeeping and tax-audit compliance](spec/compliance/fi-bookkeeping-and-tax-audit)
- [References and external foundations](spec/references/)

---

<!-- busdk-docs-nav start -->
**Prev:** — · **Index:** [BusDK Design Document](./index) · **Next:** [BusDK Design Spec: Overview](./spec/overview/)
<!-- busdk-docs-nav end -->
