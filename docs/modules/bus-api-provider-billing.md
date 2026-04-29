---
title: bus-api-provider-billing — Billing API provider
description: bus-api-provider-billing exposes provider-neutral billing status and setup APIs.
---

## `bus-api-provider-billing` — Billing API provider

`bus-api-provider-billing` serves public end-user billing APIs. It validates Bus
API JWTs, derives `account_id` from JWT `sub`, and delegates billing state and
setup work to integrations. It does not contain Stripe-specific code.

Public endpoints are caller-owned only. The provider derives account identity
from JWT `sub` and rejects caller-supplied account metadata. Internal catalog,
cross-account status, and entitlement-check endpoints require the internal
audience with narrow billing scopes. Error responses redact bearer tokens,
Stripe secret keys, and PostgreSQL passwords.

Production deployments should configure PostgreSQL catalog storage with
`BUS_BILLING_DATABASE_URL`. The provider creates a minimal catalog schema when
it is missing. Without a database URL, internal catalog endpoints return a
deterministic storage-unavailable error instead of silently using volatile
storage.

### Public Authentication

Public endpoints require an end-user API JWT with audience `ai.hg.fi/api`.
The account is always derived from JWT `sub`.

### Internal Authentication

Internal endpoints require audience `ai.hg.fi/internal` and narrow billing
scopes. End-user API tokens are rejected.

### `GET /api/v1/billing/status`

Returns billing state for the authenticated account.

The response can include enabled features, current quota usage, setup guidance,
and upgrade guidance. Requires `billing:read`.

### `POST /api/v1/billing/checkout-session`

Creates a hosted billing setup URL for the authenticated account.

The URL may point to Stripe Checkout or another configured provider. Requires
`billing:setup`.

### `POST /api/v1/billing/portal-session`

Creates a hosted billing portal URL for the authenticated account.

Users manage payment methods, invoices, and subscriptions in the provider
portal. Requires `billing:read`.

### `GET /api/internal/billing/catalog`

Returns the active provider-neutral billing catalog.

Requires `billing:catalog:read` with the internal audience.

### `PUT /api/internal/billing/catalog`

Replaces the active provider-neutral billing catalog.

Requires `billing:catalog:write` with the internal audience.

The catalog describes products, plans, prices, meters, feature scopes, quota
rules, and optional non-secret provider mappings.

### `GET /api/internal/billing/accounts/{account_id}/status`

Returns billing status for an operator-selected account.

Requires `billing:read` with the internal audience.

### `POST /api/internal/billing/entitlement-check`

Checks whether an account may use a paid feature such as `llm:proxy` or
`container:run`.

Requires `billing:entitlement:check` with the internal audience. LLM and
container providers call this before starting billable work.

Denied responses use stable reasons such as `billing_required` and
`quota_exceeded`, with user-facing guidance when available.

### `GET /readyz`

Reports process readiness.

Use this for load balancers and service supervisors.

### Catalog Rules

Catalog data should describe commercial plans in Bus terms. Common meters are
`bus_llm_tokens` and `bus_container_runtime_seconds`.

Plans may define several quota windows at the same time, such as `minute`,
`hour`, `day`, `week`, `month`, and `total`.

Do not store Stripe secret keys, webhook secrets, database passwords, or other
deployment secrets in the catalog.

### `BUS_BILLING_DATABASE_URL`

Enables durable PostgreSQL catalog storage.

Without this value, internal catalog endpoints return a deterministic
storage-unavailable error instead of using volatile storage.

### Events Backend

When configured with Events, the provider maps HTTP requests to billing events
and waits for correlated responses.

Public status/setup requests use `bus.billing.status.request`,
`bus.billing.checkout_session.request`, and
`bus.billing.portal_session.request`.

Internal entitlement checks use `bus.billing.entitlement.check.request`.

### Events

When configured with the Events backend, the provider triggers
`bus.billing.status.request`, `bus.billing.checkout_session.request`, and
`bus.billing.portal_session.request`, then returns the correlated responses.
Internal entitlement checks trigger `bus.billing.entitlement.check.request` and
return the correlated entitlement response.

### Deployment Checklist

Configure the provider with the same JWT audience and signing secret policy as
the rest of the Bus API deployment. Public billing endpoints accept only
end-user API JWTs. Internal endpoints accept only internal-audience JWTs.

Run `bus-integration-billing` with durable storage so subscription state,
entitlements, idempotency keys, usage export state, and quota buckets survive
restarts. Run `bus-integration-stripe` or another payment-provider integration
when hosted setup, portal sessions, webhooks, and payment-meter events should
use a real provider.

Use `bus operator billing catalog put --file <catalog.json>` to publish the
provider-neutral catalog, and use `bus operator stripe catalog sync --file
<catalog.json>` when Stripe products and prices should be synchronized from the
same catalog.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-billing">bus billing</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-integration-billing">bus integration billing</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus billing](./bus-billing)
- [bus integration billing](./bus-integration-billing)
- [Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes)
