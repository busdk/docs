# CSV conventions

All BusDK data is stored as CSV text files with a header row and one record per row. Conventions prioritize compatibility: UTF-8 encoding; comma delimiters; quoting for fields containing commas or newlines; ISO date formats (YYYY-MM-DD) for date fields; and predictable numeric formats for monetary values. The intended result is that the dataset remains usable in both text editors and common spreadsheet tools, supporting the long-term accessibility goals associated with sustainable formats guidance. ([TransAccess](https://www.tagovcloud.com/2023/06/what-are-sustainable-formats-for-electronic-records-part-1/?utm_source=chatgpt.com))

## Audit-trail CSV requirements

To satisfy Finnish audit-trail expectations, CSV datasets MUST be deterministic, linkable, and stable over time. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

Each dataset MUST include a stable primary identifier column (`*_id`) that never changes once written, and cross-dataset references MUST be explicit as foreign key columns (for example: `voucher_id`, `entry_id`, `attachment_id`, `bank_txn_id`). Row ordering MUST be reproducible using date + sequence columns so that independent tools can produce the same time-ordered view.

