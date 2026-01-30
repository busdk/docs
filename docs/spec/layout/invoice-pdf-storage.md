# Invoice PDF storage

An optional `invoices/pdf/` area stores generated invoice PDFs named by invoice number such as `INV-1001.pdf`. Storing PDFs in Git is supported for completeness even though diffs for binaries are not meaningful; repository size concerns may cause users to store PDFs outside Git, but the default encourages “everything together” for audit completeness. Where long-term preservation is desired, PDF/A should be used for generated invoices. ([The Library of Congress](https://www.loc.gov/preservation/digital/formats/fdd/fdd000318.shtml?utm_source=chatgpt.com))

When PDFs are stored outside Git, BusDK MUST still preserve attachment metadata and stable references so that vouchers and postings can be verified. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
**Prev:** [Budgeting area](./budget-area) · **Next:** [Invoices area (headers and lines)](./invoices-area)
<!-- busdk-docs-nav end -->
