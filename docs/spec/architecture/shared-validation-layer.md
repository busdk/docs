## Shared validation layer (schema + logical validation)

A shared validation layer is foundational. Each module relies on schema validation and logical validation before accepting a mutation. Schema validation checks types and constraints such as required fields, formats, keys, and referential integrity. Logical validation enforces accounting rules such as balanced double-entry transactions and consistency of invoice totals. Schema compliance is standardized through the schema contract described in [Schema-driven data contract (Frictionless Table Schema)](../design-goals/schema-contract) and expressed using [Frictionless Data Table Schema](https://frictionlessdata.io/specs/table-schema/). Logical validation is implemented in module logic, particularly where cross-row invariants are required (for example, “sum of debits equals sum of credits for a transaction group”).

---

<!-- busdk-docs-nav start -->
**Prev:** [Independent modules (integration through shared datasets)](./independent-modules) · **Index:** [BusDK Design Spec: System architecture](../architecture/) · **Next:** [BusDK Design Spec: Data format and storage](../data/)
<!-- busdk-docs-nav end -->
