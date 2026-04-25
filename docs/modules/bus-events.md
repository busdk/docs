---
title: bus-events — Bus Events API client and SDK
description: bus events sends and listens for Bus Events API messages using shared event-oriented contracts.
---

## `bus-events` — Bus Events API client and SDK

`bus events` is the command-line client for the Bus Events API. It can publish
events and listen for matching events using a bearer JWT with the required
scope.

The same module owns the shared Go contracts for event-oriented integrations.
Functional providers should use those contracts or the Events API SDK and
should not depend on HTTP controller internals.

### Common Tasks

```bash
bus events --token-file .bus/auth/events-token send --name example.ping --payload '{"ok":true}'
bus events --token "$BUS_EVENTS_TOKEN" listen --name example.ping
bus events --token "$BUS_EVENTS_TOKEN" listen --name example.job --delivery work --group workers --consumer worker-a
```

`send` publishes one event. `listen` streams newline-delimited JSON event
envelopes. The default `broadcast` delivery mode sends each event to every
matching listener. Use `--delivery work --group <name>` when matching listeners
are competing workers and only one of them should receive each event.

### Ownership Boundary

`bus-events` owns the CLI and SDK. `bus-api-provider-events` owns the public
HTTP Events API server/controller. Other functional providers, such as a future
UpCloud integration worker, should handle event envelopes and should not need
to know how HTTP requests were mapped into those events.

### Environment

`BUS_EVENTS_API_URL` sets the default Events API URL. `BUS_EVENTS_TOKEN` supplies
the bearer token when `--token` and `--token-file` are omitted.
