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

### Run The Worker

Run a deterministic local check with:

```sh
bus-integration-billing --self-test
```

For an Events-backed local worker with durable storage, provide a Bus Events API
URL, a service token, and PostgreSQL storage:

```sh
export BUS_EVENTS_API_URL=http://127.0.0.1:8081
export BUS_API_TOKEN="$(cat ./local/billing-worker.token)"
BUS_BILLING_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_billing?sslmode=disable' \
bus-integration-billing \
  --events-url "$BUS_EVENTS_API_URL" \
  --store-backend postgres \
  --provider-backend local
```

The service token needs the billing event scopes used by the enabled features,
typically `billing:read`, `billing:setup`, `billing:entitlement:check`,
`billing:subscription:write`, `billing:usage:export`, and
`billing:provider` when provider-backed checkout, portal, or meter events are
enabled.

### Events

Every request/reply event uses the Bus Events envelope `correlation_id`.
Responses copy the request correlation identifier so callers can match the
reply to the request. If processing fails, the response event carries the same
correlation identifier and an event error such as `billing_unavailable` with a
human-readable message. Provider-backed calls use the configured provider
timeout; timeout failures are returned as billing errors instead of silently
hanging.

`bus.billing.status.request` asks for one account's billing status. Payload:

```json
{"account_id":"account-uuid"}
```

`account_id` is required. The worker returns `billing_unavailable` when the
store cannot read the account. Unknown accounts return a normal missing-status
response rather than an event error.

`bus.billing.status.response` returns status, enabled features, quota usage,
and setup or upgrade guidance. Payload:

```json
{
  "account_id": "account-uuid",
  "status": "active",
  "provider": "stripe",
  "plan_id": "llm-pro",
  "features": ["llm:proxy"],
  "usage": [],
  "setup_required": false
}
```

`status` is one of `missing`, `incomplete`, `active`, `past_due`, or
`canceled`. When setup is required, `setup_required=true`, `next_action` is
`setup_billing`, and `command` is usually `bus billing setup`.

`usage` is omitted or empty when the account has no quota policy. Each usage
item has `feature`, `meter_event_name`, `window`, `used`, `limit`,
`remaining`, `exceeded`, and optional `upgrade_plan_id`. `used`, `limit`, and
`remaining` are integer meter units such as tokens or runtime seconds. If any
usage item is exceeded, `upgrade_required=true`, `setup_required=false`,
`next_action=upgrade_plan`, `recommended_plan` is copied from
`upgrade_plan_id` when configured, and `command` remains the user-facing setup
or upgrade command. Optional fields are omitted when they do not apply.

`bus.billing.checkout_session.request` asks for a hosted billing setup URL.
Payload:

```json
{"account_id":"account-uuid","feature":"llm:proxy","return_url":"https://app.example.test/billing/return"}
```

`account_id` is required. `feature` and `return_url` are optional. In
event-backed mode, checkout requests trigger a provider checkout request such
as `bus.stripe.checkout_session.create.request`.

`bus.billing.checkout_session.response` returns the setup URL and provider
name. Payload:

```json
{"url":"https://provider.example.test/checkout/session","provider":"stripe"}
```

`url` is required in provider responses. If a provider response omits
`provider`, the billing worker fills it from the configured provider label.

`bus.billing.portal_session.request` asks for a hosted billing portal URL.
Payload:

```json
{"account_id":"account-uuid","return_url":"https://app.example.test/billing/return"}
```

`account_id` is required. `return_url` is optional. In event-backed mode,
portal requests trigger a provider portal request such as
`bus.stripe.portal_session.create.request`.

`bus.billing.portal_session.response` returns the portal URL and provider name.
Payload:

```json
{"url":"https://provider.example.test/customer/portal","provider":"stripe"}
```

`url` is required in provider responses. If a provider response omits
`provider`, the billing worker fills it from the configured provider label.

`bus.billing.entitlement.check.request` asks whether an account may receive a
billable feature scope. Payload:

```json
{"account_id":"account-uuid","scope":"llm:proxy"}
```

`account_id` and `scope` are required.

`bus.billing.entitlement.check.response` returns an allow/deny decision. Denied
paid-feature access uses the provider-neutral `billing_required` reason and
`bus billing setup` command. Exhausted plan quotas use `quota_exceeded` and
include the exhausted quota window. Payload:

```json
{
  "allowed": false,
  "reason": "quota_exceeded",
  "command": "bus billing setup",
  "plan_id": "llm-basic",
  "recommended_plan": "llm-pro",
  "usage": {
    "feature": "llm:proxy",
    "meter_event_name": "bus_llm_tokens",
    "window": "month",
    "used": 1000000,
    "limit": 1000000,
    "remaining": 0,
    "exceeded": true,
    "upgrade_plan_id": "llm-pro"
  }
}
```

Allowed responses use `allowed=true` and `reason=billing_active`. Missing or
inactive billing uses `reason=billing_required`. Quota denial responses use
the optional `usage` object to identify the exhausted quota; the quota window
is `usage.window`.

`bus.billing.subscription.update` applies a provider-neutral subscription update
from a payment provider integration. It is idempotent by `event_id`, enables
listed features only when status is `active`, and disables paid-feature access
for `past_due`, `canceled`, `incomplete`, or unknown statuses. Payload:

```json
{
  "event_id": "provider-event-id",
  "account_id": "account-uuid",
  "provider": "stripe",
  "provider_customer_id": "cus_123",
  "provider_subscription_id": "sub_123",
  "plan_id": "llm-pro",
  "status": "active",
  "features": ["llm:proxy"]
}
```

`event_id`, `account_id`, `provider`, and `status` are required. Duplicate
`event_id` values are accepted but do not reapply the update.

`bus.billing.subscription.result` returns the correlated application result.
Payload:

```json
{"account_id":"account-uuid","status":"active","applied":true}
```

`applied=false` means the update was a duplicate or otherwise did not change
stored billing state.

`bus.billing.usage.export.request` asks the billing domain to export one
provider-neutral usage metric to a payment meter. Requests identify
`account_id`, billable `feature`, `meter_event_name`, positive integer
`quantity`, and an idempotency `event_id`. `bus-integration-usage` can emit
these requests automatically from canonical usage records; the first built-in
usage mappings are LLM tokens and successful container runtime seconds. If
feature or meter is omitted, the billing worker keeps the LLM-compatible
defaults `llm:proxy` and `bus_llm_tokens`.
Payload:

```json
{
  "event_id": "usage-event-id",
  "account_id": "account-uuid",
  "event_type": "llm_request_finished",
  "feature": "llm:proxy",
  "meter_event_name": "bus_llm_tokens",
  "quantity": 1200,
  "data": {
    "total_tokens": 1200
  }
}
```

`account_id` is required. `quantity` must be a positive integer after defaults
and LLM token derivation are applied. `event_id` is the preferred idempotency
key. If it is omitted, the worker derives a deterministic key from account,
meter, and quantity; callers should still send stable event IDs to avoid
collisions between separate equal-sized usage records.

`data` is an optional object for raw usage fields. If `quantity` is omitted,
LLM quantity is derived from `data.total_tokens`, `data.tokens`,
`data.input_tokens + data.output_tokens`, or
`data.prompt_tokens + data.completion_tokens`, in that order. Numeric values
must decode as integers or JSON numbers. Container usage should normally send
`quantity` directly in runtime seconds because no container-specific derived
field is currently read from `data`.

`event_type` is optional. It is a provider-neutral source label such as
`llm_request_finished` or `container_run_finished`; the billing worker accepts
it for audit and troubleshooting context but does not use it as the
idempotency key, meter event name, token derivation input, or quota selector.
Those decisions come from `event_id`, `account_id`, `feature`,
`meter_event_name`, `quantity`, and `data`.

`bus.billing.usage.export.response` returns export status, quantity, meter name,
idempotency key, and provider event metadata. Successfully exported
idempotency keys are not sent to the provider again. Failed exports are stored
as failed and remain retryable. Payload:

```json
{
  "account_id": "account-uuid",
  "meter_event_name": "bus_llm_tokens",
  "quantity": 1200,
  "idempotency_key": "usage-event-id",
  "status": "exported",
  "exported": true,
  "provider": "stripe",
  "provider_event_id": "meter-event-id"
}
```

`exported=true` means the provider accepted the meter event or the local
provider accepted the record. A failed export includes `exported=false`,
`status=failed`, and `reason`.

In event-backed mode, usage export triggers a provider meter event such as
`bus.stripe.meter_event.record.request`.
Successful usage exports increment matching quota buckets once per idempotency
key; duplicate export requests do not double-count quota usage.

### Provider Backend Configuration

`BUS_BILLING_QUOTA_CONFIG` points to the provider-neutral JSON quota
configuration used for plan enforcement.

| Setting | Required | Default | Valid values | Failure behavior |
| --- | --- | --- | --- | --- |
| `BUS_EVENTS_API_URL` or `--events-url` | Required for event-listener mode. Not required for `--self-test`. | Empty. | Bus Events API collection URL. | Missing or unreachable URL prevents the worker from receiving billing requests. |
| `BUS_API_TOKEN` | Required when connecting to a secured Events API. Not required for in-memory self-test. | Empty. | Bus API token with scopes such as `billing:read`, `billing:setup`, `billing:entitlement:check`, `billing:subscription:write`, `billing:usage:export`, and `billing:provider` according to enabled provider flows. | Missing, expired, or underscoped tokens produce Events API authentication or authorization failures. |
| `BUS_BILLING_PROVIDER_BACKEND` or `--provider-backend` | Optional. | `local`. | `local`, `events`. | Unknown values are not useful in production; provider calls fail when the selected backend cannot create sessions or meter events. |
| `BUS_BILLING_PROVIDER` or `--provider` | Optional for `local`; required operationally for `events` when provider labels matter. | `stripe`. | Provider label such as `stripe`. | Used in provider event payloads and responses; mismatched labels can route requests to the wrong provider integration. |
| `BUS_BILLING_PROVIDER_TIMEOUT` or `--provider-timeout` | Optional. | `30s`. | Go duration such as `5s`, `30s`, or `2m`; integer environment values are seconds. | Provider request/reply calls return timeout errors after this duration. |
| `BUS_BILLING_STORE_BACKEND` or `--store-backend` | Optional. | `memory`. | `memory`, `postgres`. | Unknown backends fail readiness with an unsupported-backend error. |
| `BUS_BILLING_DATABASE_URL` | Required when `BUS_BILLING_STORE_BACKEND=postgres`. Ignored by `memory`. | Empty. | PostgreSQL connection URL. | Missing value with `postgres` makes storage unavailable and the worker exits on readiness. |
| `BUS_BILLING_QUOTA_CONFIG` or `--quota-config` | Optional. Required only when the deployment enforces quotas. | Empty, meaning no quota rules. | Path to a JSON quota policy file. | Missing file, invalid JSON, duplicate quota rules, unsupported windows, or non-positive limits make startup fail. |

Use `BUS_BILLING_PROVIDER_BACKEND=local` for deterministic local responses.
Use `BUS_BILLING_PROVIDER_BACKEND=events` when hosted setup, portal, and meter
recording should be delegated to another provider integration such as
`bus-integration-stripe`.

Use `BUS_BILLING_STORE_BACKEND=memory` only for local development or
single-process checks. Use `BUS_BILLING_STORE_BACKEND=postgres` with
`BUS_BILLING_DATABASE_URL` for durable account billing status, usage export
idempotency, and quota buckets.

The default provider event names target the current Stripe integration. The
mapping is configurable through the Go `EventSessionProvider` and
`EventMeterRecorder` boundaries for future providers.

The BusDK superproject `compose.yaml` runs this worker as `bus-billing-worker`
with `--store-backend postgres`, `BUS_BILLING_DATABASE_URL`, and
`--events-url http://bus-events:8081`. The default local provider backend is
`local`, which returns deterministic setup and portal responses. Set
`BUS_LOCAL_BILLING_PROVIDER_BACKEND=events` in the superproject `.env` file or
on the compose command line when the local stack should route checkout, portal,
and meter calls through a provider integration such as `bus-integration-stripe`:

```sh
BUS_LOCAL_BILLING_PROVIDER_BACKEND=events docker compose up --build
```

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

The quota file has one top-level object with `plans`. Each plan has a required
`id` and optional `quotas`. Each quota requires `feature`,
`meter_event_name`, `window`, and `limit`. `upgrade_plan_id` is optional and
is returned as upgrade guidance when the quota is exhausted.

Accepted `window` values are `minute`, `hour`, `day`, `week`, `month`, and
`total`. Common aliases such as `minutes`, `daily`, `weekly`, `monthly`,
`lifetime`, and `all` are normalized to those values. `limit` must be a
positive integer. A plan cannot define two quotas with the same `feature`,
`meter_event_name`, and `window`.

Minimal LLM and container quota file:

```json
{
  "plans": [
    {
      "id": "starter",
      "quotas": [
        {
          "feature": "llm:proxy",
          "meter_event_name": "bus_llm_tokens",
          "window": "month",
          "limit": 1000000,
          "upgrade_plan_id": "pro"
        },
        {
          "feature": "container:run",
          "meter_event_name": "bus_container_runtime_seconds",
          "window": "day",
          "limit": 3600,
          "upgrade_plan_id": "pro"
        }
      ]
    }
  ]
}
```

Use it by setting:

```sh
export BUS_BILLING_QUOTA_CONFIG=/etc/bus/billing-quotas.json
```

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
