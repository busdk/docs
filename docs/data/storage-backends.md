## Storage backends and workspace store interface

BusDK defines the workspace store (storage backend) interface as the boundary between domain modules and persistence. The contract is mechanical: the backend reads and writes deterministic tables plus schemas, enforces schema-valid writes, and provides canonical import and export back to the tabular text conventions. Modules own business rules and invariants; the backend only persists the canonical dataset and schema definitions and exposes them through deterministic ordering and validation preconditions. This separation ensures that datasets remain reviewable and exportable regardless of whether the default filesystem backend or a future SQL-backed implementation is used.

The default backend is a local filesystem repository that stores datasets as UTF-8 CSV tables with beside-the-table Table Schemas. This is an implementation choice, not the definition of the goal, and it remains the preferred default because it keeps the workspace datasets and change history transparent. Alternative backends are allowed if they preserve determinism, auditability, schema semantics, and canonical export and import to the CSV plus Table Schema contract. If a backend stores data in a non-file system, it must still produce the same tabular representation and schema metadata so that reviews, audits, and cross-language tooling remain possible without hidden dependencies.

Storage backends must respect append-only and audit-trail expectations by refusing destructive changes or representing corrections explicitly, but the policy decisions belong to domain modules. The backend provides deterministic record ordering and explicit schema enforcement so the modules can apply their business rules in a consistent, reviewable way. This keeps generic CRUD tooling optional and prevents it from becoming a required internal API.

When modules are implemented in Go, a shared library implementation of the workspace store interface is allowed and recommended to keep behavior consistent. Cross-language interoperability is still guaranteed by the table-and-schema contract and by the requirement that any non-file backend can export and import the canonical CSV plus schema form.

Repository layout and dependency rules remain separate from the storage interface: modules must not depend on invoking other `bus-*` CLIs as internal APIs, and shared implementation is limited to mechanical libraries like the workspace store. The canonical repository structure and dependency rules are defined in [Module repository structure and dependency rules](../implementation/module-repository-structure).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./csv-conventions">CSV conventions</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./data-package-organization">Data Package organization</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
