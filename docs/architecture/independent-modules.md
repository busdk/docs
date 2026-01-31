## Independent modules (integration through shared datasets)

Modules are independent tools or services. Each functional area is a module: ledger, invoice, bank import, VAT, budget, and related features. Modules encapsulate their domain logic and do not call each other’s functions directly. Integration occurs through shared datasets. When the invoice module needs to produce ledger impact, it should request journal entries through the journal module’s command interface rather than writing to the journal dataset directly or invoking ledger APIs. This keeps modules loosely coupled and allows modules to be implemented in different languages. For example, a Python component could generate PDFs while a Go component enforces ledger integrity, both interoperating through the same workspace datasets (tables plus schemas) tracked as repository data — often as CSV in a Git repository by default.

Modules can also compose through the command line in the same spirit as the [UNIX composability goal](../design-goals/unix-composability). When a tool needs business logic that belongs to another module, it should invoke that module’s CLI instead of re-implementing logic or reaching into that module’s data files. Direct data access is appropriate for read-only use, but the ownership of a dataset belongs to the module that defines it, so writes and changes should go through the owning module’s command interface, including any validation or domain rules it enforces.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./git-backed-data-store">Git-backed data repository (the data store)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./shared-validation-layer">Shared validation layer (schema + logical validation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
