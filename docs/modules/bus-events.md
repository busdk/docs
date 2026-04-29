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
bus auth token --scope "vm:read vm:write"
bus events send --name example.ping --payload '{"ok":true}'
bus events send --name bus.vm.start.request --payload '{"runtime":"default"}'
bus events listen --name example.ping
bus events listen --name example.job --delivery work --group workers --consumer worker-a
bus events listen --name example.history --replay --no-follow
```

`send` publishes one event. `listen` streams newline-delimited JSON event
envelopes. The default `broadcast` delivery mode sends each event to every
matching listener. Use `--delivery work --group <name>` when matching listeners
are competing workers and only one of them should receive each event.
By default `listen` follows new events. Use `--replay` to include existing
matching events and `--no-follow` to return after replaying the current
history snapshot.

### Global Options

`--help` and `--version` print command help or version information.

`--api-url <url>` selects the Events API base URL. `--token-file <path>` reads
the Bus API bearer token from a file. `--timeout <duration>` sets the HTTP and
listen timeout.

`--chdir <dir>`, `--output <file>`, `--format <text|json>`, `--quiet`,
`--color <auto|always|never>`, and `--no-color` provide the common Bus CLI
working-directory and output controls.

### Ownership Boundary

`bus-events` owns the CLI and SDK. `bus-api-provider-events` owns the public
HTTP Events API server/controller. Other functional providers, such as a future
UpCloud integration worker, should handle event envelopes and should not need
to know how HTTP requests were mapped into those events.

### Environment

`BUS_EVENTS_API_URL` sets the default Events API URL. `BUS_API_TOKEN` supplies
the bearer token when `--token-file` is omitted. If no environment variable is
set, `bus events` reads the normal Bus auth API token from `auth/api-token` under the user Bus config root. The
root is `BUS_CONFIG_DIR` when set, otherwise `$XDG_CONFIG_HOME/bus` or
`~/.config/bus` on Unix-like systems. This lets a user or service run
`bus events` after local Bus auth session setup without repeating token flags.
The CLI never accepts bearer tokens as command-line arguments and never
auto-reads repository-local `.bus/` token files.

Events API authorization is least-privilege and domain-scoped. The CLI does
not decide which event names a token may access; it passes the normal Bus API
JWT to the provider, and the provider maps event names to scopes such as
`vm:write`, `container:run`, or `usage:read`. If a token is missing a required
scope, the provider returns `403 Forbidden` and `bus events` prints the bounded
provider diagnostic so the operator can request the correct scope with
`bus auth token --scope "<scopes>"`.
