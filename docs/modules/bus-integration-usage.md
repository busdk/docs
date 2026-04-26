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

List and delete requests use `before`, `page`, and `page_size` pagination. The
worker returns deterministic pages ordered by usage occurrence time and storage
ID.

## Running The Worker

For local development, use the memory backend:

```sh
bus-integration-usage \
  --usage-backend memory \
  --events-url "$BUS_EVENTS_API_URL" \
  --events-token "$BUS_EVENTS_TOKEN"
```

For deployed collection, use PostgreSQL:

```sh
BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable' \
bus-integration-usage \
  --usage-backend postgres \
  --events-url "$BUS_EVENTS_API_URL" \
  --events-token "$BUS_EVENTS_TOKEN"
```

Use only non-secret local examples in documentation and tests. Real database
URLs and Events API tokens must come from deployment secrets or local untracked
configuration.

The worker can run as its own process or be registered into a shared
`bus-integration` host through the Go `usageintegration.Registration(...)`
function.

### Sources

- [bus-integration-usage README](../../../bus-integration-usage/README.md)
- [bus-integration](./bus-integration.md)
- [bus-api-provider-usage](./bus-api-provider-usage.md)
