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
Operators mint these trusted collector tokens with `bus operator token issue`
or another deployment-controlled internal-token flow. The token must be HS256
signed with `BUS_USAGE_JWT_SECRET`, include `sub`, `aud=ai.hg.fi/internal`,
space-separated `scope`, `iat`, and `exp`, and be sent as
`Authorization: Bearer <token>`.

For a local auth-backed deployment, configure the auth provider to sign with
the same HS256 secret as `BUS_USAGE_JWT_SECRET`, then mint a read/delete
collector token through the auth provider internal-token endpoint:
the auth provider or local gateway must already be running at
`http://127.0.0.1:8080/local-dev/v1`.

```sh
mkdir -p ./local
export BUS_USAGE_JWT_SECRET=not-a-secret-local-development-hs256-key
printf '%s' 'not-a-secret-local-development-internal-key' > ./local/auth-internal-shared-key
# The auth provider must run with BUS_AUTH_HS256_SECRET="$BUS_USAGE_JWT_SECRET"
# and BUS_AUTH_INTERNAL_SHARED_KEY from ./local/auth-internal-shared-key.
bus operator token \
  --api-url http://127.0.0.1:8080/local-dev/v1 \
  --internal-key-file ./local/auth-internal-shared-key \
  --format token \
  issue \
  --subject usage-collector \
  --audience ai.hg.fi/internal \
  --scope "usage:read usage:delete" \
  --ttl 1h > ./local/usage-collector.token
```

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
Item fields are `id` (integer), `event_id` (string or omitted),
`occurred_at` (RFC3339 string), `account_id` (UUID string or omitted),
`event_type` (string), and `data` (JSON object or omitted). A non-empty page
looks like:

```json
{"items":[{"id":1,"event_id":"usage-doc-check","occurred_at":"2026-05-03T12:00:00Z","account_id":"00000000-0000-4000-8000-000000000001","event_type":"usage_recorded","data":{"total_tokens":1}}],"page":1,"page_size":100,"before":"2026-05-03T12:05:00Z","has_more":false}
```

Collectors should persist a page downstream before deleting it.
Query parameters are `before=<RFC3339 timestamp>`, `page=<n>`, and
`page_size=<n>`. Defaults are current time, page `1`, and page size `1000`;
page size is capped at `10000`. Results are ordered by `occurred_at,id` and
return `items`, `page`, `page_size`, `before`, and `has_more`.

Example collector request:

```sh
before="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
curl -fsS \
  -H "Authorization: Bearer $(cat ./local/usage-collector.token)" \
  "http://127.0.0.1:8082/api/internal/usage-events?before=${before}&page=1&page_size=100"
```

A successful response is `200 OK` with a deterministic page, for example
`{"items":[],"page":1,"page_size":100,"before":"...","has_more":false}`.

### `DELETE /api/internal/usage-events`

Deletes collected usage records.

Use the same pagination selector after the collector has safely persisted the
page elsewhere. "Safely persisted" means the downstream database transaction,
file write plus fsync, or provider export acknowledgement has completed and can
be retried without losing records. With offset-style pages, repeatedly read,
persist, and delete `page=1` with the same fixed `before` value until the page
is empty. Do not
delete page `1` and then move to page `2`, because deleting earlier rows can
shift later records and skip items.
The DELETE endpoint accepts the same `before`, `page`, and `page_size`
selector as GET and deletes that deterministic page. Success returns
`{"deleted": <count>}`.

Persist the GET page downstream before deleting it, then reuse the exact same
selector:

```sh
curl -fsS -X DELETE \
  -H "Authorization: Bearer $(cat ./local/usage-collector.token)" \
  "http://127.0.0.1:8082/api/internal/usage-events?before=${before}&page=1&page_size=100"
```

The response is `200 OK` with `{"deleted":0}` or the number of records removed
from that page.

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

Start PostgreSQL first and ensure the database in `BUS_USAGE_DATABASE_URL`
exists and is reachable.

```sh
BUS_USAGE_JWT_SECRET=not-a-secret-local-development-hs256-key \
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-api-provider-usage --addr 127.0.0.1:8082
```

Verify readiness with:

```sh
curl -fsS http://127.0.0.1:8082/readyz
```

A configured database returns `200 OK` with an `ok` readiness body. Missing or
unreachable storage returns a service-unavailable JSON error.

Plain JWT secret values are raw text even when they look like base64; use
`base64:<value>` only for an intentionally base64-encoded secret.

The BusDK superproject `compose.yaml` starts this provider as `bus-usage-api`
with `BUS_USAGE_DATABASE_URL` pointing at the local PostgreSQL service. Nginx
exposes the trusted collector path at `/api/internal/usage-events`. The local
usage worker writes usage records through Bus Events using PostgreSQL storage,
and trusted collectors read or delete collected pages through this provider
with internal-audience usage scopes.

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
