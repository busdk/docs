# Shared validation layer (schema + logical validation)

A shared validation layer is foundational. Each module relies on schema validation and logical validation before accepting a mutation. Schema validation checks types and constraints such as required fields, formats, keys, and referential integrity. Logical validation enforces accounting rules such as balanced double-entry transactions and consistency of invoice totals. Schema compliance is standardized via Table Schema. ([Frictionless Data](https://frictionlessdata.io/specs/table-schema/?utm_source=chatgpt.com)) Logical validation is implemented in module logic, particularly where cross-row invariants are required (for example, “sum of debits equals sum of credits for a transaction group”).

