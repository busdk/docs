# Frictionless Table Schema as the contract

In BusDK, each table has a corresponding Table Schema that declares fields, types, constraints, and structural metadata. In the preferred default layout, tables are stored as CSV and schemas are stored as JSON, but the invariant is the schema-driven data contract — not a particular serialization format. Table Schema supports declaring required fields, minimums, patterns, primary keys, and foreign keys. The schema functions simultaneously as documentation, as automated validation input, and as a mechanism for keeping revisions interpretable as tables and schemas evolve over time. See [Schema-driven data contract (Frictionless Table Schema)](../design-goals/schema-contract) and the upstream specification at [Frictionless Data Table Schema](https://frictionlessdata.io/specs/table-schema/).

Because Table Schema is standardized, modules can share a single interpretation of datasets even when implemented in different languages. Validation can be performed by integrating Frictionless-compatible tooling or libraries, but BusDK’s architectural requirement is that validation behavior is consistent across modules regardless of implementation language.

## Audit-trail constraints

To satisfy Finnish audit-trail requirements, Table Schemas MUST formalize the identifiers and links required for traceability. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

Primary keys MUST be declared for core datasets (journal, ledger, vouchers, invoices, bank, attachments), and foreign keys MUST be declared for all cross-dataset references (voucher → entries, entries → reports, invoices → attachments). Required fields MUST include the minimum voucher metadata and posting metadata needed for traceability (date, identifier, amount, VAT data when applicable).

---

<!-- busdk-docs-nav start -->
**Prev:** [Schema evolution and migration](./schema-evolution-and-migration) · **Index:** [BusDK Design Spec: Data format and storage](../data/) · **Next:** [BusDK Design Spec: Data directory layout](../layout/)
<!-- busdk-docs-nav end -->
