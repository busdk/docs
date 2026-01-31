## Invoice ledger impact (integration through journal entries)

For integration convenience, the invoice module can also write the corresponding ledger impact automatically by appending journal lines that debit Accounts Receivable €1240, credit Consulting Revenue €1000, and credit VAT Payable €240, optionally tagging the transaction with invoice number for traceability. This integration is accomplished by writing to the shared journal dataset rather than calling ledger internals.

---

<!-- busdk-docs-nav start -->
**Prev:** [Initialize a new repository](./initialize-repo) · **Index:** [BusDK Design Document](../../index) · **Next:** [Record a purchase as a journal transaction](./record-purchase-journal-transaction)
<!-- busdk-docs-nav end -->
