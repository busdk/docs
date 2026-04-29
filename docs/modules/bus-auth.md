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

```bash
bus auth --api-url http://127.0.0.1:8080 register --email user@example.com
bus auth --api-url http://127.0.0.1:8080 login --email user@example.com
bus auth --api-url http://127.0.0.1:8080 verify --email user@example.com --otp 123456
bus auth --api-url http://127.0.0.1:8080 status
bus auth --api-url http://127.0.0.1:8080 token
bus auth --api-url http://127.0.0.1:8080 token --scope "vm:read container:run"
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
`bus-api-provider-auth/examples/local-compose/`. It runs PostgreSQL, MailHog,
and `bus-api` with the auth provider mounted at
`http://127.0.0.1:8080/local-dev/v1/modules/auth`. Configure
`BUS_AUTH_API_URL` to that URL, register and request an OTP with `bus auth`,
read the OTP from MailHog at `http://127.0.0.1:8025`, verify the OTP, and then
request the AI Platform token after operator approval. The token returned by
`bus auth token` is the token to use with `https://ai.hg.fi/v1`; when saved as
`~/.config/bus/auth/api-token` by default, other Bus API clients such as
`bus events` can discover it without repeating token flags. Do not use
developer-machine paths, repository-local token files, or external JWT minting
commands.

Run `bus auth --help` for the full command reference. The
help output is organized into Git-style sections covering name, synopsis,
description, commands, options, environment, examples, and related
documentation. Automated tests validate that structure during normal quality
runs.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [bus-operator](./bus-operator)
- [bus-api](./bus-api)
