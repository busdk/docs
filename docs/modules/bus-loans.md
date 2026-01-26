# bus-loans

Bus Loans maintains loan master data and event logs in CSV datasets, generates
amortization schedules from contract terms, and produces journal posting
suggestions for loan activity.

## How to run

Run `bus loans` … and use `--help` for available
subcommands and arguments.

## Data it reads and writes

It reads and writes loan register and event datasets in the loans area, uses
reference data from [`bus accounts`](./bus-accounts) and
[`bus entities`](./bus-entities), and relies on JSON Table
Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes updated loan registers and schedules, emits posting suggestions for
[`bus journal`](./bus-journal), and provides validation
diagnostics for inconsistent terms.

## Integrations

It posts to [`bus journal`](./bus-journal) and influences
[`bus reports`](./bus-reports), linking to
[`bus bank`](./bus-bank) and
[`bus reconcile`](./bus-reconcile) for cash movements.

## See also

Repository: ./modules/bus-loans
