---
title: bus operator stripe
description: bus operator stripe provides Stripe-specific billing diagnostics.
---

## `bus operator stripe`

`bus operator stripe` is the Stripe-specific operator client behind Bus billing.
It is a sibling of `bus operator billing`, not a nested billing submodule.

Use it to verify Stripe connectivity and synchronize Stripe Products and Prices
from the same provider-neutral catalog used by Bus billing. End users should
not use this command; end users use `bus billing setup` and
`bus billing portal`.

`test` verifies Stripe credentials with a harmless balance read and prints only
safe metadata such as whether the key is live mode. It never prints Stripe
secret keys or webhook secrets.

`catalog sync --file <catalog.json>` creates Stripe Products and Prices from a
local operator-managed catalog file. It uses lookup keys for stable idempotency
and prints only safe Stripe object IDs. Run it before publishing the catalog to
Bus when the catalog references newly created Stripe objects.

Use `BUS_STRIPE_SECRET_KEY` for the test secret key and
`BUS_STRIPE_API_VERSION` when you need to pin response behavior for older Stripe
accounts.

Use `--api-key-file <path>` when the Stripe secret key is stored in an
operator-managed local secret file. Literal Stripe API key values are not
accepted on the command line. `--stripe-api-url <url>` selects the Stripe API
base URL, `--stripe-api-version <version>` pins the Stripe API version,
`--output <file>` writes output to a file, `--quiet` suppresses normal output,
`--timeout <duration>` sets the HTTP timeout, and `--version` prints version
information.

Stripe webhook secrets are not used by this CLI. Webhook verification belongs
to the Stripe integration service and uses `BUS_STRIPE_WEBHOOK_SECRET`.
Publishable keys beginning with `pk_` are browser keys and are not valid for
this operator CLI.

Typical test-mode setup:

```sh
. ./.env.stripe-test
bus operator stripe test
bus operator billing catalog template > catalog.json
bus operator stripe catalog sync --file catalog.json
bus operator billing catalog put --file catalog.json
```

Keep `BUS_STRIPE_SECRET_KEY` in a secret manager or untracked local environment
file such as `./.env.stripe-test`. Do not put it in public docs, committed
compose files, shell history, or command arguments.

Run `bus operator stripe --help` for the full command reference.

### Sources

- [bus-integration-stripe](./bus-integration-stripe)
- [bus-operator-billing](./bus-operator-billing)
