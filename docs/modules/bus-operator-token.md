---
title: bus operator token
description: bus operator token issues trusted internal service tokens.
---

## `bus operator token`

`bus operator token` is the operator-facing service-token bootstrap client. It
calls the auth provider internal token endpoint by default and is not an
end-user login flow. It also has an explicit `--local` mode for trusted local
developer automation that must sign a short-lived JWT without an auth provider
HTTP call.

`issue --subject <id> [--audience <aud>] [--scope <scopes>]` creates a trusted
token using an internal shared key from `--internal-key-file` or
`BUS_OPERATOR_INTERNAL_KEY`. Literal internal key values are not accepted on
the command line.

`issue --local --subject <id> --audience ai.hg.fi/api --scope llm:proxy`
creates the same HS256 Bus JWT claim shape locally from `BUS_AUTH_HS256_SECRET`
or `--hs256-secret-file`. Use `--ttl <duration>` to choose the local token
lifetime and `--format token` when a caller needs only the raw bearer token on
stdout.
`BUS_AUTH_HS256_SECRET` or the `--hs256-secret-file` value must match the HS256
signing secret trusted by the target Bus API or auth service. If it does not
match, the command can still print a JWT, but the receiving service rejects the
token.

Use it for trusted services and maintenance jobs that need internal-audience
JWTs, for example billing catalog management, usage collection, provider
request/reply workers, or internal runner administration. End-user API tokens
should come from `bus auth token`, not this command.

Common internal audiences are `ai.hg.fi/internal` for service and operator
work, and `ai.hg.fi/auth` for auth-service administrative flows. Keep scopes
narrow, such as `billing:catalog:write`, `billing:entitlement:check`,
`usage:read usage:delete`, or `container:admin`.

`--api-url <url>` selects the auth provider base URL for remote issuing.
`--format json|token` selects a JSON response envelope or raw access-token
output. `--output <file>` writes output to a file, `--quiet` suppresses normal
output, `--timeout <duration>` sets the HTTP timeout, and `--version` prints
version information.

Local developer token example:

```sh
bus operator token --format token issue --local \
  --subject local-codex \
  --audience ai.hg.fi/api \
  --scope llm:proxy \
  --ttl 1h
```

Store the internal shared key in a deployment secret or untracked local file.
Store the local HS256 signing secret in the same kind of private secret source,
for example an untracked local environment file loaded before invocation. Do
not put internal keys, signing secrets, or real JWTs in shell history, public
compose files, committed docs, or command-line arguments.

Run `bus operator token --help` for the full command reference.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
