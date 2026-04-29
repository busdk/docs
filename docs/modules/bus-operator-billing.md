---
title: bus operator billing
description: bus operator billing provides provider-neutral billing administration.
---

## `bus operator billing`

`bus operator billing` is the provider-neutral billing operator client. It is
separate from end-user `bus billing`, which only handles caller-owned billing
setup and status.

`status --account <account-id>` reads one account's internal billing status from
the Billing API. This is an internal/operator operation and should use an
internal-audience Bearer JWT.

`catalog template` prints a starter provider-neutral catalog JSON document.

`catalog get` reads the active provider-neutral billing catalog from the
internal Billing API. It requires an internal-audience Bearer JWT with
`billing:catalog:read`.

`catalog put --file <catalog.json>` replaces the active provider-neutral billing
catalog. It requires an internal-audience Bearer JWT with
`billing:catalog:write`.

Use `--token-file <path>`, `BUS_OPERATOR_TOKEN`, or `BUS_INTERNAL_TOKEN` for
the internal Bearer JWT. Literal token values are not accepted on the command
line. `--api-url <url>` selects the Billing API base URL. `--output <file>`
writes output to a file, `--quiet` suppresses normal output,
`--timeout <duration>` sets the HTTP timeout, and `--version` prints version
information.

Run `bus operator billing --help` for the full command reference.

### Sources

- [bus-operator-billing README](../../../bus-operator-billing/README.md)
