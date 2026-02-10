## `vat_percent` (applied VAT percentage)

`vat_percent` is the VAT percentage applied to the invoice row. Bookkeeping requires the applied VAT percentage to be explicit at line level because VAT can differ by item and can change over time.

When VAT percentage is explicit, VAT reporting and validation can be deterministic without re-interpreting free-text descriptions.

BusDK examples use the current Finnish VAT rate set as the canonical sample values: `25.5`, `13.5`, `10`, `0`.

Older Finnish rates such as `24` and `14` can still appear in historical invoice rows and must remain valid as data, but they should not be treated as defaults for new invoices.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./discount-percent">discount_percent</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Sales invoice rows</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ledger-account-id">ledger_account_id</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Invoice ledger impact](../../workflow/invoice-ledger-impact)
- [Create sales invoice](../../workflow/create-sales-invoice)

