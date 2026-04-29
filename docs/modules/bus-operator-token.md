---
title: bus operator token
description: bus operator token issues trusted internal service tokens.
---

## `bus operator token`

`bus operator token` is the operator-facing service-token bootstrap client. It
calls the auth provider internal token endpoint and is not an end-user login
flow.

`issue --subject <id> [--audience <aud>] [--scope <scopes>]` creates a trusted
token using an internal shared key from `--internal-key-file` or
`BUS_OPERATOR_INTERNAL_KEY`. Literal internal key values are not accepted on
the command line.

Use it for trusted services and maintenance jobs that need internal-audience
JWTs, for example billing catalog management, usage collection, provider
request/reply workers, or internal runner administration. End-user API tokens
should come from `bus auth token`, not this command.

Common internal audiences are `ai.hg.fi/internal` for service and operator
work, and `ai.hg.fi/auth` for auth-service administrative flows. Keep scopes
narrow, such as `billing:catalog:write`, `billing:entitlement:check`,
`usage:read usage:delete`, or `container:admin`.

`--api-url <url>` selects the auth provider base URL. `--output <file>` writes
output to a file, `--quiet` suppresses normal output, `--timeout <duration>`
sets the HTTP timeout, and `--version` prints version information.

Store the internal shared key in a deployment secret or untracked local file.
Do not put it in shell history, public compose files, committed docs, or
command-line arguments.

Run `bus operator token --help` for the full command reference.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
