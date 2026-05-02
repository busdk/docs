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
bootstrap, billing operations, provider diagnostics, and deployment
automation.

Command implementations live in focused `bus-operator-*` modules. The umbrella
module calls those modules through Go library entrypoints. It does not execute
child binaries, duplicate command logic, or implement auth policy locally.

The auth examples require `bus-api-provider-auth` to be reachable at
`--api-url`, and `--token-file` must contain an operator/admin token accepted by
that provider. For local bootstrap, first create `./local/`, keep it ignored,
and write the same verifier secret used by the auth provider to
`./local/hs256-secret`. Run these commands from the repository root that
contains `.git`. Then create the token:

```bash
install -m 700 -d ./local
git check-ignore -q ./local/hs256-secret || printf '%s\n' '/local/' >> .git/info/exclude
git check-ignore -q ./local/hs256-secret
test -n "${BUS_AUTH_HS256_SECRET:-}" || { echo "export BUS_AUTH_HS256_SECRET with the verifier secret used by bus-api-provider-auth" >&2; exit 2; }
printf '%s\n' "$BUS_AUTH_HS256_SECRET" > ./local/hs256-secret
chmod 600 ./local/hs256-secret
test -s ./local/hs256-secret
bus operator token --format token issue --local \
  --hs256-secret-file ./local/hs256-secret \
  --subject auth-operator \
  --audience ai.hg.fi/auth \
  --scope "waitlist:read waitlist:approve waitlist:reject" \
  > ./local/admin-token
chmod 600 ./local/admin-token
```

Before using that token, verify the auth provider is configured with the same
`BUS_AUTH_HS256_SECRET` value and accepts the `ai.hg.fi/auth` audience for
operator waitlist scopes.

```bash
bus operator auth --api-url http://127.0.0.1:8080 --token-file ./local/admin-token waitlist
bus operator auth --api-url http://127.0.0.1:8080 --token-file ./local/admin-token approve --email user@example.com
```

For a real pending registration, run either `approve` or `reject`, not both.
Use `reject` only when the registration should be denied:

```bash
bus operator auth --api-url http://127.0.0.1:8080 --token-file ./local/admin-token reject --email user@example.com
```

A successful `waitlist` call prints pending registrations, while successful
`approve` and `reject` calls exit 0 and print the updated user decision or no
output when `--quiet` is used.

`bus operator token issue` is for internal service bootstrap and installation
automation. It uses `/api/internal/auth/token`, which is protected by the
provider's `X-Bus-Internal-Key` check. Keep that endpoint on internal routing
and provide the key from a deployment secret store, an untracked local secret
file, or the operator environment.
Before running the command below, `./local/internal-key` must contain the exact
auth provider internal key from the deployment secret store.

```bash
bus operator token --api-url http://127.0.0.1:8080 \
  --internal-key-file ./local/internal-key \
  issue \
  --subject usage-exporter \
  --audience ai.hg.fi/internal \
  --scope "usage:read"
```

A successful issue command prints structured JSON by default. Use
`--format token` when automation needs only the raw bearer token. Store the raw
token in the service environment or secret file used by the worker you are
bootstrapping, then start or restart that service.

For trusted local developer automation, `token issue --local` signs a
short-lived HS256 Bus JWT from `BUS_AUTH_HS256_SECRET` or
`--hs256-secret-file` without an auth provider HTTP call. Use `--format token`
when the caller expects only the raw bearer token. The local signing secret
must match the verifier secret configured in the target local service; a token
signed with a different secret is intentionally rejected.

```bash
bus operator token --format token issue --local \
  --hs256-secret-file ./local/hs256-secret \
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

Deployment automation is split into focused command families. Use
`bus operator deploy` as the controller for complete deployment flows, then use
`bus operator cloud`, `bus operator database`, `bus operator node`, and
`bus operator inference` to inspect or retry specific phases independently.

### Common Operator Flags

`--version` prints the umbrella dispatcher version. Focused families document
their own flags, including `--api-url`, `--token-file`, `--account`,
`--api-key-file`, `--stripe-api-url`, and `--stripe-api-version`.

### Using from `.bus` files

Inside a `.bus` file, call the focused operator workflow directly:

```bus
# same as: bus operator deploy doctor --env-file ./deploy/bus.env
run command -- bus operator deploy doctor --env-file ./deploy/bus.env
```

### Sources

- [bus-operator](./bus-operator)
- [bus-operator-auth](./bus-operator-auth)
- [bus-operator-token](./bus-operator-token)
- [bus-operator-billing](./bus-operator-billing)
- [bus-operator-cloud](./bus-operator-cloud)
- [bus-operator-database](./bus-operator-database)
- [bus-operator-deploy](./bus-operator-deploy)
- [bus-operator-inference](./bus-operator-inference)
- [bus-operator-node](./bus-operator-node)
- [bus-operator-stripe](./bus-operator-stripe)
- [bus-api-provider-auth](./bus-api-provider-auth)
