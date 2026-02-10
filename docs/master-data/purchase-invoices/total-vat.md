## `total_vat` (invoice total VAT)

`total_vat` is the VAT total for the purchase invoice. Bookkeeping uses it for validation and for review of VAT deductibility and reporting expectations, especially when posting lines split the invoice across accounts.

An explicit VAT total makes “header vs lines vs payment” consistency checks straightforward.

Example values: `240.00`, `19.18`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./total-sum">total_sum</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase invoices</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./total-sum-including-vat">total_sum_including_vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

