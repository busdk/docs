---
title: "`accounting_note` (exception explanation)"
description: accounting_note records why a bank transaction was booked in a particular way when the decision is not obvious from the statement evidence alone.
---

## `accounting_note` (exception explanation)

`accounting_note` records why a bank transaction was booked in a particular way when the decision is not obvious from the statement evidence alone. Bookkeeping uses notes to make exceptions reproducible later, such as private portions, partial deductions, or settlement batches that required a manual split.

This is the same workflow field as [`accounting_note` in bookkeeping status and review workflow](../workflow-metadata/accounting-note).

Example values: `Bank fee — booked as expense.`, `Settlement batch — split across invoices.`.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./booked-by">booked_by</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Bank transactions</a></span>
  <span class="busdk-prev-next-item busdk-next">—</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Import bank transactions and apply payment](../../workflow/import-bank-transactions-and-apply-payment)
- [Reconcile bank transactions](../../modules/bus-reconcile)

