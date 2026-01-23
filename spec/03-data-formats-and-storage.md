# BuSDK Design Spec: Data format and storage

## CSV conventions

All BuSDK data is stored as CSV text files with a header row and one record per row. Conventions prioritize compatibility: UTF-8 encoding; comma delimiters; quoting for fields containing commas or newlines; ISO date formats (YYYY-MM-DD) for date fields; and predictable numeric formats for monetary values. The intended result is that the dataset remains usable in both text editors and common spreadsheet tools, supporting the long-term accessibility goals associated with sustainable formats guidance. ([TransAccess](https://www.tagovcloud.com/2023/06/what-are-sustainable-formats-for-electronic-records-part-1/?utm_source=chatgpt.com))

## Frictionless Table Schema as the contract

Each CSV has a corresponding JSON Table Schema that declares fields, types, constraints, and structural metadata. Table Schema supports declaring required fields, minimums, patterns, primary keys, and foreign keys. The schema functions simultaneously as documentation, as automated validation input, and as future-proofing mechanism when schemas evolve across time. ([Frictionless Data](https://frictionlessdata.io/specs/table-schema/?utm_source=chatgpt.com))

Because Table Schema is standardized, modules can share a single interpretation of datasets even when implemented in different languages. Validation can be performed by integrating Frictionless-compatible tooling or libraries, but BuSDK’s architectural requirement is that validation behavior is consistent across modules regardless of implementation language.

## Data Package organization

BuSDK may optionally adopt a Frictionless Data Package (typically a `datapackage.json`) to provide a repository-wide manifest of resources and their schemas. A Data Package descriptor lists resources, their paths, and their schema references, enabling whole-repository validation and standardized publication or interchange patterns. ([specs.frictionlessdata.io](https://specs.frictionlessdata.io/data-package/?utm_source=chatgpt.com)) Even without a descriptor, the directory structure is designed to be discoverable and navigable, but the Data Package option improves automation and interoperability.

## Schema evolution and migration

BuSDK assumes schemas will evolve as a business evolves. Schema changes are versioned in Git and may include a schema version indicator so tooling can identify the schema version at a given commit. When adding fields, BuSDK may provide migration commands that insert default values across historical rows, or it may treat missing fields in older rows as null/default during reporting. Large structural changes such as splitting a file or renaming a field are acceptable so long as migrations are transparent and recorded in Git history.

## Append-only updates and soft deletion

For critical ledgers such as the journal, BuSDK enforces that new transactions are appended as new rows and that corrections are represented as new records such as reversing entries, not silent in-place edits. Where record removal semantics are required (for example, voiding an invoice), BuSDK prefers soft deletion via an “active” boolean or explicit status field rather than removing rows from history. Git history provides a backstop by exposing deletions as diffs, but user-facing tools are expected to discourage destructive edits.

## Scaling over decades

CSV is viable long-term if proactively managed. To keep repositories performant and diffs focused, BuSDK supports splitting data into multiple files by time period or category. A typical strategy is to segment journal data by year, such as `journal_2025.csv` and `journal_2026.csv`, instead of allowing a single file to grow indefinitely. This reduces the size and complexity of day-to-day diffs, keeps Git operations snappy, and aligns with the practical expectation that even large datasets can remain manageable when partitioned. Older data can be archived by tagging year-end commits, and where desired, by removing old-year files from active branches while retaining them in history for retrieval.

