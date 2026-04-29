---
title: bus-api-provider-usage — internal usage API provider
description: bus-api-provider-usage exposes JWT-secured internal usage event collection endpoints for trusted Bus backend jobs.
---

## `bus-api-provider-usage` — internal usage API provider

`bus-api-provider-usage` exposes the internal usage-events API used by trusted
backend collectors. It is not an end-user command module and does not provide a
`bus usage` CLI.

Use this provider when a deployment needs an HTTP collector feed for usage
events after API providers and integrations have recorded them. End users
should not call these endpoints.

### Authentication

Requests use Bearer JWT authentication with audience `ai.hg.fi/internal`.

Listing events requires `usage:read`. Deleting collected events requires
`usage:delete`.

### Error Format

Errors use the common Bus API JSON envelope:

```json
{
  "error": {
    "type": "invalid_auth",
    "message": "missing bearer token"
  }
}
```

The collector feed is internal infrastructure. Payment-provider export and
quota bucket updates normally happen through `bus-integration-usage` and
`bus-integration-billing`; collectors should not infer authorization or account
ownership from caller-supplied data.

### `GET /api/internal/usage-events`

Lists usage records for trusted collectors.

Responses can include LLM, runtime, and container usage records. Each item
contains storage `id`, optional idempotency `event_id`, occurrence time,
optional `account_id`, event type, and raw JSON data.

Collectors should persist a page downstream before deleting it.

### `DELETE /api/internal/usage-events`

Deletes collected usage records.

Use the same pagination selector after the collector has safely persisted the
page elsewhere.

### `GET /readyz`

Reports provider readiness.

If no database URL is configured, readiness returns a service-unavailable JSON
response explaining that usage storage is unavailable.

### Persistence

The provider stores collector feed data in PostgreSQL. It creates a small schema at startup
when it is missing: `accounts`, `usage_events`, and indexes for deterministic
pagination and non-empty `event_id` idempotency. The database is an intermediate
collector feed and can be recreated from scratch; long-term billing records
belong to downstream billing systems.

`bus-integration-usage` is the event-worker boundary for usage business logic
and storage access. This provider remains the JWT-secured HTTP facade for
trusted collectors.

### Local Development

Use non-secret local configuration values only:

```sh
BUS_USAGE_JWT_SECRET=dev-secret \
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-api-provider-usage --addr 127.0.0.1:8080
```

Plain JWT secret values are raw text even when they look like base64; use
`base64:<value>` only for an intentionally base64-encoded secret.

### Security Notes

Use internal-audience JWTs only. End-user `aud=ai.hg.fi/api` tokens are not
valid for this provider. Do not expose the internal usage API through public
routes unless an API gateway enforces the same internal audience and scope
checks.

Usage records can contain operational metadata. Avoid placing bearer tokens,
provider secrets, database URLs with passwords, SSH keys, or SMTP credentials
inside usage `data`.

### Sources

- [bus-integration-usage](./bus-integration-usage)
