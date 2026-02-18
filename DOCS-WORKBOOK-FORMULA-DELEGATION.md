# docs.busdk.com — workbook formula delegation

Documentation for formula metadata and workbook extraction lives on **docs.busdk.com**, not in this repo. This file is a short reference for maintainers.

## Canonical page

**Formula metadata and evaluation for workbook extraction**  
https://docs.busdk.com/modules/bus-bfl-workbook-formula-delegation

That page is the source of truth. In-repo text (e.g. README) should link only to that URL.

## Status

The canonical page is current and includes:

- Overview (audience, canonical SDD link)
- Delegation contract (determinism, consumer responsibilities, bus-bfl role)
- Formula metadata table (schema → BFL options) and validation note
- Locale-aware evaluation (decimal/thousands separators, dialect profile, example, display vs evaluation)
- Function set for report totals (SUM, IF, ROUND; same set for validation and evaluation)
- Relation to bus-data and FR-DAT-025, including source-specific workbook dialect behavior
- Sources (Table Schema contract, bus-bfl SDD, bus-data SDD, bus-data CLI)

## When to update docs.busdk.com

Edit the canonical page when:

- The [bus-bfl SDD](https://docs.busdk.com/sdd/bus-bfl) changes formula metadata, dialect, or integration contract.
- bus-data adds or changes `--formula` / `--formula-source` or FR-DAT-025 behavior.
- You want to add sections (e.g. error handling, dry-run) — keep them consistent with the SDD and [Table Schema contract](https://docs.busdk.com/data/table-schema-contract).

No in-repo copy of the page is maintained; use the live page and the SDD as the spec.
