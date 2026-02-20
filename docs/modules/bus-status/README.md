# bus-status

`bus-status` reports deterministic workspace readiness and period close-state status.

## Quickstart

```bash
bus-status readiness
bus-status -f json -o status.json
```

## Fields

- `accounts_ready`: accounts dataset + schema present.
- `journal_ready`: journal dataset + schema present.
- `periods_ready`: periods dataset + schema present.
- `latest_period`: latest period id from period control data.
- `latest_state`: latest period state (`future|open|closed|locked|...`).
- `close_flow_ready`: true only when core datasets exist and latest state is `closed` or `locked`.
