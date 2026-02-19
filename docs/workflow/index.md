---
title: Example end-to-end workflow
description: Workflow section of the BusDK design spec — accounting workflow, scenarios, and step-by-step guides.
---

## BusDK Design Spec: Example end-to-end workflow

This section is split into single-concept documents. Each page is written as a small, ordered sequence so that the relevant `bus <module> <subcommand>` invocations and their typical order are easy to scan.

The recommended reading order is:

1. [Accounting workflow overview](./accounting-workflow-overview)
2. [Sale invoicing (sending invoices to customers)](./sale-invoicing)
3. [Scenario introduction](./scenario-introduction)
4. [Initialize a new repository](./initialize-repo)
5. [Configure the chart of accounts](./configure-chart-of-accounts)
6. [Add a sales invoice (interactive workflow)](./create-sales-invoice)
7. [Invoice ledger impact (integration through journal entries)](./invoice-ledger-impact)
8. [Record a purchase as a journal transaction](./record-purchase-journal-transaction)
9. [Import bank transactions and apply payments](./import-bank-transactions-and-apply-payment)
10. [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)
11. [Import ERP history into canonical invoices and bank datasets](./import-erp-history-into-canonical-datasets)
12. [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks)
13. [AI-assisted classification (review before recording a revision)](./ai-assisted-classification-review)
14. [Budgeting and budget-vs-actual reporting](./budgeting-and-budget-vs-actual)
15. [VAT reporting and payment](./vat-reporting-and-payment)
16. [Year-end close (closing entries)](./year-end-close)
17. [Finnish payroll handling (monthly pay run)](./finnish-payroll-monthly-pay-run)
18. [Inventory valuation and COGS postings](./inventory-valuation-and-cogs)
19. [Workbook and validated tabular editing](./workbook-and-validated-tabular-editing)
20. [Evolution over time (extending the model)](./evolution-over-time)
21. [Workflow takeaways (transparency, control, automation)](./workflow-takeaways)

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../cli/validation-and-safety-checks">Validation and safety checks</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./accounting-workflow-overview">Accounting workflow overview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Accounting workflow overview](./accounting-workflow-overview)
- [Import bank transactions and apply payments](./import-bank-transactions-and-apply-payment)
- [Deterministic reconciliation proposals and batch apply](./deterministic-reconciliation-proposals-and-batch-apply)
- [Import ERP history into canonical invoices and bank datasets](./import-erp-history-into-canonical-datasets)
- [Source import parity and journal gap checks](./source-import-parity-and-journal-gap-checks)
