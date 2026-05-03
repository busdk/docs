---
title: bus-auth
description: bus auth is the thin command-line client for Bus auth provider login and token handling.
---

## Auth Client CLI

`bus-auth` is the command-line client for the Bus auth provider. Through the Bus
dispatcher it is used as `bus auth ...`. It does not own authentication service
logic; it sends HTTP requests to a configured auth provider API.

Use `register` to enter the waitlist, `login` to request an OTP, `verify` to
exchange the OTP for an auth-service JWT, `status` to check approval state, and
`token` to request a Bus API JWT after approval. Admin users use
`bus operator auth waitlist`, `bus operator auth approve`, and
`bus operator auth reject` with an auth-service JWT that has waitlist scopes.
Use `token --scope "<scopes>"` to request an approved-user API JWT with domain
scopes such as `llm:proxy`, `billing:read`, `container:run`, or `terminal:read`.
The same `aud=ai.hg.fi/api` token is used for REST APIs and Events API
endpoints available to end users.

An auth provider must already be running at the selected API URL. For local
development, the compose example below exposes the auth provider at
`http://127.0.0.1:8080/local-dev/v1/api/v1/auth` and sends OTP email to
MailHog. For another deployment, replace the API URL and read the OTP from the
configured OTP sender.

```bash
bus auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth register --email user@example.com
bus auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth login --email user@example.com
bus auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth verify --email user@example.com --otp <otp-from-provider>
bus auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth status
bus auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth token
bus auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth token --scope "vm:read container:run"
```

The API base URL can also be provided by `BUS_AUTH_API_URL`. `verify` stores the
auth-service session token as `auth/token` under the Bus user config root by
default. `token` stores the returned normal Bus API JWT as `auth/api-token` in
the same root. The root is `BUS_CONFIG_DIR` when set, otherwise
`$XDG_CONFIG_HOME/bus` or `~/.config/bus` on Unix-like systems. Use
`--token-file` or `BUS_AUTH_TOKEN` for automation; literal token values are not
accepted on the command line. Tokens are never auto-written under
repository-local `.bus/` paths.

### Options

`--help` and `--version` print command help or version information.

`--api-url <url>` selects the auth provider base URL. `--token-file <path>`
reads or writes the auth-service session token at a caller-selected path.
`--timeout <duration>` sets the HTTP timeout. `--output <file>` writes command
output to a file and `--quiet` suppresses normal output.

`token --scope <scopes>` requests a space-separated API scope set.

### Paid Feature Access

Registration and OTP verification do not grant paid feature access. A user must
be approved first, then request a token with the scopes needed by the feature.
Billing may still be required by the feature provider before work starts.

Common examples:

```sh
bus auth token --scope "billing:read billing:setup"
bus auth token --scope "llm:proxy billing:read"
bus auth token --scope "container:read container:run container:delete billing:read"
```

If the auth provider policy does not allow a requested scope for the account,
the token request fails. If the token is allowed but billing is incomplete or
quota is exhausted, the target API provider returns billing guidance.

For a complete local flow, start the compose stack in
`bus-api-provider-auth/examples/local-compose/`:

```sh
docker compose -f bus-api-provider-auth/examples/local-compose/docker-compose.yml up
export BUS_AUTH_API_URL=http://127.0.0.1:8080/local-dev/v1/api/v1/auth
bus auth register --email user@example.com
bus auth login --email user@example.com
```

Read the OTP from MailHog at `http://127.0.0.1:8025`, then verify it:

```sh
bus auth verify --email user@example.com --otp <otp-from-mailhog>
```

An operator approves the verified user with `bus operator auth approve` using
an auth-service admin token from the local deployment. With the local compose
defaults, create the untracked token file first:

```sh
mkdir -p ./local
export BUS_AUTH_INTERNAL_TOKEN_URL=http://127.0.0.1:8080/local-dev/v1/api/internal/auth/token
curl -fsS \
  -H 'Content-Type: application/json' \
  -H 'X-Bus-Internal-Key: not-a-secret-local-development-internal-key' \
  -d '{"subject":"admin-user","scope":"waitlist:read waitlist:approve admin:manage"}' \
  "$BUS_AUTH_INTERNAL_TOKEN_URL" \
  | jq -r '.access_token' > ./local/admin-token
```

Then approve the user:

```sh
bus operator auth --api-url http://127.0.0.1:8080/local-dev/v1/api/v1/auth \
  --token-file ./local/admin-token \
  approve --email user@example.com
```

After approval, request the AI Platform token:

```sh
bus auth token --scope "llm:proxy"
```

The token returned by this local compose flow is for the matching local API
origin, not for the hosted `https://ai.hg.fi/v1` endpoint. When saved as
`~/.config/bus/auth/api-token` by default, other local Bus API clients can
discover it without repeating token flags. For the hosted AI Platform, run the
same auth flow against the hosted auth API and use the hosted token with
`https://ai.hg.fi/v1`. Do not use developer-machine paths, repository-local
token files, or external JWT minting commands.

The BusDK superproject root `compose.yaml` exposes the broader local AI
Platform auth route at
`http://127.0.0.1:${LOCAL_AI_PLATFORM_PORT:-8080}/api/v1/auth`. That stack
shares the same MailHog-backed OTP flow and allows approved users to request
the local feature scopes configured by `BUS_AUTH_API_USER_SCOPES`.

Run `bus auth --help` for the full command reference. The
help output is organized into Git-style sections covering name, synopsis,
description, commands, options, environment, examples, and related
documentation.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [bus-operator](./bus-operator)
- [bus-api](./bus-api)
