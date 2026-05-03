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

Remote issuing example:

```sh
bus operator token \
  --api-url https://api.example.test \
  --internal-key-file /run/secrets/bus-auth-internal-key \
  --format token \
  issue \
  --subject billing-worker \
  --audience ai.hg.fi/api \
  --scope "billing:read billing:entitlement:check" \
  --ttl 1h
```

The command prints one bearer JWT to stdout when the auth provider accepts the
internal key and requested claims.

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

`--api-url <url>` selects the auth provider base URL for remote issuing; the
client posts to `/api/internal/auth/token` below that base URL.
`--format json|token` selects a JSON response envelope or raw access-token
output. `--output <file>` writes output to a file, `--quiet` suppresses normal
output, `--timeout <duration>` sets the HTTP timeout, and `--version` prints
version information.

Local developer token example:

```sh
mkdir -p ./local
printf '%s' 'not-a-secret-local-development-hs256-key' > ./local/hs256-secret
bus operator token --format token issue --local \
  --hs256-secret-file ./local/hs256-secret \
  --subject local-codex \
  --audience ai.hg.fi/api \
  --scope llm:proxy \
  --ttl 1h
```

The command prints a raw JWT signed with the provided HS256 secret. Use
`--hs256-secret-file` instead of the environment variable when the local secret
comes from an untracked file.
Verify the token against the intended local service before using it in
automation, for example:

```sh
TOKEN="$(bus operator token --format token issue --local --hs256-secret-file ./local/hs256-secret --subject local-codex --audience ai.hg.fi/api --scope llm:proxy --ttl 1h)"
curl -fsS -H "Authorization: Bearer $TOKEN" http://127.0.0.1:8080/v1/models
```

If the receiving service uses a different HS256 secret, the verification
request fails with an authentication error.

The BusDK superproject `compose.yaml` uses the `bus-operator-token` binary as a
container entrypoint alias for `bus operator token issue --local` to mint
short-lived local service tokens from the shared development HS256 secret. The
`testing-agent` writes an API-audience token and an auth-audience admin token
under `/root/.config/bus/auth/` for smoke checks.
Those tokens are local compose artifacts only; do not reuse them for hosted or
shared deployments.

Store the internal shared key in a deployment secret or untracked local file.
Store the local HS256 signing secret in the same kind of private secret source,
for example an untracked local environment file loaded before invocation. Do
not put internal keys, signing secrets, or real JWTs in shell history, public
compose files, committed docs, or command-line arguments.

Run `bus operator token --help` for the full command reference.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
