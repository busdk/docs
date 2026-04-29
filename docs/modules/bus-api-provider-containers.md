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

### Authentication

Public endpoints use Bearer JWT authentication with audience `ai.hg.fi/api`.
The provider derives the account from JWT `sub`.

`container:read` allows status reads. `container:run` allows run creation.
`container:delete` allows deleting owned runs.

Internal runner endpoints use audience `ai.hg.fi/internal` with
`container:admin`.

### `GET /api/v1/containers/status`

Returns container status and runs visible to the authenticated account.

With `--backend events`, the provider sends
`bus.containers.status.request` and waits for
`bus.containers.status.response`.

### `POST /api/v1/containers/runs`

Starts one foreground user-owned container run.

End users normally call this through `bus containers run`. The request can use
a named `profile` with `args`, or an explicit `image` and `command`.

Successful responses include runner name, image, arguments, exit code, stdout,
stderr, duration, and runner status.

With `--billing-backend events`, the provider checks `container:run`
entitlement before usage recording or backend delegation. Billing failures
return HTTP `402` with `bus billing ...` guidance.

With `--usage-backend events`, the provider records
`container_run_requested`, then `container_run_finished` or
`container_run_failed`.

With `--backend events`, the provider sends `bus.containers.run.request` and
waits for `bus.containers.run.response`.

### `DELETE /api/v1/containers/runs/{run_id}`

Deletes or cancels one user-owned container run when the backend supports it.

The provider must reject attempts to delete runs owned by another account.
Infrastructure runner deletion uses the internal runner endpoint instead.

With `--backend events`, the provider sends
`bus.containers.delete.request` and waits for
`bus.containers.delete.response`.

### `GET /api/internal/containers/runner`

Returns protected operational status for the configured runner.

This endpoint is for trusted service or operator tooling, not end-user
container clients. With `--backend events`, it sends
`bus.containers.runner.status.request`.

### `POST /api/internal/containers/runner`

Starts and bootstraps the configured runner for internal operations.

With `--backend events`, it sends
`bus.containers.runner.start.request`.

### `DELETE /api/internal/containers/runner`

Deletes the configured runner for internal cleanup.

With `--backend events`, it sends
`bus.containers.runner.delete.request`.

### `GET /readyz`

Reports provider readiness.

When `BUS_EVENTS_LISTENER_REQUIRED=1`, readiness is unhealthy until required
container, usage, and billing response streams are connected.

### Billing And Quotas

Container plans use the same billing quota system as LLM plans. A common meter
is `bus_container_runtime_seconds`, produced from successful
`container_run_finished` usage events.

Operators can configure minute, hour, day, week, month, or total runtime
limits in the billing catalog or quota config.

### `--backend <static|events>`

Selects the container backend.

Use `static` for deterministic local checks. Use `events` for Bus Events
request/reply mode.

### `--events-url <url>`

Sets the Bus Events API URL used when `--backend events`, `--usage-backend
events`, or `--billing-backend events` is enabled.

Provide the provider's Events token through deployment-managed configuration,
such as `BUS_API_TOKEN`. Do not pass bearer tokens as command-line arguments.

### `--usage-backend <none|events>`

Enables usage recording through Events.

Commercial deployments should use `events` so accepted container work is
available for billing and quota accounting.

### `--billing-backend <none|events>`

Enables billing entitlement checks before container run creation.

Use `events` with `bus-integration-billing` for paid container plans.

### `BUS_EVENTS_LISTENER_REQUIRED`

When set to `1`, readiness requires the Events response listeners needed by the
enabled backends.

Use it in production so startup ordering problems do not leave the provider
active but unable to complete request/reply work.

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

- [bus-containers](./bus-containers)
- [bus-integration-usage](./bus-integration-usage)
- [bus-api-provider-billing](./bus-api-provider-billing)
