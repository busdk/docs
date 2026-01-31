## Invoice ledger impact (integration through journal entries)

For integration convenience, the invoice module can also write the corresponding ledger impact automatically by appending journal lines that debit Accounts Receivable €1240, credit Consulting Revenue €1000, and credit VAT Payable €240, optionally tagging the transaction with invoice number for traceability. This integration is accomplished by writing to the shared journal dataset rather than calling ledger internals.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./initialize-repo">Initialize a new repository</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./record-purchase-journal-transaction">Record a purchase as a journal transaction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
