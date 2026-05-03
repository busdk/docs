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
ID. Delete is bounded by the same `before` timestamp and deletes the selected
page of records older than or equal to that cutoff. Collectors should use a
fixed `before` value and repeatedly process/delete `page=1` to avoid offset
shifts.
`before` is an RFC3339 timestamp; when omitted, the provider uses the current
time. `page` defaults to `1` and must be positive. `page_size` defaults to
`1000` and is capped at `10000`.

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

Set the Events API service root URL and bearer token before starting the worker. The token
is supplied through `BUS_API_TOKEN` and must be a Bus API JWT with audience
`ai.hg.fi/api`. It must include the usage domain scopes for the events this
worker listens to and emits, such as `usage:write`, `usage:read`, and
`usage:delete`. If that token is issued as an internal service token, set its
TTL long enough for the worker lifetime or rotate/restart the worker before
expiry.

For local development without collector verification, use the memory backend:

```sh
export BUS_EVENTS_API_URL=http://127.0.0.1:8081
export BUS_API_TOKEN="$(bus auth token --audience ai.hg.fi/api --scope "usage:write usage:read usage:delete")"
bus-integration-usage \
  --usage-backend memory \
  --events-url "$BUS_EVENTS_API_URL"
```

The memory worker is connected when it stays running without Events
authentication errors. Use the PostgreSQL path below when you need to verify
stored records through `bus-api-provider-usage`.

For local PostgreSQL collection, use a local DSN with `sslmode=disable`. Create
an untracked local worker token before starting the worker; include
`billing:usage:export` too if billing export will be enabled.

```sh
mkdir -p ./local
bus operator token \
  --api-url http://127.0.0.1:8080/local-dev/v1 \
  --internal-key-file ./local/auth-internal-shared-key \
  --format token \
  issue \
  --subject usage-worker \
  --audience ai.hg.fi/api \
  --scope "usage:write usage:read usage:delete billing:usage:export" \
  --ttl 1h > ./local/bus-usage-worker.token

export BUS_EVENTS_API_URL=http://127.0.0.1:8081
export BUS_API_TOKEN="$(cat ./local/bus-usage-worker.token)"
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-integration-usage \
  --usage-backend postgres \
  --events-url "$BUS_EVENTS_API_URL"
```

For hosted deployments, provide `BUS_USAGE_DATABASE_URL` from a secret manager
with a TLS-enabled PostgreSQL URL such as
`postgres://user:password@postgres.example.internal:5432/bus_usage?sslmode=require`.

Enable the default LLM and container export rules with
`--billing-export default` or `BUS_USAGE_BILLING_EXPORT=default`. Use
`--billing-export file --billing-export-policy <path>` or
`BUS_USAGE_BILLING_EXPORT_POLICY` when plans include additional usage metrics.
The worker token also needs permission to publish billing usage export events,
typically `billing:usage:export`, whenever billing export is enabled.
The policy file is JSON with a `rules` array. Each rule matches a usage event
type and writes one billing export feature/meter:

```json
{"rules":[{"event_type":"usage_recorded","feature":"llm:proxy","meter_event_name":"bus_llm_tokens","quantity_field":"total_tokens"}]}
```

Invalid JSON, missing `event_type`, missing `feature`, or missing
`meter_event_name` makes startup fail.
`quantity_field` is read from the usage event `data` object. The value must be
a positive integer or JSON number in the meter's unit; missing, non-numeric, or
non-positive values prevent that record from being exported.

Use only non-secret local examples in documentation. Real database URLs and Bus
API tokens must come from deployment secrets or local untracked configuration.

The worker can run as its own process or be registered into a shared
`bus-integration` host through the Go `usageintegration.Registration(...)`
function.
Successful startup connects to the Events API service root and begins waiting
for usage events. Verify the path by publishing a usage record request and
checking that the stored usage event appears in the usage collector API.

For example, publish a local record request through the Events API:

```sh
curl -fsS -X POST \
  -H "Authorization: Bearer $BUS_API_TOKEN" \
  -H "Content-Type: application/json" \
  "$BUS_EVENTS_API_URL/api/v1/events" \
  -d '{"name":"bus.usage.record.request","correlation_id":"usage-doc-check","payload":{"event_type":"usage_recorded","event_id":"usage-doc-check","account_id":"00000000-0000-4000-8000-000000000001","data":{"total_tokens":1}}}'
```

The stored record should be visible through `bus-api-provider-usage` when
PostgreSQL storage is enabled.

To verify storage through the collector API, the worker and
`bus-api-provider-usage` must share the same PostgreSQL database. Query the
provider with a trusted usage collector token whose audience is
`ai.hg.fi/internal` and whose scopes include `usage:read`:

```sh
bus operator token \
  --api-url http://127.0.0.1:8080/local-dev/v1 \
  --internal-key-file ./local/auth-internal-shared-key \
  --format token \
  issue \
  --subject usage-collector \
  --audience ai.hg.fi/internal \
  --scope "usage:read" \
  --ttl 1h > ./local/usage-collector.token

curl -fsS \
  -H "Authorization: Bearer $(cat ./local/usage-collector.token)" \
  "http://127.0.0.1:8082/api/internal/usage-events?page=1&page_size=10"
```

The response should include an item with `event_id` `usage-doc-check` when the
usage worker and collector API share the same PostgreSQL database.

The BusDK superproject `compose.yaml` runs this worker as `bus-usage-worker`
with `--usage-backend postgres` and `BUS_USAGE_DATABASE_URL` pointing at the
local PostgreSQL service. It connects to `http://bus-events:8081` with a local
service token minted by `bus-operator-token`, so LLM and container providers
can record usage through Events while the collector feed remains available
through `bus-api-provider-usage`.

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

### Using from `.bus` files

Inside a `.bus` file, write the module target without the `bus` prefix:

```bus
# same as: bus integration usage --usage-backend memory --events-url "$BUS_EVENTS_API_URL"
integration usage --usage-backend memory --events-url "$BUS_EVENTS_API_URL"
```

### Sources

- [bus-integration](./bus-integration)
- [bus-api-provider-usage](./bus-api-provider-usage)
- [bus-integration-billing](./bus-integration-billing)
