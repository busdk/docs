---
title: bus-api-provider-usage — internal usage API provider
description: bus-api-provider-usage exposes JWT-secured internal usage event collection endpoints for trusted Bus backend jobs.
---

## `bus-api-provider-usage` — internal usage API provider

`bus-api-provider-usage` exposes the internal usage-events API used by trusted
backend collectors. It is not an end-user command module and does not provide a
`bus usage` CLI.

### API

```text
GET    /api/internal/usage-events
DELETE /api/internal/usage-events
GET    /readyz
```

Requests use Bearer JWT authentication. The default audience is
`ai.hg.fi/internal`. Listing events requires `usage:read`; deleting events after
successful collection requires `usage:delete`. The response format is JSON and
errors use the common Bus API error envelope:

```json
{
  "error": {
    "type": "invalid_auth",
    "message": "missing bearer token"
  }
}
```

### Persistence

The MVP backend is PostgreSQL. The provider creates a small schema at startup
when it is missing: `accounts`, `usage_events`, and indexes for deterministic
pagination. The database is an intermediate collector feed and can be recreated
from scratch; long-term billing records belong to downstream billing systems.

### Local Development

Use non-secret local configuration values only:

```sh
BUS_USAGE_JWT_SECRET=dev-secret \
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-api-provider-usage --addr 127.0.0.1:8080
```

If no database URL is configured, `/readyz` returns a service-unavailable JSON
response explaining that usage storage is unavailable.

### Sources

- [bus-api-provider-usage README](../../../bus-api-provider-usage/README.md)
