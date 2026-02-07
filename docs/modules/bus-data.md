## bus-data

Bus Data provides the shared tabular data layer for BusDK by implementing schema-validated dataset I/O and validation for workspace datasets (CSV plus Table Schema by default). It is a module with a thin CLI wrapper, but its primary surface is a Go library that other modules import directly for deterministic table and schema handling.

### How to run

Run `bus data` ... and use `--help` for available subcommands and arguments. The CLI is primarily a wrapper over the Go library, and internal module integrations must import the library rather than shelling out to `bus data`.

### Subcommands

The CLI is intentionally minimal and focuses on inspection and safe operations such as schema inspection and validation. Domain-level edits belong to the owning domain modules rather than to `bus data`.

### Data it reads and writes

It operates on workspace datasets and beside-the-table schemas (CSV plus Table Schema by default). It may update schema files and table files only when explicitly instructed, but it does not own domain datasets and does not enforce domain invariants.

### Outputs and side effects

It emits deterministic ordering and serialization for tables and schemas, performs schema-valid writes, and refuses invalid writes. It does not perform network or Git operations.

### Finnish compliance responsibilities

Bus Data supports compliance by enforcing schema-driven correctness, deterministic formatting, and audit-trail friendly behavior (including avoiding silent destructive updates), but it does not make discretionary accounting judgments and it does not replace domain validation.

### Integrations

All Go modules that touch tabular data should import the Bus Data Go library for mechanical table, schema, and store behavior. This reduces duplication while preserving dataset-based integration boundaries.

### See also

Repository: https://github.com/busdk/bus-data

For the storage backend boundary and repository rules that the library implements, see [Storage backends and workspace store interface](../data/storage-backends) and [Module repository structure and dependency rules](../implementation/module-repository-structure).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-init">bus-init</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-accounts">bus-accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
