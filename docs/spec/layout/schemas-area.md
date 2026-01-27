# Schemas beside datasets (Table Schema JSON files)

Each dataset stores its Table Schema JSON file directly beside the CSV file.
This keeps schemas and data tightly coupled and avoids any dedicated
`schemas/` directory. A `datapackage.json` manifest may still be placed at the
repository root to bind resources and schemas into a standardized Frictionless
Data Package.

For Finnish compliance, schemas MUST declare primary and foreign keys for audit-trail references. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

