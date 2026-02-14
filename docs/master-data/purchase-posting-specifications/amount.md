---
title: "`amount` (posted amount)"
description: amount is the amount intended to be posted for this purchase line.
---

## `amount` (posted amount)

`amount` is the amount intended to be posted for this purchase line. Bookkeeping needs line amounts to be explicit and stable for audit and export purposes, especially when an invoice is split across multiple accounts.

When amounts are recorded per posting line, reviewers can validate the split without reconstructing it from PDF annotations.

Example values: `1000.00`, `79.90`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ledger-account-id">ledger_account_id</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Purchase posting specifications</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./description">description</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Record purchase journal transaction](../../workflow/record-purchase-journal-transaction)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

