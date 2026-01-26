# bus-vat

Bus VAT computes VAT totals per reporting period, validates VAT code and rate
mappings against reference data, and reconciles invoice VAT with ledger
postings.

## How to run

Run `bus vat` … and use `--help` for available
subcommands and arguments.

## Data it reads and writes

It reads invoice data from [`bus invoices`](./bus-invoices) and
postings from [`bus journal`](./bus-journal), optionally uses
VAT reference datasets in the VAT area, and uses JSON Table Schemas stored
beside their CSV datasets.

## Outputs and side effects

It writes VAT summaries and export files for reporting and archiving, and emits
diagnostics for VAT mismatches or missing mappings.

## Integrations

It consumes data from [`bus invoices`](./bus-invoices),
[`bus journal`](./bus-journal), and
[`bus accounts`](./bus-accounts), and feeds
[`bus filing`](./bus-filing) and statutory reporting workflows.

## See also

Repository: ./modules/bus-vat
