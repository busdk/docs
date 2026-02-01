## Record a purchase as a journal transaction

When she buys a new laptop for work, she records the transaction as a double-entry journal record that credits Cash and debits an equipment-related expense or asset account. She runs:

```bash
bus journal record --date 2026-01-10 \
--desc "Bought new laptop" \
--debit "Office Equipment"=2500 \
--credit "Cash"=2500
```

The command generates two ledger rows in `2026/journals/2026-journal.csv`, linking them with a shared transaction ID. The CLI ensures the debits equal the credits and rejects unknown account names. If the repository did not yet have a 2026 journal file, the tool also updates `journals.csv` so the new file is discoverable and unambiguous. On success, the change is committed via external Git tooling with a message such as “Record transaction: 2026-01-10 Bought new laptop €2,500.” This makes it difficult to accidentally record only half of a double-entry transaction, supporting reliable bookkeeping.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./invoice-ledger-impact">Invoice ledger impact (integration through journal entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./scenario-introduction">Scenario introduction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
