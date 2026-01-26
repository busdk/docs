# Frictionless Table Schema as the contract

Each CSV has a corresponding JSON Table Schema that declares fields, types, constraints, and structural metadata. Table Schema supports declaring required fields, minimums, patterns, primary keys, and foreign keys. The schema functions simultaneously as documentation, as automated validation input, and as future-proofing mechanism when schemas evolve across time. ([Frictionless Data](https://frictionlessdata.io/specs/table-schema/?utm_source=chatgpt.com))

Because Table Schema is standardized, modules can share a single interpretation of datasets even when implemented in different languages. Validation can be performed by integrating Frictionless-compatible tooling or libraries, but BusDK’s architectural requirement is that validation behavior is consistent across modules regardless of implementation language.

