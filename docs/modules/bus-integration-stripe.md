---
title: bus-integration-stripe — Stripe integration
description: bus-integration-stripe owns Stripe-specific billing protocol behavior behind generic Bus billing.
---

## `bus-integration-stripe` — Stripe integration

`bus-integration-stripe` owns Stripe-specific billing protocol behavior behind
the provider-neutral Bus billing boundary. It verifies Stripe webhooks, creates
Stripe Checkout and Customer Portal sessions when deployment secrets are
configured, records Stripe meter events, and defines Stripe-specific event DTOs.
Public billing APIs and auth logic do not import Stripe code.

### Events

`bus.stripe.checkout_session.create.request` asks the Stripe integration to
create a Checkout Session. Requests can include a Bus feature scope such as
`llm:proxy`; this is written to Stripe metadata for later webhook mapping.

`bus.stripe.checkout_session.create.response` returns a hosted Checkout URL. In
development without `BUS_STRIPE_SECRET_KEY`, the URL is deterministic and local.
With Stripe configuration, the worker creates a real Stripe Checkout Session.

`bus.stripe.portal_session.create.request` asks for a Stripe Customer Portal
session.

`bus.stripe.portal_session.create.response` returns a hosted portal URL. Real
Stripe Portal sessions require Stripe Customer Portal to be configured for the
test/live account.

`bus.stripe.webhook.verify.request` asks the integration to verify a Stripe
webhook signature over the raw request body.

`bus.stripe.webhook.verify.response` returns verified Stripe event metadata.

For supported webhook types, verification also emits
`bus.billing.subscription.update` for the generic billing integration. Supported
types are `checkout.session.completed`, `customer.subscription.created`,
`customer.subscription.updated`, and `customer.subscription.deleted`.

Webhook objects must include Bus account and feature metadata:
`bus_account_id` or checkout `client_reference_id`, plus `bus_feature` or
comma-separated `bus_features`.

`bus.stripe.meter_event.record.request` asks the integration to record a Stripe
meter event with an idempotency key. Requests include the Bus `account_id` for
ownership and Stripe `provider_customer_id` for Stripe meter customer mapping.

`bus.stripe.meter_event.record.response` returns provider acceptance metadata.
The request idempotency key is used for Stripe event identity and retry safety.

### Secrets

Stripe API keys and webhook secrets are deployment secrets. Do not commit them
to source control or print them in logs.

Use these environment variables in deployments or untracked local test files:

- `BUS_STRIPE_SECRET_KEY`
- `BUS_STRIPE_WEBHOOK_SECRET`
- `BUS_STRIPE_API_VERSION`
- `BUS_STRIPE_DEFAULT_PRICE_ID`

For old Stripe test accounts, pin `BUS_STRIPE_API_VERSION` explicitly.

### Live test-mode e2e

Normal e2e is deterministic and avoids Stripe network calls. To validate the
real Stripe test-mode path with local credentials:

```sh
BUS_STRIPE_LIVE_E2E=1 make e2e
```

The live test creates isolated test products, prices, a billing meter, a test
customer, and Checkout Sessions. It verifies a signed checkout webhook into
`bus.billing.subscription.update`, applies it through `bus-integration-billing`,
checks `llm:proxy` entitlement, records one Stripe meter event, and verifies the
result is not livemode.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-integration-billing">bus integration billing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-api-provider-llm">bus api provider llm</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-integration-billing](./bus-integration-billing)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
