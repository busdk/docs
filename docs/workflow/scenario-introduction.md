## Scenario introduction

Consider Alice, a freelance consultant using BusDK to run bookkeeping in a dedicated Git repository. She uses the `bus` dispatcher and a small set of focused modules (accounts, entities, journal, invoices, bank, reconcile, VAT, reports) to keep her CSV-based records validated, auditable, and reproducible, while handling Git operations outside BusDK.

The full, module-level flow is summarized in `workflow/accounting-workflow-overview.md`, and the rest of this section walks through concrete examples of how the pieces fit together.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./record-purchase-journal-transaction">Record a purchase as a journal transaction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-reporting-and-payment">VAT reporting and payment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
