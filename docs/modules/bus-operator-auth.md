---
title: bus operator auth
description: bus operator auth manages Bus auth waitlist approvals.
---

## `bus operator auth`

`bus operator auth` is the operator-facing auth waitlist client. It is separate
from end-user `bus auth` login and token commands.

`waitlist` lists waitlisted users. `approve --email <address>` approves a
verified waitlisted user. `reject --email <address>` rejects a waitlisted user.
All commands require an auth-service admin Bearer JWT supplied with
`--token-file`, `BUS_OPERATOR_TOKEN`, or `BUS_INTERNAL_TOKEN`. Literal token
values are not accepted on the command line.
The token must be minted for the auth-service audience and include the
waitlist administration scopes used by the deployment, such as
`waitlist:read`, `waitlist:approve`, and `admin:manage`. Operators normally
obtain it through `bus operator token issue` during installation or from the
deployment's internal secret store.

Approving a user allows the auth provider to create or activate the stable
account UUID and issue only the end-user scopes allowed by provider policy.
Approval does not bypass billing. Paid features such as LLM access and
containers still require billing entitlement and quota checks in their domain
providers.

`--api-url <url>` selects the auth provider base URL and has no network default
that is safe for every deployment. Tokens are read from `--token-file` first,
then `BUS_OPERATOR_TOKEN`, then `BUS_INTERNAL_TOKEN`. `--output <file>` writes
normal output to a file, `--quiet` suppresses normal output,
`--timeout <duration>` uses Go duration syntax such as `30s` or `2m`, and
`--version` prints version information.

Run `bus operator auth --help` for the full command reference.

### Sources

- [bus-api-provider-auth](./bus-api-provider-auth)
- [bus-auth](./bus-auth)
