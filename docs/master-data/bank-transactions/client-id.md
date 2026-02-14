---
title: "`client_id` (party link, customer-side)"
description: client_id links a bank transaction to a customer party when the transaction relates to that party but is not necessarily tied to a specific invoice.
---

## `client_id` (party link, customer-side)

`client_id` links a bank transaction to a customer party when the transaction relates to that party but is not necessarily tied to a specific invoice. Bookkeeping uses party links for review, rule-based classification, and reporting, especially for non-invoice transactions.

Example values: `client-001`, `client-042`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./matched-purchase-invoice-id">matched_purchase_invoice_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./purchase-company-id">purchase_company_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)

