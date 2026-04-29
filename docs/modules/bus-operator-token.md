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

`--api-url <url>` selects the auth provider base URL. `--output <file>` writes
output to a file, `--quiet` suppresses normal output, `--timeout <duration>`
sets the HTTP timeout, and `--version` prints version information.

Run `bus operator token --help` for the full command reference.

### Sources

- [bus-operator-token README](../../../bus-operator-token/README.md)
