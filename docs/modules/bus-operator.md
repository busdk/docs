---
title: bus-operator
description: bus operator is the command-line client for Bus operator, admin, and service automation tasks.
---

## Operator CLI

`bus-operator` is the umbrella dispatcher for the `bus operator ...` namespace.
It is the operator-facing companion to end-user tools such as `bus auth`. End
users use `bus auth` to register, verify email ownership, check approval
status, and request approved API tokens. Operators use focused
`bus operator <family> ...` commands for waitlist administration, service-token
bootstrap, billing operations, and provider diagnostics.

Command implementations live in focused `bus-operator-*` modules. The umbrella
module calls those modules through Go library entrypoints. It does not execute
child binaries, duplicate command logic, or implement auth policy locally.

```bash
bus operator auth --api-url http://127.0.0.1:8080 --token-file ./local/admin-token waitlist
bus operator auth --api-url http://127.0.0.1:8080 --token-file ./local/admin-token approve --email user@example.com
bus operator auth --api-url http://127.0.0.1:8080 --token-file ./local/admin-token reject --email user@example.com
```

The auth provider must be reachable at `--api-url`, and `--token-file` must
contain an operator/admin token accepted by that provider. A successful
`waitlist` call prints pending registrations, while successful `approve` and
`reject` calls exit 0 and print the updated user decision or no output when
`--quiet` is used.

`token issue` is for internal service bootstrap and installation automation. It
uses `/api/internal/auth/token`, which is protected by the provider's
`X-Bus-Internal-Key` check. Keep that endpoint on internal routing and provide
the key from a deployment secret store, an untracked local secret file, or the
operator environment.

```bash
bus operator token --api-url http://127.0.0.1:8080 \
  --internal-key-file ./local/internal-key \
  issue \
  --subject usage-worker \
  --audience ai.hg.fi/auth \
  --scope "usage:read usage:delete"
```

For trusted local developer automation, `token issue --local` signs a
short-lived HS256 Bus JWT from `BUS_AUTH_HS256_SECRET` or
`--hs256-secret-file` without an auth provider HTTP call. Use `--format token`
when the caller expects only the raw bearer token.

```bash
bus operator token --format token issue --local \
  --subject local-codex \
  --audience ai.hg.fi/api \
  --scope llm:proxy \
  --ttl 1h
```

Run `bus operator --help` for the full command reference. The help output uses
Git-style sections covering name, synopsis, description, commands, options,
environment, examples, and related documentation. Run
`bus operator <family> --help` for the focused command-family flags and
environment variables.

### Common Operator Flags

`--version` prints the umbrella dispatcher version. Focused families document
their own flags, including `--api-url`, `--token-file`, `--account`,
`--api-key-file`, `--stripe-api-url`, and `--stripe-api-version`.

### Sources

- [bus-operator](./bus-operator)
- [bus-operator-auth](./bus-operator-auth)
- [bus-operator-token](./bus-operator-token)
- [bus-operator-billing](./bus-operator-billing)
- [bus-operator-stripe](./bus-operator-stripe)
- [bus-api-provider-auth](./bus-api-provider-auth)
