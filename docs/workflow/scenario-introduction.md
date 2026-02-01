## Scenario introduction

Consider Alice, a freelance consultant using BusDK to run bookkeeping in a dedicated repository workspace. She uses the `bus` dispatcher and a small set of focused modules (accounts, entities, journal, invoices, bank, reconcile, VAT, reports) to keep her CSV-based records validated, auditable, and reproducible, while handling version control operations outside BusDK.

In practice her workflow is a small sequence of repeatable module commands that produce and validate repository data:

1. She bootstraps the workspace datasets and schemas:

```bash
bus init
```

2. She configures master data such as the chart of accounts:

```bash
bus accounts add ...
```

3. She records day-to-day activity using subledger commands and append-only journal postings:

```bash
bus invoices create --type sales
bus journal add ...
```

4. She imports evidence such as bank statements, then records the ledger impact explicitly:

```bash
bus bank import --file 2026/bank-statements/202602-bank-statement.csv
bus journal add ...
```

5. She closes reporting periods by computing VAT and producing report outputs:

```bash
bus vat report ...
bus reports trial-balance ...
```

The full, module-level flow is summarized in `workflow/accounting-workflow-overview.md`, and the rest of this section walks through concrete examples of how the pieces fit together.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./record-purchase-journal-transaction">Record a purchase as a journal transaction</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./vat-reporting-and-payment">VAT reporting and payment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
