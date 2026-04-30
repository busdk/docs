---
title: bus-api-provider-terminal — terminal API provider
description: bus-api-provider-terminal exposes authenticated user-owned web terminal sessions for Bus portal clients.
---

## `bus-api-provider-terminal` — terminal API provider

`bus-api-provider-terminal` owns the API boundary for browser terminal access.
Portal UI modules call this provider for authenticated browser terminal
sessions.

Use this provider when a web portal needs shell-style access to a user-owned
runtime, such as a non-persistent container running Codex. The provider exposes
an authenticated API surface for session creation, input, output, and cleanup.

### Authentication

Terminal APIs require a Bus API JWT with audience `ai.hg.fi/api`.

Write operations require `terminal:write`. Read operations require
`terminal:read`. Every operation is account-isolated by JWT `sub`.

JWT validation is strict: tokens must be HS256 signed, use JWT type when `typ`
is present, include `exp`, pass issued-at/expiry checks with configured clock
skew, match the accepted audience, and match the configured issuer when one is
set. `none` and wrong-algorithm tokens are rejected.

The local backend stores terminal session state in memory. Production
deployments can connect this API boundary to container or SSH execution while
keeping portal clients on the authenticated terminal API.

### `POST /api/v1/terminal/sessions`

Creates a terminal session for the authenticated account.

Use this after the user has an approved account and the portal has a valid Bus
API token.

### `GET /api/v1/terminal/sessions/{id}`

Returns metadata for one owned terminal session.

The provider rejects reads for sessions owned by another account.

### `GET /api/v1/terminal/sessions/{id}/output`

Returns terminal output for one owned session.

Use this endpoint for browser polling or streaming-style UI updates, depending
on deployment configuration.

### `GET /api/v1/terminal/sessions/{id}/stream`

Streams terminal output for one owned session as Server-Sent Events.

Each event uses `event: output` and a JSON `data` payload containing the
session `id` and one output line. Closing the browser stream cancels the server
subscription.

### `POST /api/v1/terminal/sessions/{id}/input`

Sends input to one owned terminal session.

Treat terminal input as sensitive operational data. Do not log raw input in
production.

### `POST /api/v1/terminal/sessions/{id}/resize`

Updates terminal dimensions for one owned session.

The JSON body contains positive integer `rows` and `cols`. Use this when the
browser terminal viewport changes size.

### `DELETE /api/v1/terminal/sessions/{id}`

Closes one owned terminal session.

Call this when the browser session ends or the owning container run is cleaned
up.

### `GET /readyz`

Reports provider readiness.

### Portal Use

`bus-portal-ai` calls this provider after the user has logged in through
`bus-portal-auth`. The browser sends the Bus API token as bearer
authorization. The terminal provider validates the token and ensures the
session belongs to the account in JWT `sub`.

Terminal access should be combined with container ownership checks when the
terminal is attached to container-backed work. A user must not be able to read
or write terminal sessions for another account's container.

### Security Notes

Use HTTPS for browser access. Do not expose terminal APIs without JWT
validation. Do not log bearer tokens, terminal input containing secrets, SSH
keys, or provider credentials. Prefer short session lifetimes and close
sessions when the browser disconnects or the owning container run ends.

### Sources

- [bus-portal-ai](./bus-portal-ai)
- [bus-api-provider-containers](./bus-api-provider-containers)
