# bus-status SDD

## Purpose

`bus-status` provides deterministic workspace readiness and close-state status for automation and operator workflows.

## Scope (initial)

- Readiness checks for required datasets:
  - `accounts/accounts.csv` + `accounts/accounts.schema.json`
  - `journal/journal.csv` + `journal/journal.schema.json`
  - `periods.csv` + `periods.schema.json`
- Latest period status summary from `periods.csv`.
- Deterministic machine-friendly output (`tsv`, `json`).

## Command Contract

- Binary: `bus-status`
- Subcommand: `readiness` (default)
- Global flags:
  - `-h, --help`
  - `-V, --version`
  - `-v, --verbose` (repeatable)
  - `-q, --quiet` (mutually exclusive with verbose)
  - `-C, --chdir`
  - `-o, --output`
  - `-f, --format` (`tsv|json`)
  - `--color`, `--no-color`

## Output Schema

`tsv` header:

`workspace	accounts_ready	journal_ready	periods_ready	latest_period	latest_state	close_flow_ready`

`close_flow_ready` is true only when all readiness datasets are present and latest period state is `closed` or `locked`.

## Determinism

- No wall-clock fields in normal output.
- Stable header and field order.
- Latest period/state selected from final valid row in append-only `periods.csv`.

## Test Strategy

- Unit tests:
  - CLI flag parser/validation.
  - Status collector and output formatters.
  - App runtime behavior (help/version/quiet/output/chdir).
- E2E:
  - Workspace fixture with closed period returns `close_flow_ready=true`.
