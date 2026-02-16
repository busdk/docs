---
layout: home
show_nav_cards: false
home_grid_blocks: true
title: BusDK Docs
description: Design and reference documentation for the BusDK toolkit — modular CLI, workspace datasets, workflows, modules, and compliance.
---

## Get started

### Orientation

- [Overview](overview/index)
- [Purpose and scope](overview/purpose-and-scope)
- [Visual identity and branding on outputs](overview/visual-identity)
- [Design goals and requirements](design-goals/index)
- [Implementation and development status](implementation/index)

### Design foundations

- [CLI-first and human-friendly interfaces](design-goals/cli-first)
- [Modularity as a first-class requirement](design-goals/modularity)
- [Schema-driven data contract (Frictionless Table Schema)](design-goals/schema-contract)
- [Git as the canonical, append-only source of truth](design-goals/git-as-source-of-truth)
- [Auditability and append-only discipline](design-goals/append-only-auditability)

### Delivery and progress

- [Development status](implementation/development-status)
- [Cost summary](implementation/cost-summary)
- [Module repository structure and dependency rules](implementation/module-repository-structure)
- [Developer module workflow](implementation/developer-module-workflow)
- [BusDK Software Design Document (single-page SDD)](sdd)

## Workflows

### Workflow hubs

- [Example end-to-end workflow](workflow/index)
- [Accounting workflow overview](workflow/accounting-workflow-overview)
- [Sale invoicing (sending invoices to customers)](workflow/sale-invoicing)
- [Scenario introduction](workflow/scenario-introduction)
- [CLI tooling and workflow](cli/index)

### Core bookkeeping flow

- [Initialize a new repository](workflow/initialize-repo)
- [Configure the chart of accounts](workflow/configure-chart-of-accounts)
- [Add a sales invoice (interactive workflow)](workflow/create-sales-invoice)
- [Invoice ledger impact](workflow/invoice-ledger-impact)
- [Record a purchase as a journal transaction](workflow/record-purchase-journal-transaction)

### Controls and period operations

- [Import bank transactions and apply payments](workflow/import-bank-transactions-and-apply-payment)
- [VAT reporting and payment](workflow/vat-reporting-and-payment)
- [Year-end close (closing entries)](workflow/year-end-close)
- [Generate invoice PDF and register attachment](workflow/generate-invoice-pdf-and-register-attachment)
- [Workflow takeaways](workflow/workflow-takeaways)

### Specialized operations

- [AI-assisted classification (review before recording)](workflow/ai-assisted-classification-review)
- [Budgeting and budget-vs-actual reporting](workflow/budgeting-and-budget-vs-actual)
- [Finnish payroll (monthly pay run)](workflow/finnish-payroll-monthly-pay-run)
- [Inventory valuation and COGS postings](workflow/inventory-valuation-and-cogs)
- [Workbook and validated tabular editing](workflow/workbook-and-validated-tabular-editing)

## Modules by use (CLI + SDD)

### Core command surface

- `bus` - [CLI](modules/bus) - [SDD](sdd/bus)
- `bus init` - [CLI](modules/bus-init) - [SDD](sdd/bus-init)
- `bus config` - [CLI](modules/bus-config) - [SDD](sdd/bus-config)
- `bus data` - [CLI](modules/bus-data) - [SDD](sdd/bus-data)
- `bus preferences` - [CLI](modules/bus-preferences) - [SDD](sdd/bus-preferences)

### Interfaces and automation tooling

- `bus api` - [CLI](modules/bus-api) - [SDD](sdd/bus-api)
- `bus sheets` - [CLI](modules/bus-sheets) - [SDD](sdd/bus-sheets)
- `bus run` - [CLI](modules/bus-run) - [SDD](sdd/bus-run)
- `bus agent` - [CLI](modules/bus-agent) - [SDD](sdd/bus-agent)
- `bus dev` - [CLI](modules/bus-dev) - [SDD](sdd/bus-dev)

### Formula and ledger foundation

- `bus bfl` - [CLI](modules/bus-bfl) - [SDD](sdd/bus-bfl)
- `bus accounts` - [CLI](modules/bus-accounts) - [SDD](sdd/bus-accounts)
- `bus entities` - [CLI](modules/bus-entities) - [SDD](sdd/bus-entities)
- `bus period` - [CLI](modules/bus-period) - [SDD](sdd/bus-period)
- `bus balances` - [CLI](modules/bus-balances) - [SDD](sdd/bus-balances)

### Journal and transaction flow

- `bus journal` - [CLI](modules/bus-journal) - [SDD](sdd/bus-journal)
- `bus invoices` - [CLI](modules/bus-invoices) - [SDD](sdd/bus-invoices)
- `bus bank` - [CLI](modules/bus-bank) - [SDD](sdd/bus-bank)
- `bus reconcile` - [CLI](modules/bus-reconcile) - [SDD](sdd/bus-reconcile)
- `bus attachments` - [CLI](modules/bus-attachments) - [SDD](sdd/bus-attachments)

### Asset and resource operations

- `bus assets` - [CLI](modules/bus-assets) - [SDD](sdd/bus-assets)
- `bus loans` - [CLI](modules/bus-loans) - [SDD](sdd/bus-loans)
- `bus inventory` - [CLI](modules/bus-inventory) - [SDD](sdd/bus-inventory)
- `bus payroll` - [CLI](modules/bus-payroll) - [SDD](sdd/bus-payroll)
- `bus budget` - [CLI](modules/bus-budget) - [SDD](sdd/bus-budget)

### Validation and reporting outputs

- `bus reports` - [CLI](modules/bus-reports) - [SDD](sdd/bus-reports)
- `bus validate` - [CLI](modules/bus-validate) - [SDD](sdd/bus-validate)
- `bus vat` - [CLI](modules/bus-vat) - [SDD](sdd/bus-vat)
- `bus pdf` - [CLI](modules/bus-pdf) - [SDD](sdd/bus-pdf)
- `bus filing` - [CLI](modules/bus-filing) - [SDD](sdd/bus-filing)

### Filing targets

- `bus filing prh` - [CLI](modules/bus-filing-prh) - [SDD](sdd/bus-filing-prh)
- `bus filing vero` - [CLI](modules/bus-filing-vero) - [SDD](sdd/bus-filing-vero)

## Design

### Software Design Documents

- [SDD index](sdd/index)
- [BusDK Software Design Document (single-page SDD)](sdd)
- [Module SDDs (list)](sdd/modules)
- [Independent modules](architecture/independent-modules)
- [Modularity as a first-class requirement](design-goals/modularity)

### Architecture and boundaries

- [System architecture](architecture/index)
- [Architectural overview](architecture/architectural-overview)
- [Independent modules](architecture/independent-modules)
- [Workspace scope and multi-workspace workflows](architecture/workspace-scope-and-multi-workspace)
- [Shared validation layer](architecture/shared-validation-layer)

### Security and storage model

- [Append-only discipline and security model](architecture/append-only-and-security)
- [CLI as the primary interface](architecture/cli-as-primary-interface)
- [Git-backed data repository](architecture/git-backed-data-store)
- [Data formats and storage](data/index)
- [Frictionless Table Schema as the contract](data/table-schema-contract)

### Data contracts over time

- [Workspace configuration (datapackage.json)](data/workspace-configuration)
- [CSV conventions](data/csv-conventions)
- [Append-only updates and soft deletion](data/append-only-and-soft-deletion)
- [Schema evolution and migration](data/schema-evolution-and-migration)
- [Scaling over decades](data/scaling-over-decades)

### Workspace layout

- [Data directory layout](layout/index)
- [Data directory layout (principles)](layout/layout-principles)
- [Minimal workspace baseline](layout/minimal-workspace-baseline)
- [Minimal example layout](layout/minimal-example-layout)
- [Schemas beside datasets](layout/schemas-area)

### Operational layout areas

- [Accounts area](layout/accounts-area)
- [Invoices area](layout/invoices-area)
- [Journal area](layout/journal-area)
- [VAT area](layout/vat-area)
- [Budgeting area](layout/budget-area)

## Reference

### Master data hubs

- [Master data (business objects)](master-data/index)
- [Accounting entity](master-data/accounting-entity/index)
- [Chart of accounts](master-data/chart-of-accounts/index)
- [Accounting periods](master-data/accounting-periods/index)
- [Bookkeeping status and review workflow](master-data/workflow-metadata/index)

### Commercial and cash records

- [Sales invoices](master-data/sales-invoices/index)
- [Purchase invoices](master-data/purchase-invoices/index)
- [Bank transactions](master-data/bank-transactions/index)
- [Reconciliations](master-data/reconciliations/index)
- [Documents (evidence)](master-data/documents/index)

### People, assets, and planning records

- [Fixed assets](master-data/fixed-assets/index)
- [Loans](master-data/loans/index)
- [Employees](master-data/employees/index)
- [Inventory items](master-data/inventory-items/index)
- [Budgets](master-data/budgets/index)

### CLI behavior and command contracts

- [CLI tooling (index)](cli/index)
- [Standard global flags](cli/global-flags)
- [CLI command naming](cli/command-naming)
- [Minimum required command surface](cli/minimum-command-surface)
- [Validation and safety checks](cli/validation-and-safety-checks)

### Integration, extensibility, and quality

- [Integration and future interfaces](integration/index)
- [Extensibility model](extensibility/index)
- [Testing](testing/index)
- [References and external foundations](references/index)
- [Sources](references/link-list)

### Compliance and regulatory context

- [Finnish bookkeeping and tax-audit compliance](compliance/fi-bookkeeping-and-tax-audit)
- [Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack](compliance/fi-company-reorganisation-evidence-pack)

