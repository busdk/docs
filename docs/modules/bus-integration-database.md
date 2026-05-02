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

Operators normally send these requests through `bus operator database`:

```sh
bus operator database plan --env-file ./deploy/database.env
bus operator database apply --env-file ./deploy/database.env
bus operator database status --env-file ./deploy/database.env
bus operator database verify --env-file ./deploy/database.env
```

The internal `bus-api-provider-database` route provides the running-Bus API
surface for the same contract. Direct event publishers send the JSON payload to
the Bus Events API with the matching event type, for example
`POST /api/v1/events` on `bus-api-provider-events` with a bearer token that has
event publish scope. Include a `correlation_id` field in the event envelope and
consume the matching response event with the same correlation id.

```json
{
  "event_type": "bus.database.plan.request",
  "correlation_id": "deploy-001-db-plan",
  "payload": {
    "deployment_id": "example-dev",
    "provider": "postgres",
    "dry_run": true,
    "databases": ["bus_events"]
  }
}
```

The bearer token used to publish this envelope must include the deployment's
Bus Events publish scope, such as `events:write`.

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
