# bus-invoices

Bus Invoices keeps sales and purchase invoices in schema-validated CSV
datasets, validates totals, VAT amounts, and line consistency, and optionally
produces posting outputs for [`bus journal`](./bus-journal).

## How to run

Run `bus invoices` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes invoice header and line datasets in the invoices area, uses
reference data from [`bus entities`](./bus-entities),
[`bus accounts`](./bus-accounts), and VAT rates, and relies on
JSON Table Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes updated invoice CSVs and status changes, emits validation diagnostics
for missing references or mismatched totals, and produces journal posting
outputs when configured.

## Integrations

It links to [`bus attachments`](./bus-attachments) for invoice
documents and feeds [`bus journal`](./bus-journal),
[`bus bank`](./bus-bank),
[`bus reconcile`](./bus-reconcile), and
[`bus vat`](./bus-vat).

## See also

Repository: ./modules/bus-invoices
