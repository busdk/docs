---
title: Shared validation layer (schema + logical validation)
description: A shared validation layer is foundational.
---

## Shared validation layer (schema + logical validation)

A shared validation layer is foundational. Each module relies on schema validation and logical validation before accepting a mutation. Schema validation checks types and constraints such as required fields, formats, keys, and referential integrity. Logical validation enforces accounting rules such as balanced double-entry transactions and consistency of invoice totals. Schema compliance is standardized through the schema contract described in [Schema-driven data contract (Frictionless Table Schema)](../design-goals/schema-contract) and expressed using [Frictionless Data Table Schema](https://frictionlessdata.io/specs/table-schema/). Logical validation is implemented in module logic, particularly where cross-row invariants are required (for example, “sum of debits equals sum of credits for a transaction group”).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./independent-modules">Independent modules (integration through shared datasets)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">BusDK Design Spec: Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
