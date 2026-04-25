---
title: bus-api-provider-events — Bus Events API provider
description: bus-api-provider-events exposes JWT-secured event publish and stream endpoints for Bus event-oriented integrations.
---

## `bus-api-provider-events` — Bus Events API provider

`bus-api-provider-events` is the HTTP controller for the public Bus Events API.
It accepts authenticated event publishing requests and exposes authenticated
event streams. Functional providers remain event-oriented and do not implement
HTTP controllers themselves.

### API

```text
POST /api/v1/events
GET  /api/v1/events/stream?name=<event-name>&delivery=broadcast
GET  /api/v1/events/stream?name=<event-name>&delivery=work&group=<group>&consumer=<consumer>
```

Publishing requires `events:send`. Listening requires `events:listen`. The
provider verifies the JWT and derives account identity from `sub`; callers do
not provide account IDs for authorization.

The internal event backend is selectable. `memory` is non-durable and intended
for local development and tests. Redis is available through Redis Streams with
atomic `XADD` operations. PostgreSQL is available as a disposable durable event
log that creates its minimal tables at startup. These backends plug in behind
the same event bus boundary, so functional providers and HTTP controllers do
not change when the backend changes.

Use `delivery=broadcast` when multiple listeners must all see the same event.
Use `delivery=work` with a shared `group` when listeners are competing workers
and exactly one of them should receive each matching event. If `group` is
omitted in work mode, the provider uses `default`.

The PostgreSQL backend is intentionally migration-free. It creates `bus_events`
and `bus_event_group_cursors` when missing, and the operator may destroy and
recreate the database from scratch. PostgreSQL uses `LISTEN/NOTIFY` to wake
listeners quickly, with SQL polling as the fallback and SQL transactions as the
source of truth.

### Development

For local development, use an obvious non-secret JWT secret and locally
generated test tokens only. Do not commit real deployment secrets.
