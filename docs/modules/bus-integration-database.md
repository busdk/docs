---
title: bus-integration-database
description: bus-integration-database defines provider-neutral database event contracts for Bus deployment automation.
---

## Database Integration Contract

`bus-integration-database` defines the provider-neutral event contract for
database setup and verification. Bootstrap tools and running Bus services use
the same contract so database providers can be reused in both environments.

Run the discovery commands after installing the matching release binary. No
database credentials are required for these local contract checks. `--events`
prints one event name per line, `--events --format json` prints provider,
event, and direct-bootstrap capability metadata, and `--self-test` prints
`OK bus-integration-database self-test`.

```sh
bus-integration-database --events
bus-integration-database --events --format json
bus-integration-database --self-test
```

Database request and response events include:

- `bus.database.plan.request` and `bus.database.plan.response`: request fields include provider, target deployment, desired roles/databases/schemas, listener policy, and credential references; responses include planned actions, validation diagnostics, and error class.
- `bus.database.apply.request` and `bus.database.apply.response`: request fields include the reviewed desired state plus dry-run/confirmation flags; responses include applied actions, safe resource names, diagnostics, and error class.
- `bus.database.status.request` and `bus.database.status.response`: request fields identify provider and target deployment; responses include current database/role/schema status summaries.
- `bus.database.verify.request` and `bus.database.verify.response`: request fields identify connection and listener checks; responses include `ok`, connectivity results, listener-policy results, and diagnostics.

Concrete database providers such as `bus-integration-postgres` register behind
this contract.

Operators normally send these requests through `bus operator database`. Install
the `bus` dispatcher with `bus-operator-database` and the selected provider
module, for PostgreSQL `bus-integration-postgres`, from the same release set.
For a local PostgreSQL contract check, create `./.env` with the selected
provider before running the commands. The `bus` dispatcher loads this file into
the operator command environment:

```sh
cat > ./.env <<'EOF'
BUS_DATABASE_PROVIDER=postgres
EOF
bus operator database plan
bus operator database apply
bus operator database status
bus operator database verify
```

Each command exits 0 and prints JSON with `"ok": true` and
`"provider": "postgres"` when the provider-neutral command path is available.
The current `bus operator database apply` command is a provider-neutral
controller check that prints `apply-database-plan`; it does not create
PostgreSQL objects by itself. A real PostgreSQL mutation must be handled by the
provider integration with dry-run disabled and explicit confirmation. For the
runnable PostgreSQL apply path, use the provider instructions in
[bus-integration-postgres](./bus-integration-postgres), including
`bus operator database apply` after the PostgreSQL admin DSN and output
directory prerequisites are satisfied.
Provider-specific credentials such as PostgreSQL admin DSNs belong to
`bus-integration-postgres` and should be supplied through untracked secret files
or service environment when a real apply replaces the dry-run path.

The internal `bus-api-provider-database` route provides the running-Bus API
surface for the same contract. Before running the stream-and-grep example,
Bus Events, `bus-api-provider-database`, and the selected database provider
integration must be running and subscribed so a response event can be produced.
Direct event publishers send the JSON payload to the Bus Events API with the
matching event type, for example
`POST /api/v1/events` on `bus-api-provider-events` with a bearer token that has
event publish scope. Include a `correlation_id` field in the event envelope and
consume the matching response event with the same correlation id through
`GET /api/v1/events/stream?name=bus.database.plan.response&delivery=broadcast`.
Set `$BUS_EVENTS_API_BASE_URL` to the Bus Events provider base URL and
`$BUS_EVENTS_TOKEN` to a token with `events:write` for publish and
`events:read` for streaming before running the example.

```sh
export BUS_EVENTS_API_BASE_URL="https://example.test"
test -n "$BUS_EVENTS_TOKEN"
install -m 700 -d ./deploy
cat > ./deploy/database-plan-event.json <<'EOF'
{
  "name": "bus.database.plan.request",
  "correlation_id": "deploy-001-db-plan",
  "delivery": "broadcast",
  "payload": {
    "deployment_id": "example-dev",
    "provider": "postgres",
    "dry_run": true,
    "databases": ["bus_events"]
  }
}
EOF
curl -fsS -N --max-time 15 "$BUS_EVENTS_API_BASE_URL/api/v1/events/stream?name=bus.database.plan.response&delivery=broadcast" \
  -H "Authorization: Bearer $BUS_EVENTS_TOKEN" > ./deploy/database-plan-response.ndjson &
stream_pid=$!
curl -fsS -X POST "$BUS_EVENTS_API_BASE_URL/api/v1/events" \
  -H "Authorization: Bearer $BUS_EVENTS_TOKEN" \
  -H "Content-Type: application/json" \
  --data @./deploy/database-plan-event.json
wait "$stream_pid" || true
grep '"correlation_id":"deploy-001-db-plan"' ./deploy/database-plan-response.ndjson
```

The bearer token used to publish this envelope must include the deployment's
Bus Events publish scope, such as `events:write`, and response streaming needs
the matching read scope, such as `events:read`. Successful publish returns
`202 Accepted` or `200 OK` with stored event metadata.

This is a minimal `bus.database.plan.request` or dry-run
`bus.database.apply.request` payload:

```json
{
  "deployment_id": "example-dev",
  "provider": "postgres",
  "dry_run": true,
  "confirm": false,
  "credentials": {
    "admin_dsn_file": "./local/postgres-admin-dsn"
  },
  "databases": ["bus_auth", "bus_events"],
  "roles": ["bus_service"],
  "schemas": ["public"]
}
```

Use the request example for `bus.database.plan.request` and
dry-run validation. For a real `bus.database.apply.request`, use the same
shape with `"dry_run": false` and `"confirm": true`. `bus.database.status.request`
requires only `deployment_id`, `provider`, and optional `credentials`.
`bus.database.verify.request` requires `deployment_id`, `provider`, and
`checks`, where `checks` is an array such as
`["connectivity","listener-policy"]`; credentials are required only when the
provider cannot resolve them from its service environment.

Minimal status payload:

```json
{
  "deployment_id": "example-dev",
  "provider": "postgres"
}
```

Minimal verify payload:

```json
{
  "deployment_id": "example-dev",
  "provider": "postgres",
  "checks": ["connectivity", "listener-policy"]
}
```

Minimal database response payloads use this shape:

```json
{
  "ok": true,
  "deployment_id": "example-dev",
  "provider": "postgres",
  "actions": ["discover-provider", "compute-database-plan"],
  "diagnostics": []
}
```

Required fields per event are:

- `bus.database.plan.request`: `deployment_id` string, `provider` string, and one or more of `databases`, `roles`, or `schemas`; `dry_run` defaults to `true`.
- `bus.database.apply.request`: the same fields as plan plus `confirm` boolean; `confirm` must be `true` unless `dry_run` is `true`.
- `bus.database.status.request`: `deployment_id` string and `provider` string.
- `bus.database.verify.request`: `deployment_id` string, `provider` string, and `checks` string array; `credentials.admin_dsn_file` or `credentials.admin_dsn_secret` is required when the provider does not already have a configured admin DSN.

Supported credential keys are `admin_dsn_file` for file references such as
`./local/postgres-admin-dsn` and `admin_dsn_secret` for secret references such
as `secret://deployment/postgres-admin-dsn`. Error responses set `ok` to
`false`, include `error_class`, and include a diagnostic message.

### Sources

- [bus-api-provider-database](./bus-api-provider-database)
- [bus-integration-postgres](./bus-integration-postgres)
- [bus operator database](./bus-operator-database)
