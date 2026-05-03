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

### `GET /api/v1/vm/status`

Returns user-visible runtime status.

Status reads are not quota-gated and are not treated as billable lifecycle
events.
The request body is empty. Success returns `200 OK` with
`{"status":{"state":"ready","provider":"...","details":{}}}`.

### `POST /api/v1/vm/start`

Requests runtime start.

With billing enabled, the provider checks `vm:write` entitlement before sending
worker requests or recording lifecycle usage.
The request body is empty. Success returns `202 Accepted` with
`{"accepted":true,"action":"start"}`.

### `POST /api/v1/vm/stop`

Requests runtime stop.

Use this only for runtime products where the caller is allowed to control the
target runtime.
The request body is empty. Success returns `202 Accepted` with
`{"accepted":true,"action":"stop"}`.

### `GET /readyz`

Reports provider readiness.

When `BUS_EVENTS_LISTENER_REQUIRED=1`, readiness is unhealthy until required
VM, usage, and billing response streams are connected.

### `--backend <static|events>`

Selects the VM backend.

Use `static` for deterministic local checks. Use `events` for Bus Events
request/reply mode. The default is deployment-configured; standalone local
checks usually use `static`, while production runtime control uses `events`.

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
