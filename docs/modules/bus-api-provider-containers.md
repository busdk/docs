---
title: bus-api-provider-containers — container API provider
description: bus-api-provider-containers exposes user-owned container status and run lifecycle endpoints.
---

## `bus-api-provider-containers` — container API provider

`bus-api-provider-containers` is the server-side provider for user-owned
container APIs. It owns cloud-neutral REST endpoints for container status and
run lifecycle requests.

In events mode, the provider sends container lifecycle requests through the Bus
Events API. A deployment can pair it with `bus-integration-upcloud` for
UpCloud runner lifecycle work and `bus-integration-ssh-runner` for SSH script
execution.

### API

```text
GET    /api/v1/containers/status
POST   /api/v1/containers/runs
DELETE /api/v1/containers/runs/{run_id}
GET    /api/internal/containers/runner
POST   /api/internal/containers/runner
DELETE /api/internal/containers/runner
GET    /readyz
```

Requests use Bearer JWT authentication with audience `ai.hg.fi/api` by default.
Status requires `container:read`; run creation requires `container:run`; delete
requires `container:delete`. The provider can run with a deterministic static
backend for local tests or in Bus Events request/reply mode. In events mode,
start the provider with `--backend events` and `--events-url`; `BUS_API_TOKEN`
is a normal Bus API JWT with audience `ai.hg.fi/api` and the container domain
scopes needed for the events it sends and receives. The
provider process owns the response listener and correlates responses to
in-flight HTTP requests.
When `BUS_EVENTS_LISTENER_REQUIRED=1`, `GET /readyz` reports unhealthy until
the required container, usage, and billing response streams are connected.

Commercial deployments should add `--billing-backend events` or
`BUS_CONTAINERS_BILLING_BACKEND=events`. With that backend enabled,
`POST /api/v1/containers/runs` checks `container:run` entitlement through
`bus.billing.entitlement.check.request` before recording usage or sending any
container worker request. A missing payment method, inactive subscription, or
quota exhaustion returns HTTP `402` with a `bus billing ...` command hint.
Status and delete endpoints remain protected by JWT scopes and account
ownership checks, not by quota checks.

The internal runner lifecycle endpoints are for service operations during the
old api-proxy replacement. They require a JWT with audience
`ai.hg.fi/internal` and scope `container:admin`, and are not exposed through
the end-user `bus containers` command surface. In events mode they publish
`bus.containers.runner.status.request`,
`bus.containers.runner.start.request`, or
`bus.containers.runner.delete.request` and wait for the matching response
events.

`POST /api/v1/containers/runs` executes a foreground request through the
configured backend. End users normally call it through `bus containers run`,
which sends a `profile`, `args`, and optional timeout. The API also accepts an
explicit `image` and `command`. Successful responses include the runner name,
image, args, exit code, stdout, stderr, duration, and runner status.

When started with `--usage-backend events`, container runs are also reported
through `bus-integration-usage`. The provider records
`container_run_requested` before backend delegation and then records
`container_run_finished` or `container_run_failed` with request/run IDs, stable
account UUID, profile, image, duration, exit code, runner name, and failure
details when available.

### Sources

- [bus-api-provider-containers README](../../../bus-api-provider-containers/README.md)
