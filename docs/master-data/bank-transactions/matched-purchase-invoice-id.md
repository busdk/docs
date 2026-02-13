---
title: `matched_purchase_invoice_id` (purchase invoice match)
description: matched_purchase_invoice_id links a bank transaction to a purchase invoice when the transaction represents payment of that vendor invoice.
---

## `matched_purchase_invoice_id` (purchase invoice match)

`matched_purchase_invoice_id` links a bank transaction to a purchase invoice when the transaction represents payment of that vendor invoice. Bookkeeping uses the link to make payables reconciliation near-automatic and to keep the audit trail navigable from cash movement to invoice evidence.

Example values: `PI-2026-000045`, `PI-2026-000046`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./matched-sale-invoice-id">matched_sale_invoice_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./client-id">client_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)

