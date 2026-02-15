---
title: Invoice ledger impact (integration through journal entries)
description: Invoices and the general ledger stay integrated by writing shared repository data rather than by calling hidden ledger internals.
---

## Invoice ledger impact (integration through journal entries)

Invoices and the general ledger stay integrated by writing shared repository data rather than by calling hidden ledger internals. When invoice posting integration is enabled, the invoice module expresses ledger impact by appending to the journal dataset as normal, reviewable records.

1. Alice ensures the required account references exist:

```bash
bus accounts list
```

2. Alice adds the invoice as stored invoice rows:

```bash
bus invoices add --help
bus invoices add --type sales
```

3. If the pinned module version is configured to produce postings, it appends the corresponding journal impact as part of the same user-level operation, for example debiting Accounts Receivable €1255, crediting Consulting Income €1000, and crediting VAT Payable €255. The important detail is that the integration happens by writing journal rows in the shared journal dataset, tagged with the invoice identifier for traceability.

4. Alice verifies the posting result from the journal side:

```bash
bus reports trial-balance --help
bus reports trial-balance ...
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./initialize-repo">Initialize a new repository</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./record-purchase-journal-transaction">Record a purchase as a journal transaction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
