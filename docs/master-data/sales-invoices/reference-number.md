---
title: `reference_number` (payment matching key)
description: reference_number is the payment reference used for matching incoming bank payments to the invoice.
---

## `reference_number` (payment matching key)

`reference_number` is the payment reference used for matching incoming bank payments to the invoice. In Finnish banking, reference numbers are one of the strongest keys for deterministic matching.

Keeping reference numbers as a clean, dedicated field directly improves reconciliation automation and reduces manual matching work.

Example values: `1234567890`, `2026000123`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./duedate">duedate</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./currency">currency</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Create sales invoice](../../workflow/create-sales-invoice)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Generate invoice PDF and register attachment](../../workflow/generate-invoice-pdf-and-register-attachment)

