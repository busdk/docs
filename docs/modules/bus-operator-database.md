---
title: bus operator database
description: bus operator database manages provider-neutral database setup and verification for Bus deployments.
---

## Database Operations

`bus operator database` controls database resources needed by Bus services:
roles, databases, schemas, DSN references, listener policy, and connectivity
checks. The command is provider-neutral and defaults to the PostgreSQL provider.

Run these commands from the deployment repository or workspace root. Create
`./deploy/database.env` as an operator-owned local file with mode `0600`. For
PostgreSQL, include `BUS_DATABASE_PROVIDER=postgres` and references to the
admin connection secret, service DSN output location, target databases, roles,
and schema names used by the selected deployment. The PostgreSQL role used for
`apply` must be allowed to create or update the requested roles, databases,
schemas, and privileges. `doctor`, `plan`, and `status` are safe inspection
commands. `apply` is mutating and should run only after `plan` returns the
expected actions. `verify` should return `ok: true` with connectivity and
listener-policy checks.

```sh
umask 077
: "${POSTGRES_ADMIN_DSN:?export POSTGRES_ADMIN_DSN with a PostgreSQL admin DSN allowed to create/update the requested roles, databases, schemas, and privileges}"
install -m 700 -d ./deploy ./local
git check-ignore -q ./local/postgres-admin-dsn || printf '%s\n' './local/' >> .git/info/exclude
printf '%s\n' "$POSTGRES_ADMIN_DSN" > ./local/postgres-admin-dsn
cat > ./deploy/database.env <<'EOF'
BUS_DEPLOYMENT_ID=example-dev
BUS_DATABASE_PROVIDER=postgres
BUS_POSTGRES_ADMIN_DSN_FILE=./local/postgres-admin-dsn
BUS_DATABASE_NAMES=bus_auth,bus_events,bus_usage,bus_billing
BUS_DATABASE_SERVICE_ROLE=bus_service
BUS_DATABASE_DSN_OUTPUT_DIR=./local/dsn
EOF
bus operator database doctor --provider postgres
bus operator database plan --env-file ./deploy/database.env
```

Review the plan output before applying database changes:

```sh
bus operator database apply --env-file ./deploy/database.env
bus operator database status --env-file ./deploy/database.env
bus operator database verify --env-file ./deploy/database.env
```

Use env-style files for local operator inputs. Keep passwords and DSNs in
operator-owned secret files or environment variables outside Git. In a running
Bus deployment, `bus-api-provider-database` exposes the matching internal API
surface and `bus-integration-database` owns the shared event contract.

### Sources

- [bus-api-provider-database](./bus-api-provider-database)
- [bus-integration-database](./bus-integration-database)
- [bus-integration-postgres](./bus-integration-postgres)
- [bus operator deploy](./bus-operator-deploy)
