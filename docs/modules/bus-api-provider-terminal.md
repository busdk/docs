---
title: bus-api-provider-terminal — terminal API provider
description: bus-api-provider-terminal exposes authenticated user-owned web terminal sessions for Bus portal clients.
---

## `bus-api-provider-terminal` — terminal API provider

`bus-api-provider-terminal` owns the API boundary for browser terminal access.
Portal UI modules call this provider; they must not integrate directly with
`bus-integration-*` workers.

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

The MVP backend is in-memory for local development. Production container or SSH
execution should remain behind this provider boundary.
