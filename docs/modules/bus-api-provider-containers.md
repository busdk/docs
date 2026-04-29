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

The public API is account-isolated. The provider derives the owner account from
the JWT `sub`; callers cannot choose an account ID in request metadata. Users
can list, read, and delete only runs owned by their own account.

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

Container plans can use the same billing quota system as LLM plans. A common
meter is `bus_container_runtime_seconds`, produced from successful
`container_run_finished` usage events. Operators can configure per-minute,
hourly, daily, weekly, monthly, or total container runtime limits in the
billing catalog or quota config.

The internal runner lifecycle endpoints are for trusted service operations.
They require a JWT with audience `ai.hg.fi/internal` and scope
`container:admin`, and are not exposed through the end-user `bus containers`
command surface. In events mode they publish
`bus.containers.runner.status.request`,
`bus.containers.runner.start.request`, or
`bus.containers.runner.delete.request` and wait for the matching response
events.

`POST /api/v1/containers/runs` executes a foreground request through the
configured backend. End users normally call it through `bus containers run`,
which sends a `profile`, `args`, and optional timeout. The API also accepts an
explicit `image` and `command`. Successful responses include the runner name,
image, args, exit code, stdout, stderr, duration, and runner status.

`DELETE /api/v1/containers/runs/{run_id}` cancels or removes a user-owned run
when the backend supports it. It must not remove runs owned by other accounts.
Infrastructure runner deletion is separate and uses the internal runner
endpoint with internal audience and admin scope.

When started with `--usage-backend events`, container runs are also reported
through `bus-integration-usage`. The provider records
`container_run_requested` before backend delegation and then records
`container_run_finished` or `container_run_failed` with request/run IDs, stable
account UUID, profile, image, duration, exit code, runner name, and failure
details when available.

### End-User Access

Approved users request a Bus API token with the container scopes their plan and
approval policy allow:

```sh
bus auth token --scope "container:read container:run container:delete billing:read"
```

The token can be used by `bus containers` and by direct HTTP clients. Billing
setup may still be required before run creation succeeds.

### Operator Notes

Run this provider with Events listener retry enabled in production so startup
ordering and Events API restarts do not leave request/reply paths broken:

```sh
BUS_EVENTS_LISTENER_RETRY=1
BUS_EVENTS_LISTENER_REQUIRED=1
```

Use internal runner endpoints only from trusted service or operator tooling.
End-user container APIs are deliberately separate from runner lifecycle
administration.

### Sources

- [bus-api-provider-containers README](../../../bus-api-provider-containers/README.md)
- [bus-containers](./bus-containers)
- [bus-integration-usage](./bus-integration-usage)
- [bus-api-provider-billing](./bus-api-provider-billing)
