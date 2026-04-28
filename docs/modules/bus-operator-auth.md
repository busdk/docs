---
title: bus operator auth
description: bus operator auth manages Bus auth waitlist approvals.
---

## `bus operator auth`

`bus operator auth` is the operator-facing auth waitlist client. It is separate
from end-user `bus auth` login and token commands.

`waitlist` lists waitlisted users. `approve --email <address>` approves a
verified waitlisted user. `reject --email <address>` rejects a waitlisted user.
All commands require an auth-service admin Bearer JWT supplied with `--token` or
`--token-file`.

Run `bus operator auth --help` for the full command reference.

### Sources

- [bus-operator-auth README](../../../bus-operator-auth/README.md)
