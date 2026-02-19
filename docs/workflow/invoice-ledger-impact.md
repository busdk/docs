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
bus invoices add --type sales --invoice-id INV-1001 --invoice-date 2026-02-14 --due-date 2026-03-14 --customer "Acme Oy"
bus invoices INV-1001 add --desc "Consulting" --quantity 1 --unit-price 100 --income-account 3000 --vat-rate 25.5
bus invoices postings
```

3. If the pinned module version is configured to produce postings, it appends the corresponding journal impact as part of the same user-level operation, for example debiting Accounts Receivable €1255, crediting Consulting Income €1000, and crediting VAT Payable €255. The important detail is that the integration happens by writing journal rows in the shared journal dataset, tagged with the invoice identifier for traceability.

4. Alice verifies the posting result from the journal side:

```bash
bus reports trial-balance --as-of 2026-02-28
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./initialize-repo">Initialize a new repository</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./record-purchase-journal-transaction">Record a purchase as a journal transaction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-invoices module CLI reference](../modules/bus-invoices)
- [bus-journal module CLI reference](../modules/bus-journal)
- [bus-reports module CLI reference](../modules/bus-reports)
