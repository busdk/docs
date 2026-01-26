# bus-period

Bus Period opens and closes accounting periods in the workspace, generates
closing and opening balance entries, and locks periods to prevent changes after
close.

## How to run

Run `bus period` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads and writes period control datasets in the period area, uses journal
data from [`bus journal`](./bus-journal) for closing
calculations, and uses JSON Table Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes period state datasets and closing entry outputs, and emits diagnostics
for unbalanced or invalid period closures.

## Integrations

It consumes [`bus journal`](./bus-journal) data and may emit
postings back to it, and is required before
[`bus filing`](./bus-filing) and authority export workflows.

## See also

Repository: ./modules/bus-period
