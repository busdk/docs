## Independent modules (integration through shared datasets)

Modules are independent tools or services. Each functional area is a module: ledger, invoice, bank import, VAT, budget, and related features. Modules encapsulate their domain logic and do not call each other’s functions directly. Integration occurs through shared datasets. When the invoice module needs to produce ledger impact, it writes journal entries into the journal dataset through the same data layer conventions as the ledger module, rather than invoking ledger APIs. This keeps modules loosely coupled and allows modules to be implemented in different languages. For example, a Python component could generate PDFs while a Go component enforces ledger integrity, both interoperating through the same workspace datasets (tables plus schemas) tracked as repository data — often as CSV in a Git repository by default.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./git-backed-data-store">Git-backed data repository (the data store)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./shared-validation-layer">Shared validation layer (schema + logical validation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
