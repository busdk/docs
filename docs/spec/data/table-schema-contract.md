# Frictionless Table Schema as the contract

Each CSV has a corresponding JSON Table Schema that declares fields, types, constraints, and structural metadata. Table Schema supports declaring required fields, minimums, patterns, primary keys, and foreign keys. The schema functions simultaneously as documentation, as automated validation input, and as future-proofing mechanism when schemas evolve across time. ([Frictionless Data](https://frictionlessdata.io/specs/table-schema/?utm_source=chatgpt.com))

Because Table Schema is standardized, modules can share a single interpretation of datasets even when implemented in different languages. Validation can be performed by integrating Frictionless-compatible tooling or libraries, but BusDK’s architectural requirement is that validation behavior is consistent across modules regardless of implementation language.

## Audit-trail constraints

To satisfy Finnish audit-trail requirements, Table Schemas MUST formalize the identifiers and links required for traceability. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

Primary keys MUST be declared for core datasets (journal, ledger, vouchers, invoices, bank, attachments), and foreign keys MUST be declared for all cross-dataset references (voucher → entries, entries → reports, invoices → attachments). Required fields MUST include the minimum voucher metadata and posting metadata needed for traceability (date, identifier, amount, VAT data when applicable).

---

<!-- busdk-docs-nav start -->
**Prev:** [Schema evolution and migration](./schema-evolution-and-migration) · **Next:** [BusDK Design Spec: CLI tooling and workflow](../04-cli-workflow)
<!-- busdk-docs-nav end -->
