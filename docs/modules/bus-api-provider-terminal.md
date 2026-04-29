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

### API

```text
POST   /api/v1/terminal/sessions
GET    /api/v1/terminal/sessions/{id}
GET    /api/v1/terminal/sessions/{id}/output
POST   /api/v1/terminal/sessions/{id}/input
DELETE /api/v1/terminal/sessions/{id}
GET    /readyz
```

Session creation, input, and close require a Bus API JWT with audience
`ai.hg.fi/api` and scope `terminal:write`. Read and output endpoints require
`terminal:read`. Every operation is account-isolated by JWT `sub`.

JWT validation is strict: tokens must be HS256 signed, use JWT type when `typ`
is present, include `exp`, pass issued-at/expiry checks with configured clock
skew, match the accepted audience, and match the configured issuer when one is
set. `none` and wrong-algorithm tokens are rejected.

The local backend stores terminal session state in memory. Production
deployments can connect this API boundary to container or SSH execution while
keeping portal clients on the authenticated terminal API.

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
