## Invoice PDF storage

An optional `invoices/pdf/` area stores generated invoice PDFs named by invoice number such as `INV-1001.pdf`. Storing PDFs in Git is supported for completeness even though diffs for binaries are not meaningful; repository size concerns may cause users to store PDFs outside Git, but the default encourages “everything together” for audit completeness. Where long-term preservation is desired, PDF/A should be used for generated invoices (see [PDF/A Family, PDF for Long-term Preservation (Library of Congress)](https://www.loc.gov/preservation/digital/formats/fdd/fdd000318.shtml)).

When PDFs are stored outside Git, BusDK MUST still preserve attachment metadata and stable references so that vouchers and postings can be verified. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./budget-area">Budgeting area</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./invoices-area">Invoices area (headers and lines)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
