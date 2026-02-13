---
title: `currency` (invoice currency)
description: currency is the purchase invoice currency.
---

## `currency` (invoice currency)

`currency` is the purchase invoice currency. Even when most invoices are in EUR, explicit currency prevents silent assumptions and keeps payables reporting, exports, and review workflows safe when foreign invoices occur.

When currency is explicit, bank matching and totals validation can be interpreted consistently without additional context.

Example values: `EUR`, `SEK`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./total-sum-including-vat">total_sum_including_vat</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./service-start-date">service_start_date</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

