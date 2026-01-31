# CSV conventions

BusDK’s preferred default representation for workspace datasets is UTF-8 CSV with a header row and one record per row, paired with explicit Table Schemas. Conventions prioritize compatibility: UTF-8 encoding; comma delimiters; quoting for fields containing commas or newlines; ISO date formats (YYYY-MM-DD) for date fields; and predictable numeric formats for monetary values. The intended result is that the canonical dataset remains readable with general-purpose tooling and straightforward to inspect and diff, consistent with the long-term accessibility goals described in [Plain-text CSV for longevity](../design-goals/plaintext-csv-longevity) and aligned with [National Archives guidance on selecting sustainable formats for electronic records](https://www.archives.gov/records-mgmt/initiatives/sustainable-faq.html).

CSV is an implementation choice, not the definition of the goal. Other storage backends may be used over time as long as BusDK preserves deterministic, schema-validated tables and predictable export back to simple, tabular text formats.

## Audit-trail CSV requirements

To satisfy Finnish audit-trail expectations, tabular datasets MUST be deterministic, linkable, and stable over time. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

Each dataset MUST include a stable primary identifier column (`*_id`) that never changes once written, and cross-dataset references MUST be explicit as foreign key columns (for example: `voucher_id`, `entry_id`, `attachment_id`, `bank_txn_id`). Row ordering MUST be reproducible using date + sequence columns so that independent tools can produce the same time-ordered view.

---

<!-- busdk-docs-nav start -->
**Prev:** [Append-only updates and soft deletion](./append-only-and-soft-deletion) · **Index:** [BusDK Design Spec: Data format and storage](../data/) · **Next:** [Data Package organization](./data-package-organization)
<!-- busdk-docs-nav end -->
