---
title: bus-api-provider-containers — container API provider
description: bus-api-provider-containers is the planned cloud-neutral Bus API provider for user-owned container status and run lifecycle endpoints.
---

## `bus-api-provider-containers` — container API provider

`bus-api-provider-containers` is the server-side provider for user-owned
container APIs. It owns cloud-neutral REST endpoints for container status and
run lifecycle requests.

Provider-specific cloud implementation details do not belong here. UpCloud
behavior is planned for `bus-integration-upcloud`, which will consume Bus Events
and publish result events.

### API

```text
GET    /api/v1/containers/status
POST   /api/v1/containers/runs
DELETE /api/v1/containers/runs/{run_id}
GET    /readyz
```

Requests use Bearer JWT authentication with audience `ai.hg.fi/api` by default.
Status requires `container:read`; run creation requires `container:run`; delete
requires `container:delete`. The provider can run with a deterministic static
backend for local tests or in Bus Events request/reply mode. In events mode,
start the provider with `--backend events`, `--events-url`, and `--events-token`;
the provider process owns the response listener and correlates responses to
in-flight HTTP requests.

`POST /api/v1/containers/runs` executes a foreground request through the
configured backend. End users normally call it through `bus containers run`,
which sends a `profile`, `args`, and optional timeout. The API also accepts an
explicit `image` and `command`. Successful responses include the runner name,
image, args, exit code, stdout, stderr, duration, and runner status.

When started with `--usage-backend events`, successful container runs are also
reported through `bus-integration-usage` by sending
`bus.usage.record.request` and waiting for `bus.usage.record.response`.

### Sources

- [bus-api-provider-containers README](../../../bus-api-provider-containers/README.md)
