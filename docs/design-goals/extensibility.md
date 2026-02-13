---
title: Extensibility as a first-class goal
description: Extensibility is a first-class goal.
---

## Extensibility as a first-class goal

Extensibility is a first-class goal. The architecture must remain simple enough that a single developer can implement a new module over a weekend using common libraries, without rewriting or tightly coupling the core.

BusDK modules interoperate through shared tabular datasets: rows plus a schema-defined contract. Today, the preferred default representation is CSV tracked in Git for auditability and longevity, but storage is an implementation detail. The core must expose a storage interface that can be backed by multiple implementations over time (for example, CSV-on-disk, SQL databases, or spreadsheet-style formats), so modules can remain unaware of whether they are reading and writing “CSV” versus “SQL” while still behaving deterministically, consistent with [Modularity as a first-class requirement](./modularity) and [Schema-driven data contract (Frictionless Table Schema)](./schema-contract).

Extensibility applies within modules as well as between them. A module should present a small, stable surface area of internal interfaces around its core concepts (for example, “table access”, “schema validation”, and “record transformation”), and treat parsing, persistence, and transport as replaceable implementations behind those interfaces. This keeps “how the module works” tied to the schema contract and the meaning of the workspace datasets, rather than to a particular on-disk representation or versioning mechanism, consistent with [Git as the canonical, append-only source of truth](./git-as-source-of-truth), [Plain-text CSV for longevity](./plaintext-csv-longevity), and [Schema-driven data contract (Frictionless Table Schema)](./schema-contract).

The schema system is a core enabler of extensibility because it makes module interoperability a data contract rather than a code contract. BusDK follows the upstream Table Schema specification as closely as possible, and any BusDK-specific semantics are expressed as optional, namespaced extensions so that external tooling can still validate and process the tables. The detailed contract and extension rules are defined in [Schema-driven data contract (Frictionless Table Schema)](./schema-contract).

Shared implementation is allowed only for mechanical concerns such as the workspace store, schema parsing, and CSV handling, while interoperability remains defined by datasets and schemas, not by module-to-module APIs. CLI-to-CLI dependency is not an integration mechanism — the `bus` dispatcher provides a unified UX while modules remain independently implemented — and the canonical repository layout and dependency rules are defined in [Module repository structure and dependency rules](../implementation/module-repository-structure).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./double-entry-ledger">Double-entry ledger accounting</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./feature-scope">Initial feature scope (modules)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
