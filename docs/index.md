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
- [FAQ: what are `bus` and BusDK?](faq/index)
- [Purpose and scope](overview/purpose-and-scope)
- [Visual identity and branding on outputs](overview/visual-identity)
- [Design goals and requirements](design-goals/index)
- [Module CLI reference](modules/index)

### Principles

- [CLI-first interfaces](design-goals/cli-first)
- [Deterministic `.bus` command files](design-goals/deterministic-busfiles)
- [Modularity](design-goals/modularity)
- [Schema-driven contract](design-goals/schema-contract)
- [Git as source of truth](design-goals/git-as-source-of-truth)
- [Auditability and append-only](design-goals/append-only-auditability)

### Status

- [Module capabilities](modules/features)
- [Development cost summary](implementation/cost-summary)
- [BusDK module pricing](implementation/module-pricing)
- [Module CLI quickstart](modules/index)

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

- [Module capabilities](modules/features)

### Core commands

- `bus` ([CLI](modules/bus))
- `bus init` ([CLI](modules/bus-init))
- `bus config` ([CLI](modules/bus-config))
- `bus data` ([CLI](modules/bus-data))
- `bus preferences` ([CLI](modules/bus-preferences))
- `bus status` ([CLI](modules/bus-status))

### User interfaces

- `bus sheets` ([CLI](modules/bus-sheets))
- `bus books` ([CLI](modules/bus-books))
- `bus ui` ([CLI](modules/bus-ui))
- `bus portal` ([CLI](modules/bus-portal))

### Automation and integration

- `bus api` ([CLI](modules/bus-api))
- `bus api provider books` ([CLI](modules/bus-api-provider-books))
- `bus api provider data` ([CLI](modules/bus-api-provider-data))
- `bus api provider session` ([CLI](modules/bus-api-provider-session))
- `bus run` ([CLI](modules/bus-run))
- `bus agent` ([CLI](modules/bus-agent))
- `bus secrets` ([CLI](modules/bus-secrets))
- `bus dev` ([CLI](modules/bus-dev))
- `bus update` ([CLI](modules/bus-update))
- `bus shell` ([CLI](modules/bus-shell))
- `bus gateway` ([CLI](modules/bus-gateway))
- `bus factory` ([CLI](modules/bus-factory))
- `bus events` ([CLI](modules/bus-events))
- `bus faq` ([CLI](modules/bus-faq))
- `bus inspection` ([CLI](modules/bus-inspection))

### Ledger foundation

- `bus bfl` ([CLI](modules/bus-bfl))
- `bus ledger` ([CLI](modules/bus-ledger))
- `bus accounts` ([CLI](modules/bus-accounts))
- `bus entities` ([CLI](modules/bus-entities))
- `bus customers` ([CLI](modules/bus-customers))
- `bus vendors` ([CLI](modules/bus-vendors))
- `bus period` ([CLI](modules/bus-period))
- `bus balances` ([CLI](modules/bus-balances))

### Journal flow

- `bus journal` ([CLI](modules/bus-journal))
- `bus memo` ([CLI](modules/bus-memo))
- `bus invoices` ([CLI](modules/bus-invoices))
- `bus bank` ([CLI](modules/bus-bank))
- `bus reconcile` ([CLI](modules/bus-reconcile))
- `bus attachments` ([CLI](modules/bus-attachments))

### Assets and resources

- `bus assets` ([CLI](modules/bus-assets))
- `bus loans` ([CLI](modules/bus-loans))
- `bus inventory` ([CLI](modules/bus-inventory))
- `bus payroll` ([CLI](modules/bus-payroll))
- `bus budget` ([CLI](modules/bus-budget))

### Validation and reports

- `bus reports` ([CLI](modules/bus-reports))
- `bus replay` ([CLI](modules/bus-replay))
- `bus validate` ([CLI](modules/bus-validate))
- `bus vat` ([CLI](modules/bus-vat))
- `bus pdf` ([CLI](modules/bus-pdf))
- `bus filing` ([CLI](modules/bus-filing))

### Filing targets

- `bus filing prh` ([CLI](modules/bus-filing-prh))
- `bus filing vero` ([CLI](modules/bus-filing-vero))

The [module CLI reference](modules/index) covers every current top-level BusDK module in this superproject, including supporting tools that are not always part of the first bookkeeping workflow pass.

## Understand System Design {#understand-system-design}

### Design documents

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
