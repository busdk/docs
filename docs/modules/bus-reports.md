# bus-reports

Bus Reports reads journal entries and reference data to compute reports,
verifies integrity and balances before emitting reports, and outputs reports in
text and structured formats.

## How to run

Run `bus reports` … and use `--help` for
available subcommands and arguments.

## Data it reads and writes

It reads journal data from [`bus journal`](./bus-journal) and
accounts from [`bus accounts`](./bus-accounts), optionally uses
budget data from [`bus budget`](./bus-budget), and uses JSON
Table Schemas stored beside their CSV datasets.

## Outputs and side effects

It writes report outputs (text, CSV, or JSON) to stdout or files and emits
diagnostics for integrity or balance issues.

## Integrations

It consumes data from [`bus journal`](./bus-journal),
[`bus accounts`](./bus-accounts), and
[`bus budget`](./bus-budget), and feeds
[`bus filing`](./bus-filing) and management reporting
workflows.

## See also

Repository: ./modules/bus-reports
