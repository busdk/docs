---
title: bus-api-provider-vm — VM API provider
description: bus-api-provider-vm exposes Bus VM/runtime status and lifecycle endpoints.
---

## `bus-api-provider-vm` — VM API provider

`bus-api-provider-vm` is the server-side provider for cloud-neutral VM/runtime
APIs.

In events mode, the provider sends VM lifecycle requests through the Bus Events
API. A deployment can pair it with `bus-integration-upcloud` when the backing
runtime is UpCloud.

LLM deployments can use this provider behind `bus-api-provider-llm` runtime
wake-up. The LLM provider should wake or check runtime readiness only for
execution requests; model catalog reads can stay local and avoid waking GPU
backends.

### Authentication

Requests use Bearer JWT authentication with audience `ai.hg.fi/api`.

Status reads require `vm:read`. Lifecycle writes require `vm:write`.
Send the token as `Authorization: Bearer <jwt>`. End users normally obtain the
token with `bus auth token --scope "vm:read vm:write"` after their account is
verified and approved; services use deployment-managed service tokens.

The curl examples below target the root `compose.yaml` nginx gateway at
`LOCAL_AI_PLATFORM_PORT`, which proxies to the provider. For a standalone
provider started directly on `127.0.0.1:8085`, replace the base URL with
`http://127.0.0.1:8085`.

```sh
bus auth token --scope "vm:read vm:write"
TOKEN="$(cat ~/.config/bus/auth/api-token)"
```

### `GET /api/v1/vm/status`

Returns user-visible runtime status.

Status reads are not quota-gated and are not treated as billable lifecycle
events.
The request body is empty. Success returns `200 OK` with
`{"status":{"state":"ready","provider":"...","details":{}}}`.
The response object contains `status.state` (known values include `ready`,
`starting`, `stopped`, and `unavailable`), `status.provider`, and optional
`status.details`. Clients should display unknown future states as-is and treat
them as not ready unless the deployment documents otherwise.

```sh
curl -fsS \
  -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/vm/status
```

### `POST /api/v1/vm/start`

Requests runtime start.

With billing enabled, the provider checks `vm:write` entitlement before sending
worker requests or recording lifecycle usage.
The request body is empty. Success returns `202 Accepted` with
`{"accepted":true,"action":"start"}`.

```sh
curl -fsS -X POST \
  -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/vm/start
```

### `POST /api/v1/vm/stop`

Requests runtime stop.

Use this only for runtime products where the caller is allowed to control the
target runtime.
The request body is empty. Success returns `202 Accepted` with
`{"accepted":true,"action":"stop"}`.

```sh
curl -fsS -X POST \
  -H "Authorization: Bearer $TOKEN" \
  http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/vm/stop
```

### `GET /readyz`

Reports provider readiness.

When `BUS_EVENTS_LISTENER_REQUIRED=1`, readiness is unhealthy until required
VM, usage, and billing response streams are connected.

```sh
curl -fsS http://127.0.0.1:8085/readyz
```

A ready provider returns `200 OK` with `{"ok":true}`. If required Events
listeners are unavailable, readiness returns a non-2xx status with a JSON error
body.

### `--backend <static|events>`

Selects the VM backend.

Use `static` for deterministic local checks. Use `events` for Bus Events
request/reply mode. The default is deployment-configured; standalone local
checks usually use `static`, while production runtime control uses `events`.

Static local provider:

```sh
BUS_VM_JWT_SECRET=not-a-secret-local-development-hs256-key \
bus-api-provider-vm --addr 127.0.0.1:8085 --backend static
```

For direct standalone curl checks against that static provider, mint the local
token with the same HS256 secret and scopes:

```sh
TOKEN="$(BUS_AUTH_HS256_SECRET=not-a-secret-local-development-hs256-key bus operator token --format token issue --local --audience ai.hg.fi/api --scope 'vm:read vm:write')"
```

Events-backed provider:

```sh
BUS_VM_JWT_SECRET=dev-secret \
BUS_API_TOKEN="$(cat ./local/vm-provider.token)" \
bus-api-provider-vm \
  --addr 127.0.0.1:8085 \
  --backend events \
  --events-url http://127.0.0.1:8081 \
  --usage-backend events \
  --billing-backend events
```

The provider token needs `vm:read` and `vm:write` for VM request/reply events.
Add `usage:write` when `--usage-backend events` is enabled and
`billing:entitlement:check` when `--billing-backend events` is enabled.

### `--events-url <url>`

Sets the Bus Events API URL when Events mode is enabled.

Provide the provider token through deployment-managed configuration such as
`BUS_API_TOKEN`.
`--backend events`, `--billing-backend events`, and `--usage-backend events`
require `--events-url` or `BUS_EVENTS_API_URL` plus a provider token with the
matching VM, billing, and usage event scopes.

### `--billing-backend <none|events>`

Enables billing entitlement checks for lifecycle write requests.

Denied requests return HTTP `402` with billing setup or quota guidance.
Default is `none`; use `events` for paid VM lifecycle plans.

### `--usage-backend <none|events|memory>`

Enables runtime lifecycle usage records through `bus-integration-usage`.

Start and stop requests can record requested, finished, and failed lifecycle
events with the stable account UUID.
Default is `none`. Use `events` when usage should flow to
`bus-integration-usage`, or `memory` for deterministic local checks that should
not publish usage records to a shared Events API.

Common errors use `{"error":{"type":"...","message":"..."}}`. Missing or
invalid bearer tokens return `401 invalid_auth`, missing scopes return
`401`/`403` depending gateway policy, entitlement denial returns `402`, event
backend unavailability returns `503`, and malformed integration responses
return `502`.
For `GET /api/v1/vm/status`, callers should fix authentication or `vm:read` scope errors
and retry later on backend `503`. For `POST /api/v1/vm/start` and
`POST /api/v1/vm/stop`, callers
also need `vm:write`; `402` means billing setup or quota action is required
before retrying the lifecycle request.

### Local Compose Stack

The BusDK superproject `compose.yaml` starts this provider as `bus-vm` with
`--backend static`, `--usage-backend memory`, and `--billing-backend none`.
Nginx exposes it at `/api/v1/vm/*` on the local API port. The static backend is
for deterministic local AI Platform checks, including `/api/v1/vm/status`
returning provider `static`; deployments that control real runtimes should use
Events mode with a VM integration backend.

### Sources

- [bus-vm](./bus-vm)
- [bus-api-provider-llm](./bus-api-provider-llm)
- [bus-integration-usage](./bus-integration-usage)
