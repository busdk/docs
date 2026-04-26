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

List responses preserve mixed Bus usage records from LLM, runtime, and
container providers. Each item includes the storage `id`, optional idempotency
`event_id`, `occurred_at`, optional `account_id`, `event_type`, and raw JSON
`data`. Collectors should persist the page downstream before calling
`DELETE /api/internal/usage-events` with the same pagination selector.

### Persistence

The MVP backend is PostgreSQL. The provider creates a small schema at startup
when it is missing: `accounts`, `usage_events`, and indexes for deterministic
pagination and non-empty `event_id` idempotency. The database is an intermediate
collector feed and can be recreated from scratch; long-term billing records
belong to downstream billing systems.

`bus-integration-usage` is the event-worker boundary for usage business logic
and storage access. This provider remains the JWT-secured HTTP facade for
trusted collectors.

The module e2e suite exercises the collector path against PostgreSQL. It uses
`BUS_USAGE_E2E_DATABASE_URL` when provided, or a disposable Docker Compose
PostgreSQL service when Docker is available, then writes a usage event through
`bus-integration-usage` and reads/deletes it through this HTTP provider.

### Local Development

Use non-secret local configuration values only:

```sh
BUS_USAGE_JWT_SECRET=dev-secret \
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-api-provider-usage --addr 127.0.0.1:8080
```

Plain JWT secret values are raw text even when they look like base64; use
`base64:<value>` only for an intentionally base64-encoded secret.

If no database URL is configured, `/readyz` returns a service-unavailable JSON
response explaining that usage storage is unavailable.

### Sources

- [bus-api-provider-usage README](../../../bus-api-provider-usage/README.md)
- [bus-integration-usage](./bus-integration-usage.md)
