---
title: bus operator stripe
description: bus operator stripe provides Stripe-specific billing diagnostics.
---

## `bus operator stripe`

`bus operator stripe` is the Stripe-specific operator client behind Bus billing.
It is a sibling of `bus operator billing`, not a nested billing submodule.

`test` verifies Stripe credentials with a harmless balance read and prints only
safe metadata such as whether the key is live mode. It never prints Stripe
secret keys or webhook secrets.

`catalog sync --file <catalog.json>` creates Stripe Products and Prices from a
local operator-managed catalog file. It uses `lookup_key` values for stable
idempotency keys and prints only safe Stripe object IDs.

Use `BUS_STRIPE_SECRET_KEY` for the test secret key and
`BUS_STRIPE_API_VERSION` when you need to pin response behavior for older Stripe
accounts.

Run `bus operator stripe --help` for the full command reference.

### Sources

- [bus-operator-stripe README](../../../bus-operator-stripe/README.md)
