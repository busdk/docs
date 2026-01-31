# Extensibility as a first-class goal

Extensibility is a first-class goal. The architecture must remain simple enough that a single developer can implement a new module over a weekend using common libraries, without rewriting or tightly coupling the core.

BusDK modules interoperate through shared tabular datasets: rows plus a schema-defined contract. Today, the canonical storage is CSV files tracked in Git for auditability and longevity, but storage is an implementation detail. The core must expose a storage interface that can be backed by multiple implementations over time (for example, CSV-on-disk, SQL databases, or spreadsheet-style formats), so modules can remain unaware of whether they are reading and writing “CSV” versus “SQL” while still behaving deterministically.

Extensibility applies within modules as well as between them. A module should present a small, stable surface area of internal interfaces around its core concepts (for example, “table access”, “schema validation”, and “record transformation”), and treat parsing, persistence, and transport as replaceable implementations behind those interfaces. This keeps “how the module works” tied to the schema contract and the meaning of the workspace datasets, rather than to a particular on-disk representation or versioning mechanism, consistent with [Git as the canonical, append-only source of truth](./git-as-source-of-truth), [Plain-text CSV for longevity](./plaintext-csv-longevity), and [Schema-driven data contract (Frictionless Table Schema)](./schema-contract).

Schemas are expressed using [Frictionless Data Table Schema](https://frictionlessdata.io/specs/table-schema/) (JSON). BusDK follows the upstream specification as closely as possible; any BusDK-specific needs must be implemented as optional, namespaced extensions (for example, custom properties under a `busdk:*` key) that do not break compatibility with standard Table Schema tooling. In BusDK terms, the data contract is \((table, schema)\), not \((CSV, schema)\): CSV is the default representation today, not the definition of interoperability.

---

<!-- busdk-docs-nav start -->
**Prev:** [Double-entry ledger accounting](./double-entry-ledger) · **Index:** [BusDK Design Document](../../index) · **Next:** [Initial feature scope (modules)](./feature-scope)
<!-- busdk-docs-nav end -->
