---
title: bus-integration-usage — usage event worker
description: bus-integration-usage records, lists, and deletes usage events through the Bus Events integration worker model.
---

## Overview

`bus-integration-usage` is the event-driven usage worker for Bus billing and
lifecycle records. API providers and trusted backend services publish usage
requests through Bus Events; this worker validates the request, writes or reads
usage storage, and publishes a correlated response event.

This module is not an end-user CLI for browsing usage. It is an operator-facing
service process used by Bus API deployments. Keeping usage storage in this
worker lets model, VM, container, and future API providers report billable work
without each service opening usage database credentials directly.

For commercial deployments, run it with durable PostgreSQL storage and a
billing export policy. The usage worker is the bridge between operational usage
events and billing/quota accounting.

## Event Contract

The worker consumes these request events and emits the matching response:

```text
bus.usage.record.request  -> bus.usage.record.response
bus.usage.list.request    -> bus.usage.list.response
bus.usage.delete.request  -> bus.usage.delete.response
```

Record requests use JSON with `event_type`, optional `event_id`, optional
`account_id`, optional `occurred_at`, and optional `data`. Producers should set
a stable `event_id` for retried billable actions so duplicate delivery does not
create duplicate usage rows.

Accepted `event_type` values are the Bus billing taxonomy used by the AI
Platform replacement: `request_started`, `runtime_ready`,
`backend_request_started`, `backend_request_finished`, `usage_recorded`,
`usage_missing`, `request_failed`, `client_aborted`,
`container_run_requested`, `container_run_finished`, `container_run_failed`,
`runtime_start_requested`, `runtime_start_finished`, `runtime_start_failed`,
`runtime_stop_requested`, `runtime_stop_finished`, and
`runtime_stop_failed`. The worker also accepts the transitional `container.run`
record type until container usage recording is fully split into request,
finish, and failure events. If `account_id` is present, it must be a UUID.

List and delete requests use `before`, `page`, and `page_size` pagination. The
worker returns deterministic pages ordered by usage occurrence time and storage
ID.

Commercial deployments can enable automatic billing export so any usage metric
that appears in a plan can be charged and quota-counted. The worker evaluates
accepted records against a provider-neutral policy and emits
`bus.billing.usage.export.request` for matching rules. The built-in default
policy maps LLM `usage_recorded` `data.total_tokens` to `llm:proxy` /
`bus_llm_tokens`, and successful `container_run_finished` `data.duration_ms`
to `container:run` / `bus_container_runtime_seconds` using rounded-up seconds.
Failed, aborted, or unmapped events are not billed unless an operator adds an
explicit policy rule.

Use explicit policy rules when a product plan charges or limits a new metric.
The same mechanism supports LLM tokens, container runtime seconds, and future
usage dimensions such as storage, files, jobs, or API calls.

## Running The Worker

Set the Events API URL and bearer token before starting the worker. The token
is supplied through `BUS_API_TOKEN` and must be a Bus API JWT with audience
`ai.hg.fi/api`. It must include the usage domain scopes for the events this
worker listens to and emits, such as `usage:write`, `usage:read`, and
`usage:delete`. If that token is issued as an internal service token, set its
TTL long enough for the worker lifetime or rotate/restart the worker before
expiry.

For local development, use the memory backend:

```sh
export BUS_EVENTS_API_URL=http://127.0.0.1:8080/api/v1/events
export BUS_API_TOKEN="$(bus auth token --scope "usage:write usage:read usage:delete")"
bus-integration-usage \
  --usage-backend memory \
  --events-url "$BUS_EVENTS_API_URL"
```

For deployed collection, use PostgreSQL:

```sh
export BUS_EVENTS_API_URL=https://api.example.test/api/v1/events
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-integration-usage \
  --usage-backend postgres \
  --events-url "$BUS_EVENTS_API_URL"
```

Enable the default LLM and container export rules with
`--billing-export default` or `BUS_USAGE_BILLING_EXPORT=default`. Use
`--billing-export file --billing-export-policy <path>` or
`BUS_USAGE_BILLING_EXPORT_POLICY` when plans include additional usage metrics.
The policy file is JSON with a `rules` array. Each rule matches a usage event
type and writes one billing export feature/meter:

```json
{"rules":[{"event_type":"usage_recorded","feature":"llm:proxy","meter_event_name":"bus_llm_tokens","quantity_field":"total_tokens"}]}
```

Invalid JSON, missing `event_type`, missing `feature`, or missing
`meter_event_name` makes startup fail.

Use only non-secret local examples in documentation. Real database URLs and Bus
API tokens must come from deployment secrets or local untracked configuration.

The worker can run as its own process or be registered into a shared
`bus-integration` host through the Go `usageintegration.Registration(...)`
function.
Successful startup connects to the Events API and begins waiting for usage
events. Verify the path by publishing a usage record request and checking that
the corresponding usage response or stored usage event appears in the usage
collector API.

### Billing Export Rules

The default export policy maps successful LLM token usage to feature
`llm:proxy` and meter `bus_llm_tokens`. It maps successful container run
duration to feature `container:run` and meter
`bus_container_runtime_seconds`, rounded up to whole seconds.

Each exported usage request carries an idempotency key. The billing integration
uses that key to avoid double-counting quota buckets and to avoid duplicate
payment-provider meter events after retries.

### Collector API

`bus-api-provider-usage` exposes the internal collector feed for trusted
backend jobs. It is separate from this worker. The provider gives collectors a
JWT-secured HTTP read/delete interface, while this integration owns the event
worker behavior and storage access used by API providers.

### Sources

- [bus-integration](./bus-integration)
- [bus-api-provider-usage](./bus-api-provider-usage)
- [bus-integration-billing](./bus-integration-billing)
