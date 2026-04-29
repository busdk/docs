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

### API

```text
GET  /api/v1/vm/status
POST /api/v1/vm/start
POST /api/v1/vm/stop
GET  /readyz
```

Requests use Bearer JWT authentication with audience `ai.hg.fi/api` by default.
Status requires `vm:read`; lifecycle requests require `vm:write`. The provider
can run with a deterministic static backend for local tests or in Bus Events
request/reply mode. In events mode, start the provider with `--backend events`
and `--events-url`; `BUS_API_TOKEN` is a normal Bus API JWT with audience
`ai.hg.fi/api` and the VM domain scopes needed for the events it sends and
receives. The provider process owns the response listener and
correlates responses to in-flight HTTP requests.
When `BUS_EVENTS_LISTENER_REQUIRED=1`, `GET /readyz` reports unhealthy until
the required VM, usage, and billing response streams are connected.

Commercial deployments should add `--billing-backend events` or
`BUS_VM_BILLING_BACKEND=events`. With that backend enabled, lifecycle write
requests check `vm:write` entitlement through
`bus.billing.entitlement.check.request` before recording usage or sending any
VM worker request. A missing payment method, inactive subscription, or quota
exhaustion returns HTTP `402` with a `bus billing ...` command hint. Status
reads stay controlled by `vm:read` and are not quota-gated.

Start the provider with `--usage-backend events` to report runtime lifecycle
operations through `bus-integration-usage`. Start/stop requests record
`runtime_start_requested`, `runtime_start_finished`,
`runtime_start_failed`, `runtime_stop_requested`,
`runtime_stop_finished`, or `runtime_stop_failed` with the stable account UUID
and request/action metadata. Status reads are not treated as billable lifecycle
events.

### Sources

- [bus-api-provider-vm README](../../../bus-api-provider-vm/README.md)
