---
title: Independent modules (integration through shared datasets)
description: BusDK modules are independent tools; integration is through shared datasets and schemas so components can be in different languages without API coupling.
---

## Independent modules (integration through shared datasets)

Modules are independent tools or services. Each functional area is a module: ledger, invoice, bank import, VAT, budget, and related features. Modules encapsulate their domain logic and do not call each other’s functions directly. Integration occurs through shared datasets and schemas so that modules can be implemented in different languages without API coupling. For example, a Python component can generate PDFs while a Go component enforces ledger integrity, and both interoperate through the same workspace datasets tracked as repository data — often as CSV in a Git repository by default.

CLI-to-CLI dependency is not an integration mechanism. Modules must not invoke other `bus-*` CLIs as internal dependencies, and the `bus` dispatcher provides a unified UX without turning module CLIs into internal APIs. The canonical repository layout and dependency rules are defined in [Module repository structure and dependency rules](../implementation/module-repository-structure).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./git-backed-data-store">Git-backed data repository (the data store)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./shared-validation-layer">Shared validation layer (schema + logical validation)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
