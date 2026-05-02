---
title: bus-api-provider-database
description: bus-api-provider-database exposes provider-neutral database capabilities and planning endpoints.
---

## Database API Provider

`bus-api-provider-database` is the running-Bus HTTP surface for database setup
and verification. It keeps REST controllers provider-neutral and delegates
database work through `bus-integration-database`.

Run this provider on loopback or a protected internal network behind `bus-api`.
The supported deployment boundary is `bus-api` routing with an internal
operator token or internal service credential, plus reverse-proxy rules that
do not expose `/api/internal/database/*` directly to the public internet. The
current provider handler is an internal component and does not perform
public-client authentication by itself.

Available endpoints return `200` with JSON on success:

- `GET /healthz` returns `{"ok":true,"service":"bus-api-provider-database"}`.
- `GET /api/internal/database/capabilities` returns provider-neutral capability metadata with PostgreSQL provider discovery, event names, and direct-bootstrap support.
- `GET /api/internal/database/plan` returns `{"ok":true,"actions":[...]}` for the current database plan view.

Before starting it, install `bus-api-provider-database`,
`bus-integration-database`, and the selected provider integration from the same
BusDK release set. For PostgreSQL-backed deployments, set
`BUS_DATABASE_PROVIDER=postgres` in the service environment; the capability
endpoint then advertises PostgreSQL and database event names.

```sh
BUS_DATABASE_PROVIDER=postgres bus-api-provider-database --addr 127.0.0.1:8092
```

In a second shell, verify the provider:

```sh
curl -fsS http://127.0.0.1:8092/healthz
curl -fsS http://127.0.0.1:8092/api/internal/database/capabilities
```

The first check succeeds with `ok: true`; the second includes database event
names such as `bus.database.plan.request`.

PostgreSQL-specific behavior belongs to `bus-integration-postgres`; this
provider exposes the stable Bus API surface used by operators and deployment
automation.

### Using from `.bus` files

Inside a `.bus` file, start the provider on loopback and let `bus-api` or the
supervisor own public routing:

```bus
# same as: BUS_DATABASE_PROVIDER=postgres bus-api-provider-database --addr 127.0.0.1:8092
run command -- BUS_DATABASE_PROVIDER=postgres bus-api-provider-database --addr 127.0.0.1:8092
```

### Sources

- [bus-integration-database](./bus-integration-database)
- [bus-integration-postgres](./bus-integration-postgres)
- [bus operator database](./bus-operator-database)
