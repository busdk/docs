---
title: bus-api-provider-events — Bus Events API provider
description: bus-api-provider-events exposes JWT-secured event publish and stream endpoints for Bus event-oriented integrations.
---

## `bus-api-provider-events` — Bus Events API provider

`bus-api-provider-events` is the HTTP controller for the public Bus Events API.
It accepts authenticated event publishing requests and exposes authenticated
event streams. Functional providers remain event-oriented and do not implement
HTTP controllers themselves.

Bus API providers and integrations use Events for request/reply workflows such
as runtime wake-up, container runner work, billing status, usage export, and
Stripe provider calls. End users may also use event APIs when the deployment
grants the required domain scopes, but event access is still account- and
scope-limited.

### Authentication

The provider verifies the normal Bus API JWT audience `ai.hg.fi/api`.
Send the token as `Authorization: Bearer <JWT>` on publish and stream requests.
For local development with the same HS256 secret configured on the Events
provider, mint a token with the narrow scopes needed by the event namespace:

```sh
mkdir -p ./local
BUS_AUTH_HS256_SECRET=dev-secret \
bus operator token --format token issue --local \
  --subject events-local \
  --audience ai.hg.fi/api \
  --scope "events:send events:listen" \
  --ttl 1h > ./local/events.token
```

Production deployments should use the normal auth or service-token flow and
grant domain scopes such as `llm:proxy`, `container:run`, or `billing:read`
instead of broad event scopes whenever the event namespace is protected.

The account is derived from JWT `sub`. Callers do not provide account IDs for
authorization.

Unprotected event names require `events:send` to publish and `events:listen`
to stream.

The provider stamps the event account from the JWT. Caller-supplied account
metadata is not trusted for authorization. Streams only return events the token
is allowed to receive, and user tokens cannot subscribe to unrelated accounts.

Protected Bus integration events use domain scopes. VM events use `vm:read` or
`vm:write`, public container events use scopes such as `container:read` and
`container:run`, protected container runner administration events use
`container:admin`, and usage collector events use scopes such as `usage:read`
or `usage:delete`. This keeps event access aligned with the domain API
permissions instead of exposing broad event-pattern scopes to end users.
Billing events are protected the same way: public status/setup events use
`billing:read` or `billing:setup`, entitlement checks use
`billing:entitlement:check`, subscription updates use
`billing:subscription:write`, billing usage export uses
`billing:usage:export`, and Stripe-provider events use `billing:provider`.
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
for local development. Redis is available through Redis Streams with
atomic `XADD` operations. PostgreSQL is available as a disposable durable event
log that creates its minimal tables at startup. These backends plug in behind
the same event bus boundary, so functional providers and HTTP controllers do
not change when the backend changes.

### `POST /api/v1/events`

Publishes one event.

The provider stamps the event account from the JWT. Caller-supplied account
metadata is not trusted for ownership or stream authorization.
Send `Content-Type: application/json` with an event envelope:

```json
{
  "name": "example.ping",
  "correlation_id": "optional-correlation-id",
  "delivery": "broadcast",
  "group": "default",
  "payload": {"ok": true}
}
```

`name` is required. `payload` may be any JSON value. `delivery` defaults to
`broadcast`; omit `group` for ordinary broadcast events. Use `delivery:"work"`
with `group` when competing workers should receive the event through a named
work group. Success returns `202 Accepted` or `200 OK` with the stored event
metadata. Bad JSON or invalid event names return `400`, missing auth returns
`401`, and missing domain scope returns `403`.

Runnable local publish check:

```sh
curl -fsS -X POST \
  -H "Authorization: Bearer $(cat ./local/events.token)" \
  -H "Content-Type: application/json" \
  http://127.0.0.1:8081/api/v1/events \
  -d '{"name":"example.ping","correlation_id":"docs-ping","payload":{"ok":true}}'
```

Success returns `202 Accepted` or `200 OK` with stored event metadata,
including the event name and correlation identifier.

### `GET /api/v1/events/stream?name=<event-name>&delivery=broadcast`

Streams matching events to every authorized listener.

Use broadcast delivery when all subscribers should receive the same event.
The response is `application/x-ndjson`: each line is one JSON event envelope.
Clients should read incrementally until the connection closes or their timeout
expires.

Use `replay=true&follow=false` for a deterministic one-shot local stream check
after publishing `example.ping`:

```sh
curl -fsS \
  -H "Authorization: Bearer $(cat ./local/events.token)" \
  'http://127.0.0.1:8081/api/v1/events/stream?name=example.ping&delivery=broadcast&replay=true&follow=false'
```

The first NDJSON line should be a JSON event envelope whose `name` is
`example.ping` and whose `correlation_id` is `docs-ping`.

Missing or invalid bearer tokens return `401 invalid_auth`. Missing listen
scope for the requested event namespace returns `403 forbidden`. Invalid event
names return `400 bad_request`, and wildcard names are rejected unless the
deployment explicitly enables broad admin-only event scopes.

### `GET /api/v1/events/stream?name=<event-name>&delivery=work&group=<group>&consumer=<consumer>`

Streams matching events as competing work.

Use work delivery when only one worker in a group should receive each event. If
`group` is omitted, the provider uses `default`.
Work streams use the same newline-delimited JSON framing as broadcast streams.
Only one authorized consumer in the group receives each event.
Use short stable URL-safe `group` and `consumer` names such as
`billing-worker` or `usage-collector-1`. Avoid spaces, slashes, control
characters, and secrets; backend-specific invalid names return
`400 bad_request` or a stream setup error.
Invalid work group or consumer values return `400 bad_request`; missing or
underscoped authorization returns `401` or `403` before any stream is opened.

### `name=<event-name>`

Selects the event name to publish or stream.

Protected Bus event names require domain scopes such as `vm:write`,
`container:run`, `billing:read`, or `usage:read`.
Event names are dot-separated lowercase identifiers such as
`bus.vm.status.request` or `example.ping`. Use letters, digits, hyphen,
underscore, and dots; avoid wildcards unless the deployment explicitly enables
admin-only broad listening. Protected namespace scope mapping is documented in
the authentication section above and in
[Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes).

### `delivery=broadcast`

Delivers each event to every authorized listener.

### `delivery=work`

Delivers each event to one authorized worker in the selected group.

### `group=<group>`

Selects the work-delivery group.

Workers in the same group compete for events. Workers in different groups each
receive their own group delivery.

### `consumer=<consumer>`

Identifies one work-delivery consumer.

Use stable consumer names for long-running workers.

### `replay=true`

Includes existing matching events before following new events.

### `follow=false`

Returns after the replayed snapshot instead of waiting for new events.

The PostgreSQL backend is intentionally migration-free. It creates `bus_events`
and `bus_event_group_cursors` when missing. Use PostgreSQL for production
deployments that need restart tolerance, multiple API processes, replayable
event history, or durable work-group cursors. Destroying the PostgreSQL
database loses queued events, replay history, and work-delivery cursors, so do
that only for disposable local or test environments. PostgreSQL uses
`LISTEN/NOTIFY` to wake listeners quickly, with SQL polling as the fallback and
SQL transactions as the source of truth.

### Development

For local development, use an obvious non-secret JWT secret and locally
generated test tokens only. Plain secret values are raw text even when they look
like base64; use `base64:<value>` only for an intentionally base64-encoded
secret. Do not commit real deployment secrets.

The BusDK superproject `compose.yaml` starts this provider as `bus-events` with
`--events-backend postgres` and `BUS_EVENTS_POSTGRES_DSN` pointing at the local
PostgreSQL service. Other local AI Platform services reach it at
`http://bus-events:8081`, and nginx exposes `/api/v1/events` on the local
public API port. The shared local token scopes include the domain scopes needed
for LLM, billing, VM, container, usage, Stripe, work, and development-task
events, so the compose stack can exercise request/reply workflows without
enabling broad wildcard event access.

### Production Notes

Use Redis or PostgreSQL for deployments that need restart tolerance or multiple
processes. Select Redis with `--events-backend redis`, `BUS_EVENTS_REDIS_ADDR`,
optional `BUS_EVENTS_REDIS_PASSWORD`, and optional
`BUS_EVENTS_REDIS_PREFIX`. Select PostgreSQL with `--events-backend postgres`
and `BUS_EVENTS_POSTGRES_DSN`. Use memory only for local development. Keep
wildcard streaming disabled unless an explicitly trusted internal/admin
deployment needs it and the token audience/scope policy allows it.

Provider and integration processes should use narrow tokens with only the
domain scopes needed for the events they send and receive. Do not log bearer
tokens or event payload fields that contain provider secrets.

### Sources

- [bus events](./bus-events)
- [bus-integration](./bus-integration)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
