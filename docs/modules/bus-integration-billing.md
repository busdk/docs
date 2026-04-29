---
title: bus-integration-billing — billing integration
description: bus-integration-billing owns provider-neutral billing state and entitlement events.
---

## `bus-integration-billing` — billing integration

`bus-integration-billing` owns provider-neutral billing business logic. It
tracks generic billing state and feature entitlements, creates hosted setup and
portal sessions through a provider boundary, exports billable usage to provider
meters, and returns account-safe billing decisions through Bus Events.

Hosted setup and portal sessions can be local deterministic responses or
provider event request/reply flows. In event mode, this integration publishes
configured provider-specific events and waits for correlated responses without
importing provider SDKs or provider-specific packages.

Production deployments should use `BUS_BILLING_STORE_BACKEND=postgres` and
`BUS_BILLING_DATABASE_URL` so account subscription and entitlement state is
durable. Memory storage is for local development.

The PostgreSQL store contains the operational billing state used by Bus API
providers: account subscription status, enabled feature scopes, provider
customer and subscription identifiers, idempotently processed provider events,
usage export state, and quota usage buckets. It is not a replacement for the
payment provider ledger or invoice system.

Plan quotas are provider-neutral and loaded by the billing integration from a
quota config/catalog file. Each plan can define multiple simultaneous windows
for the same feature and meter, for example per-minute and per-month token
limits for `llm:proxy`. Supported windows are `minute`, `hour`, `day`, `week`,
`month`, and `total`. If any matching quota is exhausted, entitlement checks
return `quota_exceeded` and upgrade guidance before billable API work starts.

### Events

`bus.billing.status.request` asks for one account's billing status.

`bus.billing.status.response` returns status, enabled features, quota usage,
and setup or upgrade guidance.

`bus.billing.checkout_session.request` asks for a hosted billing setup URL.

`bus.billing.checkout_session.response` returns the setup URL and provider
name.

In event-backed mode, checkout requests trigger a provider checkout request such
as `bus.stripe.checkout_session.create.request`.

`bus.billing.portal_session.request` asks for a hosted billing portal URL.

`bus.billing.portal_session.response` returns the portal URL and provider name.

In event-backed mode, portal requests trigger a provider portal request such as
`bus.stripe.portal_session.create.request`.

`bus.billing.entitlement.check.request` asks whether an account may receive a
billable feature scope.

`bus.billing.entitlement.check.response` returns an allow/deny decision. Denied
paid-feature access uses the provider-neutral `billing_required` reason and
`bus billing setup` command. Exhausted plan quotas use `quota_exceeded` and
include the exhausted quota window.

`bus.billing.subscription.update` applies a provider-neutral subscription update
from a payment provider integration. It is idempotent by `event_id`, enables
listed features only when status is `active`, and disables paid-feature access
for `past_due`, `canceled`, `incomplete`, or unknown statuses.

`bus.billing.subscription.result` returns the correlated application result.

`bus.billing.usage.export.request` asks the billing domain to export one
provider-neutral usage metric to a payment meter. Requests identify
`account_id`, billable `feature`, `meter_event_name`, positive integer
`quantity`, and an idempotency `event_id`. `bus-integration-usage` can emit
these requests automatically from canonical usage records; the first built-in
usage mappings are LLM tokens and successful container runtime seconds. If
feature or meter is omitted, the billing worker keeps the LLM-compatible
defaults `llm:proxy` and `bus_llm_tokens`.

`bus.billing.usage.export.response` returns export status, quantity, meter name,
idempotency key, and provider event metadata. Successfully exported
idempotency keys are not sent to the provider again. Failed exports are stored
as failed and remain retryable.

In event-backed mode, usage export triggers a provider meter event such as
`bus.stripe.meter_event.record.request`.
Successful usage exports increment matching quota buckets once per idempotency
key; duplicate export requests do not double-count quota usage.

### Provider Backend Configuration

`BUS_BILLING_QUOTA_CONFIG` points to the provider-neutral JSON quota
configuration used for plan enforcement.

- `BUS_BILLING_PROVIDER_BACKEND=local|events`
- `BUS_BILLING_PROVIDER=stripe`
- `BUS_BILLING_PROVIDER_TIMEOUT=30s`
- `BUS_BILLING_STORE_BACKEND=memory|postgres`
- `BUS_BILLING_DATABASE_URL=postgres://...`

The default provider event names target the current Stripe integration. The
mapping is configurable through the Go `EventSessionProvider` and
`EventMeterRecorder` boundaries for future providers.

### Quota Configuration

A quota rule connects a Bus feature, a usage meter, a time window, and a limit.
The same plan can have several rules for the same feature. For example, an LLM
plan can limit both tokens per minute and tokens per month; a container plan
can limit runtime seconds per day and per month. When any matching quota is
exhausted, entitlement checks deny new billable work before the API provider
starts expensive processing.

Common built-in meter names are `bus_llm_tokens` for LLM token usage and
`bus_container_runtime_seconds` for successful container runtime. Additional
meters can be added through the usage export policy in
`bus-integration-usage` and corresponding plan quota rules.

Quota counters are updated when usage export succeeds. Replayed usage export
requests with the same idempotency key do not increment quota buckets again.

### Production Flow

In a Stripe-backed deployment, the billing provider receives a user checkout
request from `bus-api-provider-billing`, asks `bus-integration-stripe` to create
the hosted Checkout Session, and later receives a provider-neutral
`bus.billing.subscription.update` event from the Stripe webhook path. Once the
subscription is active, entitlement checks allow the enabled feature scopes.

LLM and container API providers call the entitlement check before doing
billable work. Accepted usage is recorded through `bus-integration-usage`,
which can then emit usage export requests back to this billing worker. This
keeps payment-provider details out of the API providers while still allowing
plans to enforce limits for different usage metrics.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api-provider-billing">bus api provider billing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-integration-stripe">bus integration stripe</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-api-provider-billing](./bus-api-provider-billing)
- [bus-integration-stripe](./bus-integration-stripe)
