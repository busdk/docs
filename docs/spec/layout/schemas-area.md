## Schemas beside datasets (Table Schema JSON files)

Each dataset stores its Table Schema JSON file directly beside the dataset file (for example, `accounts.schema.json` beside `accounts.csv`). This keeps schemas and data tightly coupled and avoids any dedicated `schemas/` directory. A `datapackage.json` manifest may still be placed at the repository root to bind resources and schemas into a standardized Frictionless Data Package.

For Finnish compliance, schemas MUST declare primary and foreign keys for audit-trail references. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
**Prev:** [Repository-level README expectations](./repository-readme-expectations) · **Index:** [BusDK Design Document](../../index) · **Next:** [VAT area (reference data and filed summaries)](./vat-area)
<!-- busdk-docs-nav end -->
