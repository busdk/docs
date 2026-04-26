---
title: bus-events — Bus Events API client and SDK
description: bus events sends and listens for Bus Events API messages using shared event-oriented contracts.
---

## `bus-events` — Bus Events API client and SDK

`bus events` is the command-line client for the Bus Events API. It can publish
events and listen for matching events using the same `aud=ai.hg.fi/api` bearer
JWTs as other Bus API endpoints, with the required domain scopes for each event
name.

The same module owns the shared Go contracts for event-oriented integrations.
Functional providers should use those contracts or the Events API SDK and
should not depend on HTTP controller internals.

### Common Tasks

```bash
BUS_API_TOKEN="$(bus auth --token-file ~/.config/bus/auth/token token --scope "vm:read" | jq -r .access_token)"
bus events --api-token "$BUS_API_TOKEN" send --name example.ping --payload '{"ok":true}'
bus events listen --name example.ping
bus events listen --name example.job --delivery work --group workers --consumer worker-a
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

`BUS_EVENTS_API_URL` sets the default Events API URL. `BUS_API_TOKEN` supplies
the bearer token when `--api-token`, `--token`, and `--token-file` are omitted.
If no token flag or environment variable is set, `bus events` reads the normal
Bus auth API token from `auth/api-token` under the user Bus config root. The
root is `BUS_CONFIG_DIR` when set, otherwise `$XDG_CONFIG_HOME/bus` or
`~/.config/bus` on Unix-like systems. This lets a user or service run
`bus events` after local Bus auth session setup without repeating token flags.
The CLI never auto-reads repository-local `.bus/` token files.
