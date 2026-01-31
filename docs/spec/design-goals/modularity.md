## Modularity as a first-class requirement

BusDK is modular from the start. Each major feature area is implemented as an independent module that operates on the workspace datasets through a shared schema-driven data contract, rather than through tight code coupling. The ledger, invoicing, VAT and tax reporting, bank import, budgeting, and document generation workflows must be able to evolve independently while still producing coherent repository data.

Modules interoperate through tables and schemas — not through internal function calls or private module-to-module APIs. This keeps boundaries explicit in the repository data, reduces integration risk, and makes it practical to add, replace, or omit modules without requiring a synchronized release train across the whole system.

Modularity is also required inside each module. A module’s domain logic should depend on stable interfaces for reading and writing tabular data and for validating it against the schema contract, while file formats and persistence details remain swappable implementations. This keeps the module’s behavior defined in terms of tables, schemas, and deterministic transformations of workspace data — not in terms of “CSV files on disk” — and it enables alternative backends (for example a SQL store) without rewriting module logic or changing the interoperability contract described in [Schema-driven data contract (Frictionless Table Schema)](./schema-contract), [Plain-text CSV for longevity](./plaintext-csv-longevity), and [Git as the canonical, append-only source of truth](./git-as-source-of-truth).

A particular packaging model for modules (separate executables, subcommands of a single CLI, or a plugin system) is an implementation choice, not the definition of the goal. The invariant is that the workspace datasets and their change history remain reviewable and exportable, and that module interoperability is defined by the schema contract rather than by shared code.

---

<!-- busdk-docs-nav start -->
**Prev:** [Git as the canonical, append-only source of truth](./git-as-source-of-truth) · **Index:** [BusDK Design Spec: Design goals and requirements](./) · **Next:** [Plain-text CSV for longevity](./plaintext-csv-longevity)
<!-- busdk-docs-nav end -->
