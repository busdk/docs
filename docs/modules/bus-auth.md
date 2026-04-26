---
title: bus-auth
description: bus-auth is the thin command-line client for Bus auth provider login and token handling.
---

## Auth Client CLI

`bus-auth` is the command-line client for the Bus auth provider. Through the Bus
dispatcher it is used as `bus auth ...`. It does not own authentication service
logic; it sends HTTP requests to a configured auth provider API.

Use `register` to enter the waitlist, `login` to request an OTP, `verify` to
exchange the OTP for an auth-service JWT, `status` to check approval state, and
`token` to request an AI Platform `llm:proxy` JWT after approval. Admin users
use `admin waitlist`, `admin approve`, and `admin reject` with an auth-service
JWT that has waitlist scopes.
Use `token --scope "<scopes>"` to request an approved-user API JWT with domain
scopes such as `vm:read` or `container:run`. The same `aud=ai.hg.fi/api` token
is used for REST APIs and Events API endpoints.

```bash
bus auth --api-url http://127.0.0.1:8080 register --email user@example.com
bus auth --api-url http://127.0.0.1:8080 login --email user@example.com
bus auth --api-url http://127.0.0.1:8080 verify --email user@example.com --otp 123456 --token-file .bus/auth/token
bus auth --api-url http://127.0.0.1:8080 --token-file .bus/auth/token status
bus auth --api-url http://127.0.0.1:8080 --token-file .bus/auth/token token
bus auth --api-url http://127.0.0.1:8080 --token-file .bus/auth/token token --scope "vm:read container:run"
```

The API base URL can also be provided by `BUS_AUTH_API_URL`. Tokens are not
stored unless `--token-file` is explicitly provided.

For a complete local flow, start the compose stack in
`bus-api-provider-auth/examples/local-compose/`. It runs PostgreSQL, MailHog,
and `bus-api` with the auth provider mounted at
`http://127.0.0.1:8080/local-dev/v1/modules/auth`. Configure
`BUS_AUTH_API_URL` to that URL, register and request an OTP with `bus auth`,
read the OTP from MailHog at `http://127.0.0.1:8025`, verify the OTP, and then
request the AI Platform token after approval. The token returned by
`bus auth token` is the token to use with `https://ai.hg.fi/v1`; do not use
developer-machine paths or external JWT minting commands.

Run `bus auth --help` or `bus-auth --help` for the full command reference. The
help output is organized into Git-style sections covering name, synopsis,
description, commands, options, environment, examples, and related
documentation. Automated tests validate that structure during normal quality
runs.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [bus-api](./bus-api)
