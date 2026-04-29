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

### `POST /api/v1/vm/start`

Requests runtime start.

With billing enabled, the provider checks `vm:write` entitlement before sending
worker requests or recording lifecycle usage.

### `POST /api/v1/vm/stop`

Requests runtime stop.

Use this only for runtime products where the caller is allowed to control the
target runtime.

### `GET /readyz`

Reports provider readiness.

When `BUS_EVENTS_LISTENER_REQUIRED=1`, readiness is unhealthy until required
VM, usage, and billing response streams are connected.

### `--backend <static|events>`

Selects the VM backend.

Use `static` for deterministic local checks. Use `events` for Bus Events
request/reply mode.

### `--events-url <url>`

Sets the Bus Events API URL when Events mode is enabled.

Provide the provider token through deployment-managed configuration such as
`BUS_API_TOKEN`.

### `--billing-backend <none|events>`

Enables billing entitlement checks for lifecycle write requests.

Denied requests return HTTP `402` with billing setup or quota guidance.

### `--usage-backend <none|events>`

Enables runtime lifecycle usage records through `bus-integration-usage`.

Start and stop requests can record requested, finished, and failed lifecycle
events with the stable account UUID.

### Sources

- [bus-vm](./bus-vm)
- [bus-api-provider-llm](./bus-api-provider-llm)
- [bus-integration-usage](./bus-integration-usage)
