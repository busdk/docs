## `group_id` (accounting entity key)

`group_id` identifies which accounting entity a record belongs to. It is the key that keeps journals, VAT, and reports separated per company or ledger so bookkeeping never mixes transactions across scopes.

Bookkeeping relies on this key being present anywhere you later generate postings, reconcile payments, or produce reports. Use it consistently on invoices, bank accounts, bank transactions, documents, and ledger postings so exports and audits can always be filtered and reconstructed per entity.

Example values: `acme-oy`, `company-123`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Accounting entity</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./base-currency">base_currency</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

