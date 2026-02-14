---
title: "`vat_treatment` (VAT handling code, when relevant)"
description: vat_treatment records the VAT handling category when a bank transaction is booked as a purchase-like event directly from the statement.
---

## `vat_treatment` (VAT handling code, when relevant)

`vat_treatment` records the VAT handling category when a bank transaction is booked as a purchase-like event directly from the statement. Bookkeeping needs VAT handling to be explicit in these cases because there may be no separate purchase invoice flow to carry VAT metadata.

This uses the same value set as [`vat_treatment` in VAT treatment](../vat-treatment/vat-treatment).

Example values: `domestic_standard`, `reverse_charge`, `intra_eu_supply`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ledger-account-id">ledger_account_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-deductible-percent">vat_deductible_percent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)

