# bus-journal

Bus Journal maintains journal entries as append-only CSV datasets, validates
schema conformance and balanced transaction invariants, and acts as the
authoritative source of ledger postings.

## How to run

Run `bus journal` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes journal datasets in the journal area (for example
`journal.csv`), uses reference data from
[`bus accounts`](./bus-accounts) and other posting sources, and
uses JSON Table Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes new or updated journal entry rows and emits diagnostics for unbalanced
or invalid entries.

## Integrations

It receives postings from [`bus invoices`](./bus-invoices),
[`bus bank`](./bus-bank),
[`bus assets`](./bus-assets),
[`bus payroll`](./bus-payroll), and
[`bus loans`](./bus-loans), and serves as the foundation for
[`bus reports`](./bus-reports),
[`bus budget`](./bus-budget), and
[`bus vat`](./bus-vat).

## See also

Repository: ./modules/bus-journal
