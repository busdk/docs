---
title: bus-operator
description: bus operator is the command-line client for Bus operator, admin, and service automation tasks.
---

## Operator CLI

`bus-operator` owns the `bus operator ...` command namespace. It is the
operator-facing companion to end-user tools such as `bus auth`. End users use
`bus auth` to register, verify email ownership, check approval status, and
request approved API tokens. Operators use `bus operator` for waitlist
administration and service-token bootstrap.

The CLI is a thin HTTP client. It does not implement auth policy locally and it
does not sign JWTs. Waitlist commands call the auth provider admin endpoints
using an admin-scoped auth-service Bearer JWT. Token bootstrap calls the auth
provider internal token endpoint with an explicit internal shared key.

```bash
bus operator --api-url http://127.0.0.1:8080 --token <admin-jwt> auth waitlist
bus operator --api-url http://127.0.0.1:8080 --token <admin-jwt> auth approve --email user@example.com
bus operator --api-url http://127.0.0.1:8080 --token <admin-jwt> auth reject --email user@example.com
```

`token issue` is for internal service bootstrap and installation automation. It
uses `/api/internal/auth/token`, which is protected by the provider's
`X-Bus-Internal-Key` check. Keep that endpoint on internal routing and provide
the key from a deployment secret store, an untracked local secret file, or the
operator environment.

```bash
bus operator --api-url http://127.0.0.1:8080 \
  --internal-key-file ./local/internal-key \
  token issue \
  --subject usage-worker \
  --audience ai.hg.fi/auth \
  --scope "usage:read usage:delete"
```

Run `bus operator --help` for the full command reference. The help output uses
Git-style sections covering name, synopsis, description, commands, options,
environment, examples, and related documentation.

### Sources

- [bus-operator](./bus-operator)
- [bus-api-provider-auth](./bus-api-provider-auth)
