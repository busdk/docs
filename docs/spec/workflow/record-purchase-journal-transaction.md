# Record a purchase as a journal transaction

When she buys a new laptop for work, she records the transaction as a double-entry journal record that credits Cash and debits an equipment-related expense or asset account. She runs:

```bash
busdk journal record --date 2026-01-10 \
--desc "Bought new laptop" \
--debit "Office Equipment"=2500 \
--credit "Cash"=2500
```

The command generates two ledger rows in `journal/journal_2026.csv`, linking them with a shared transaction ID. The CLI ensures the debits equal the credits and rejects unknown account names. On success, the change is committed via external Git tooling with a message such as “Record transaction: 2026-01-10 Bought new laptop €2,500.” This makes it difficult to accidentally record only half of a double-entry transaction, supporting reliable bookkeeping. ([docs.mypocketcfo.com](https://docs.mypocketcfo.com/article/131-accrual-based-accounting-method-and-its-double-entry-ledger-system?utm_source=chatgpt.com))

