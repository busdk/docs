# Modularity as a first-class requirement

BusDK is modular from the start. Each major feature area is implemented as an independent module that operates on the workspace datasets through a shared schema-driven data contract, rather than through tight code coupling. The ledger, invoicing, VAT and tax reporting, bank import, budgeting, and document generation workflows must be able to evolve independently while still producing coherent repository data.

Modules interoperate through tables and schemas — not through internal function calls or private module-to-module APIs. This keeps boundaries explicit in the repository data, reduces integration risk, and makes it practical to add, replace, or omit modules without requiring a synchronized release train across the whole system.

A particular packaging model for modules (separate executables, subcommands of a single CLI, or a plugin system) is an implementation choice, not the definition of the goal. The invariant is that the workspace datasets and their change history remain reviewable and exportable, and that module interoperability is defined by the schema contract rather than by shared code.

---

<!-- busdk-docs-nav start -->
**Prev:** [Git as the canonical, append-only source of truth](./git-as-source-of-truth) · **Index:** [BusDK Design Document](../../index) · **Next:** [Plain-text CSV for longevity](./plaintext-csv-longevity)
<!-- busdk-docs-nav end -->
