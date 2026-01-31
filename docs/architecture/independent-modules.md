## Independent modules (integration through shared datasets)

Modules are independent tools or services. Each functional area is a module: ledger, invoice, bank import, VAT, budget, and related features. Modules encapsulate their domain logic and do not call each other’s functions directly. Integration occurs through shared datasets. When the invoice module needs to produce ledger impact, it writes journal entries into the journal dataset through the same data layer conventions as the ledger module, rather than invoking ledger APIs. This keeps modules loosely coupled and allows modules to be implemented in different languages. For example, a Python component could generate PDFs while a Go component enforces ledger integrity, both interoperating through the same workspace datasets (tables plus schemas) tracked as repository data — often as CSV in a Git repository by default.

Modules can also compose through the command line in the same spirit as the [UNIX composability goal](../design-goals/unix-composability). When a tool needs business logic that belongs to another module, it should invoke that module’s CLI instead of re-implementing logic or reaching into that module’s data files. Direct data access is appropriate for pure data reads and writes that do not require that other module’s validation or behavior, but dependencies on business rules should go through the module’s command interface.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./git-backed-data-store">Git-backed data repository (the data store)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./shared-validation-layer">Shared validation layer (schema + logical validation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
