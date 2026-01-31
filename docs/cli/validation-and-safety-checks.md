## Validation and safety checks

Before any data mutation, the CLI performs schema validation and logical validation. Schema validation ensures type correctness and referential integrity. Logical validation enforces business rules such as existing account references, balanced debits and credits for transactions, invoice totals matching line items, and VAT classification completeness when generating VAT reports. If errors are found, the command fails with a clear diagnostic and refuses to commit invalid data.

For Finnish compliance, validation MUST also enforce audit-trail invariants (stable IDs, required voucher references, deterministic ordering fields) and must prevent changes that would break a closed period or previously reported data. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./reporting-and-queries">Reporting and query commands</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../workflow/index">BusDK Design Spec: Example end-to-end workflow</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
