# Independent modules (integration through shared datasets)

Modules are independent tools or services. Each functional area is a module: ledger, invoice, bank import, VAT, budget, and related features. Modules encapsulate their domain logic and do not call each other’s functions directly. Integration occurs through shared datasets. When the invoice module needs to produce ledger impact, it writes journal entries into the journal dataset through the same data layer conventions as the ledger module, rather than invoking ledger APIs. This keeps modules loosely coupled and allows modules to be implemented in different languages. For example, a Python component could generate PDFs while a Go component enforces ledger integrity, both interoperating through CSV files in a Git-managed repository.

---

<!-- busdk-docs-nav start -->
**Prev:** [Git-backed data repository (the data store)](./git-backed-data-store) · **Index:** [BusDK Design Document](../../index) · **Next:** [Shared validation layer (schema + logical validation)](./shared-validation-layer)
<!-- busdk-docs-nav end -->
