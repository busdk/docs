## `vat_deductible_percent` (VAT deductibility, when relevant)

`vat_deductible_percent` records how much of the input VAT is deductible when a bank transaction is booked as a purchase-like event directly from the statement. Bookkeeping uses it to compute deductible VAT deterministically and to separate non-deductible portions without manual spreadsheets.

This uses the same value set as [`vat_deductible_percent` in VAT treatment](../vat-treatment/vat-deductible-percent).

Example values: `100`, `0`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./vat-treatment">vat_treatment</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./accounting-status">accounting_status</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)

