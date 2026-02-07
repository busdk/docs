## Import bank transactions and apply payments

When the customer pays, Alice imports the bank statement as evidence, identifies the payment transaction in the normalized bank dataset, and then records the ledger impact by appending an explicit journal entry. This keeps the workflow deterministic and reviewable while BusDK is still missing dedicated reconciliation logic.

1. Alice imports the raw bank statement evidence with Bus Bank:

```bash
bus bank import --file 202602-bank-statement.csv
```

Bus Bank writes schema-validated bank datasets and preserves source statement identifiers so each imported transaction remains traceable back to the original evidence.

2. Alice reviews the imported bank transactions and finds the February payment row that corresponds to invoice INV-1001:

```bash
bus bank list --month 2026-2
```

If the module supports filters, she narrows the output to the February date range or to rows that contain the invoice number or counterparty reference. The exact filtering flags are part of the module surface area, so she uses `bus bank list --help` to see what is available in her pinned version.

3. Alice identifies the accounts she will post against by listing the chart of accounts:

```bash
bus accounts list
```

For a simple incoming payment with no fees, she needs the bank asset account that received the money and the Accounts Receivable account used by the original invoice posting. In BusDK terms, the payment entry clears receivables rather than changing invoice rows in place.

4. Alice records the ledger impact as an append-only journal entry:

```bash
bus journal add --date 2026-02-14 \
--desc "Payment received for INV-1001 (bank statement 202602)" \
--debit "Bank"=1240 \
--credit "Accounts Receivable"=1240
```

The journal entry date comes from the bank transaction date, and the description carries the invoice number and enough evidence context to make later review straightforward. If a bank transaction identifier is available in the normalized bank dataset, Alice includes it in the description so the posting remains easy to trace back to the imported statement row.

If she is unsure about the available flags in her pinned version, she uses `bus journal add --help`.

5. Alice verifies the result by reviewing the bank list output and the resulting journal postings, then uses invoice listing as a cross-check:

```bash
bus invoices list
```

Until reconciliation is implemented as a first-class module, invoice “paid” status should be treated as a reporting convenience rather than the definition of correctness. The authoritative outcome is that the ledger is updated via an append-only journal entry whose provenance remains reviewable in the revision history.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./evolution-over-time">Evolution over time (extending the model)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./initialize-repo">Initialize a new repository</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
