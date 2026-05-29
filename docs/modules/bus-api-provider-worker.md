---
title: bus-api-provider-worker
description: "bus-api-provider-worker will expose worker identity and worker status through the Bus API layer."
---

## `bus-api-provider-worker` — worker API provider

`bus-api-provider-worker` is the current scaffold for the target plural
`bus-api-provider-workers` API provider. The final product topology uses the
plural provider name, but this checkout currently hosts the first provider
slice while the repository/module rename remains unfinished.

Current status: the provider can accept local worker-control HTTP requests,
publish canonical `bus.workers.*` Events to
[`bus-api-provider-events`](./bus-api-provider-events), and serve a bounded
in-process projection from returned worker Events. The standalone provider can
listen to the Events API stream for `bus.workers.list.response` and
`bus.workers.status.snapshot`, replay existing evidence, and then follow new
worker responses. Those Events are the bridge toward a remote
`bus-integration-workers` service. Durable read projections, Bus API
registration, and final list/show/status contracts are still unfinished.

The first scaffold endpoints are:

- `GET /api/v1/workers` publishes a correlated
  `bus.workers.list.request`, returns the current projection, and asks worker
  environments to respond with `bus.workers.list.response`
- `POST /api/v1/workers` publishes `bus.workers.create.request`
- `POST /api/v1/workers/{id}/pause` publishes `bus.workers.pause.request`
- `POST /api/v1/workers/{id}/resume` publishes `bus.workers.resume.request`
- `POST /api/v1/workers/{id}/assign` publishes `bus.workers.assign.request`

One list request may receive responses from multiple local or remote worker
environments. Each response should carry the request correlation id,
environment identity, and a bounded worker array so the provider can merge
local and remote evidence into one list view.

The scaffold keeps that view in process. It can take `environment_id` from the
response payload or from the Bus Events environment metadata when an individual
worker item does not include its own environment identity.

It is expected to connect the future `bus-workers` ownership layer with Bus
API resources for:

- configured worker identities
- worker profile and capability metadata
- active assignments and status views
- worker-related non-secret validation rules

Treat the singular module path as scaffolding until the plural
`bus-api-provider-workers` module path is created or the checkout is renamed.
