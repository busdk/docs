---
title: bus operator billing
description: bus operator billing provides provider-neutral billing administration.
---

## `bus operator billing`

`bus operator billing` is the provider-neutral billing operator client. It is
separate from end-user `bus billing`, which only handles caller-owned billing
setup and status.

Use it to inspect account billing state and manage the Bus billing catalog.
The catalog describes Bus products, plans, prices, usage meters, feature
scopes, and quota rules. It is provider-neutral so the same catalog can drive
Bus entitlement checks and Stripe synchronization.

`status --account <account-id>` reads one account's internal billing status from
the Billing API. This is an internal/operator operation and requires an
internal-audience Bearer JWT with the literal `billing:read` scope.

`catalog template` prints a starter provider-neutral catalog JSON document. Use
it as the starting point for commercial plans such as an LLM plan with token
quotas or a container plan with runtime quotas.

`catalog get` reads the active provider-neutral billing catalog from the
internal Billing API. It requires an internal-audience Bearer JWT with
`billing:catalog:read`.

`catalog put --file <catalog.json>` replaces the active provider-neutral billing
catalog. It requires an internal-audience Bearer JWT with
`billing:catalog:write`.

The catalog should not contain Stripe secret keys, webhook secrets, database
passwords, or other deployment secrets. Provider mappings such as Stripe lookup
keys and public object IDs are acceptable when they are not secret.

Use `--token-file <path>`, `BUS_OPERATOR_TOKEN`, or `BUS_INTERNAL_TOKEN` for
the internal Bearer JWT. Literal token values are not accepted on the command
line. `--api-url <url>` selects the Billing API base URL. `--output <file>`
writes output to a file, `--quiet` suppresses normal output,
`--timeout <duration>` sets the HTTP timeout, and `--version` prints version
information.

Typical Stripe-backed setup:

```sh
bus operator billing catalog template > catalog.json
bus operator stripe catalog sync --file catalog.json
bus operator billing catalog put --file catalog.json
```

After the catalog is active, end users use `bus billing setup` and
`bus billing portal`; operators should not use end-user tokens for catalog or
cross-account status work.

Run `bus operator billing --help` for the full command reference.

### Sources

- [bus-api-provider-billing](./bus-api-provider-billing)
- [bus-integration-billing](./bus-integration-billing)
