---
layout: home
show_nav_cards: false
home_grid_blocks: true
title: BusDK Docs
description: Documentation hub for humans and AI agents using the Business Development Kit to run a business — workflows, CLI modules, design documents, data references, and compliance guidance.
---
## Understand BusDK Foundations

### Overview

- [Overview](overview/index)
- [Purpose and scope](overview/purpose-and-scope)
- [Visual identity and branding on outputs](overview/visual-identity)
- [Design goals and requirements](design-goals/index)
- [Implementation status](implementation/index)

### Principles

- [CLI-first interfaces](design-goals/cli-first)
- [Deterministic `.bus` command files](design-goals/deterministic-busfiles)
- [Modularity](design-goals/modularity)
- [Schema-driven contract](design-goals/schema-contract)
- [Git as source of truth](design-goals/git-as-source-of-truth)
- [Auditability and append-only](design-goals/append-only-auditability)

### Status

- [Development status](implementation/development-status)
- [Go optimization guide](implementation/go-optimization-guide)
- [Development cost summary](implementation/cost-summary)
- [BusDK module pricing](implementation/module-pricing)
- [Module repository structure](implementation/module-repository-structure)
- [Developer workflow](implementation/developer-module-workflow)
- [BusDK SDD (single page)](sdd)

## Follow Business Workflows {#follow-business-workflows}

### Workflow overview

- [End-to-end workflow](workflow/index)
- [Accounting workflow overview](workflow/accounting-workflow-overview)
- [Sale invoicing](workflow/sale-invoicing)
- [Scenario introduction](workflow/scenario-introduction)
- [CLI tooling and workflow](cli/index)

### Core flow

- [Initialize a new repository](workflow/initialize-repo)
- [Configure the chart of accounts](workflow/configure-chart-of-accounts)
- [Add a sales invoice](workflow/create-sales-invoice)
- [Invoice ledger impact](workflow/invoice-ledger-impact)
- [Record a purchase as a journal transaction](workflow/record-purchase-journal-transaction)

### Controls

- [Import bank transactions and apply payments](workflow/import-bank-transactions-and-apply-payment)
- [VAT reporting and payment](workflow/vat-reporting-and-payment)
- [Year-end close](workflow/year-end-close)
- [Generate invoice PDF and register attachment](workflow/generate-invoice-pdf-and-register-attachment)
- [Workflow takeaways](workflow/workflow-takeaways)

### Advanced

- [AI-assisted classification](workflow/ai-assisted-classification-review)
- [Codex-assisted accountant workflow](workflow/codex-accountant-workflow)
- [Budgeting and budget-vs-actual reporting](workflow/budgeting-and-budget-vs-actual)
- [Finnish payroll](workflow/finnish-payroll-monthly-pay-run)
- [Inventory valuation and COGS postings](workflow/inventory-valuation-and-cogs)
- [Workbook editing](workflow/workbook-and-validated-tabular-editing)

## Browse Modules by Task {#find-modules-by-task}

### Core commands

- `bus` ([CLI](modules/bus), [SDD](sdd/bus))
- `bus init` ([CLI](modules/bus-init), [SDD](sdd/bus-init))
- `bus config` ([CLI](modules/bus-config), [SDD](sdd/bus-config))
- `bus data` ([CLI](modules/bus-data), [SDD](sdd/bus-data))
- `bus preferences` ([CLI](modules/bus-preferences), [SDD](sdd/bus-preferences))

### User interfaces

- `bus sheets` ([CLI](modules/bus-sheets), [SDD](sdd/bus-sheets))
- `bus books` ([CLI](modules/bus-books), [SDD](sdd/bus-books))

### Automation and integration

- `bus api` ([CLI](modules/bus-api), [SDD](sdd/bus-api))
- `bus run` ([CLI](modules/bus-run), [SDD](sdd/bus-run))
- `bus agent` ([CLI](modules/bus-agent), [SDD](sdd/bus-agent))
- `bus secrets` ([CLI](modules/bus-secrets), [SDD](sdd/bus-secrets))
- `bus dev` ([CLI](modules/bus-dev), [SDD](sdd/bus-dev))

### Ledger foundation

- `bus bfl` ([CLI](modules/bus-bfl), [SDD](sdd/bus-bfl))
- `bus accounts` ([CLI](modules/bus-accounts), [SDD](sdd/bus-accounts))
- `bus entities` ([CLI](modules/bus-entities), [SDD](sdd/bus-entities))
- `bus period` ([CLI](modules/bus-period), [SDD](sdd/bus-period))
- `bus balances` ([CLI](modules/bus-balances), [SDD](sdd/bus-balances))

### Journal flow

- `bus journal` ([CLI](modules/bus-journal), [SDD](sdd/bus-journal))
- `bus invoices` ([CLI](modules/bus-invoices), [SDD](sdd/bus-invoices))
- `bus bank` ([CLI](modules/bus-bank), [SDD](sdd/bus-bank))
- `bus reconcile` ([CLI](modules/bus-reconcile), [SDD](sdd/bus-reconcile))
- `bus attachments` ([CLI](modules/bus-attachments), [SDD](sdd/bus-attachments))

### Assets and resources

- `bus assets` ([CLI](modules/bus-assets), [SDD](sdd/bus-assets))
- `bus loans` ([CLI](modules/bus-loans), [SDD](sdd/bus-loans))
- `bus inventory` ([CLI](modules/bus-inventory), [SDD](sdd/bus-inventory))
- `bus payroll` ([CLI](modules/bus-payroll), [SDD](sdd/bus-payroll))
- `bus budget` ([CLI](modules/bus-budget), [SDD](sdd/bus-budget))

### Validation and reports

- `bus reports` ([CLI](modules/bus-reports), [SDD](sdd/bus-reports))
- `bus replay` ([CLI](modules/bus-replay), [SDD](sdd/bus-replay))
- `bus validate` ([CLI](modules/bus-validate), [SDD](sdd/bus-validate))
- `bus vat` ([CLI](modules/bus-vat), [SDD](sdd/bus-vat))
- `bus pdf` ([CLI](modules/bus-pdf), [SDD](sdd/bus-pdf))
- `bus filing` ([CLI](modules/bus-filing), [SDD](sdd/bus-filing))

### Filing targets

- `bus filing prh` ([CLI](modules/bus-filing-prh), [SDD](sdd/bus-filing-prh))
- `bus filing vero` ([CLI](modules/bus-filing-vero), [SDD](sdd/bus-filing-vero))

## Understand System Design {#understand-system-design}

### Design documents

- [SDD index](sdd/index)
- [BusDK SDD](sdd)
- [Module SDDs](sdd/modules)
- [Independent modules](architecture/independent-modules)
- [Modularity](design-goals/modularity)

### Architecture

- [System architecture](architecture/index)
- [Architectural overview](architecture/architectural-overview)
- [Independent modules](architecture/independent-modules)
- [Workspace scope](architecture/workspace-scope-and-multi-workspace)
- [Shared validation layer](architecture/shared-validation-layer)

### Security and storage

- [Append-only and security](architecture/append-only-and-security)
- [CLI as the primary interface](architecture/cli-as-primary-interface)
- [Git-backed data repository](architecture/git-backed-data-store)
- [Data formats and storage](data/index)
- [Table Schema contract](data/table-schema-contract)

### Data evolution

- [Workspace configuration (datapackage.json)](data/workspace-configuration)
- [CSV conventions](data/csv-conventions)
- [Append-only updates and soft deletion](data/append-only-and-soft-deletion)
- [Schema evolution and migration](data/schema-evolution-and-migration)
- [Scaling over decades](data/scaling-over-decades)

### Workspace layout

- [Data directory layout](layout/index)
- [Layout principles](layout/layout-principles)
- [Workspace baseline](layout/minimal-workspace-baseline)
- [Minimal example layout](layout/minimal-example-layout)
- [Schemas beside datasets](layout/schemas-area)

### Layout areas

- [Accounts area](layout/accounts-area)
- [Invoices area](layout/invoices-area)
- [Journal area](layout/journal-area)
- [VAT area](layout/vat-area)
- [Budgeting area](layout/budget-area)

## Understand Data, Interfaces, and Compliance {#understand-data-interfaces-and-compliance}

### Master data

- [Master data (business objects)](master-data/index)
- [Accounting entity](master-data/accounting-entity/index)
- [Chart of accounts](master-data/chart-of-accounts/index)
- [Accounting periods](master-data/accounting-periods/index)
- [Bookkeeping status](master-data/workflow-metadata/index)

### Commercial and cash

- [Sales invoices](master-data/sales-invoices/index)
- [Purchase invoices](master-data/purchase-invoices/index)
- [Bank transactions](master-data/bank-transactions/index)
- [Reconciliations](master-data/reconciliations/index)
- [Evidence documents](master-data/documents/index)

### People, assets, and planning

- [Fixed assets](master-data/fixed-assets/index)
- [Loans](master-data/loans/index)
- [Employees](master-data/employees/index)
- [Inventory items](master-data/inventory-items/index)
- [Budgets](master-data/budgets/index)

### CLI behavior

- [CLI tooling (index)](cli/index)
- [Standard global flags](cli/global-flags)
- [`.bus` script files (writing and execution guide)](cli/bus-script-files)
- [CLI command naming](cli/command-naming)
- [Required command surface](cli/minimum-command-surface)
- [Validation and safety checks](cli/validation-and-safety-checks)

### Integration and quality

- [Integration and future interfaces](integration/index)
- [Extensibility model](extensibility/index)
- [Testing](testing/index)
- [References](references/index)
- [Sources](references/link-list)

### Compliance

- [Finnish bookkeeping and tax-audit compliance](compliance/fi-bookkeeping-and-tax-audit)
- [Finnish company reorganisation evidence pack](compliance/fi-company-reorganisation-evidence-pack)

### Sources

- [Overview](./overview/index)
- [Module CLI reference](./modules/index)
- [Workflow examples](./workflow/index)
