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

The provider verifies the normal Bus API JWT audience `ai.hg.fi/api` and derives
account identity from `sub`; callers do not provide account IDs for
authorization. Unprotected event names require `events:send` to publish and
`events:listen` to stream.

Protected Bus integration events use domain scopes. VM events use `vm:read` or
`vm:write`, public container events use scopes such as `container:read` and
`container:run`, protected container runner administration events use
`container:admin`, and usage collector events use scopes such as `usage:read`
or `usage:delete`. This keeps event access aligned with the domain API
permissions instead of exposing broad event-pattern scopes to end users.
Wildcard streams are rejected by default because the provider cannot safely
prove that one token may receive every future protected event.

`bus work` events use the protected `bus.work.*` namespace. Those events are
generic durable work streams and require dedicated scopes such as `work:send`,
`work:read`, `work:reply`, `work:claim`, and `work:admin` instead of broad
event scopes. Development task events use the separate `bus.dev.task.*`
namespace with `dev:task:*` scopes. Future deployments may further qualify
these scopes by owner or repository, for example `work:claim:acme/payroll` or
`dev:task:claim:busdk/bus-ledger`.

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
Streams follow new events by default. Add `replay=true` to include existing
matching events before following, and add `follow=false` when the caller wants a
bounded snapshot that returns after replay. Work delivery groups can claim
queued matching events that were published before the worker started.

The PostgreSQL backend is intentionally migration-free. It creates `bus_events`
and `bus_event_group_cursors` when missing, and the operator may destroy and
recreate the database from scratch. PostgreSQL uses `LISTEN/NOTIFY` to wake
listeners quickly, with SQL polling as the fallback and SQL transactions as the
source of truth.

### Development

For local development, use an obvious non-secret JWT secret and locally
generated test tokens only. Plain secret values are raw text even when they look
like base64; use `base64:<value>` only for an intentionally base64-encoded
secret. Do not commit real deployment secrets.
