# Schema-driven data contract (Frictionless Table Schema)

Plain CSV is paired with structured schemas. Each dataset adheres to Frictionless Data’s Table Schema, a JSON-based schema specification for tabular data. Table Schema provides field metadata including names, data types, and constraints, enabling automatic validation and consistent processing across modules while keeping the underlying data easily inspectable and editable. ([Frictionless Data](https://frictionlessdata.io/specs/table-schema/?utm_source=chatgpt.com)) This schema-driven approach makes the data self-describing and ensures different modules can agree on the same structure without sharing code.

---

<!-- busdk-docs-nav start -->
**Prev:** [Plain-text CSV for longevity](./plaintext-csv-longevity) · **Index:** [BusDK Design Document](../../index) · **Next:** [Unix-style composability (micro-tools)](./unix-composability)
<!-- busdk-docs-nav end -->
