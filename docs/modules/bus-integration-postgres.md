---
title: bus-integration-postgres
description: bus-integration-postgres provides PostgreSQL-specific database integration behind Bus database contracts.
---

## PostgreSQL Integration

`bus-integration-postgres` registers PostgreSQL behind the provider-neutral
`bus-integration-database` contract. It owns PostgreSQL-specific setup and
verification behavior while `bus operator database` and
`bus-api-provider-database` stay provider-neutral.

Before running provider-backed commands, create `./deploy/database.env` as
described on [bus operator database](./bus-operator-database). It must include
`BUS_DEPLOYMENT_ID`, `BUS_DATABASE_PROVIDER=postgres`,
`BUS_POSTGRES_ADMIN_DSN_FILE`, `BUS_DATABASE_NAMES`,
`BUS_DATABASE_SERVICE_ROLE`, and `BUS_DATABASE_DSN_OUTPUT_DIR`. The admin DSN
file must be mode `0600` and readable by the operator; generated service DSN
files must be readable only by the matching service account.

Run `--events` first to verify the provider advertises the database contract;
successful output includes `provider postgres` and
`bus.database.plan.request`. Use `--dry-run plan` to inspect the
PostgreSQL-specific action plan without changing the server; successful output
returns `ok: true`, `provider: postgres`, and `dry_run: true`. Then run
provider-backed apply through
`bus operator database apply --env-file ./deploy/database.env`.
That apply command succeeds with `ok: true` and an `apply-database-plan` action.
`--self-test` succeeds by printing
`OK bus-integration-postgres self-test`.

```sh
bus-integration-postgres --events
bus-integration-postgres --events --format json
bus-integration-postgres --dry-run plan
bus operator database apply --env-file ./deploy/database.env
bus-integration-postgres --self-test
```

Use PostgreSQL credentials from operator-managed local environment or secret
files. `BUS_POSTGRES_ADMIN_DSN_FILE` points to a file containing a PostgreSQL
DSN such as `postgres://admin:password@127.0.0.1:5432/postgres?sslmode=require`.
`BUS_DATABASE_DSN_OUTPUT_DIR` points to the directory where generated service
DSN files are written. The admin DSN file should be mode `0600` and readable
only by the operator running bootstrap. Generated service DSN files should be
readable only by the service account that starts the matching Bus service. Do
not put production DSNs, passwords, or service credentials in committed
configuration.

### Sources

- [bus-integration-database](./bus-integration-database)
- [bus-api-provider-database](./bus-api-provider-database)
- [bus operator database](./bus-operator-database)
