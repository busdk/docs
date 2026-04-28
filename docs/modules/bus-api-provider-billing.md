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

Production deployments should set `BUS_BILLING_DATABASE_URL` or pass
`--database-url` so operator-managed catalog data is durable. The provider
creates a minimal PostgreSQL catalog schema when missing. Without a database
URL, internal catalog endpoints return a deterministic storage-unavailable
error.

### API

`GET /api/v1/billing/status` returns billing state and enabled features for the
caller. It requires `aud=ai.hg.fi/api` with `billing:read`.

`POST /api/v1/billing/checkout-session` creates a hosted billing setup URL for
the caller. It requires `aud=ai.hg.fi/api` with `billing:setup`.

`POST /api/v1/billing/portal-session` creates a hosted billing portal URL for
the caller. It requires `aud=ai.hg.fi/api` with `billing:read`.

`GET /readyz` reports process readiness.

`GET /api/internal/billing/catalog` returns the active provider-neutral billing
catalog. It requires `aud=ai.hg.fi/internal` with `billing:catalog:read`.

`PUT /api/internal/billing/catalog` replaces the active provider-neutral billing
catalog. It requires `aud=ai.hg.fi/internal` with `billing:catalog:write`.

The catalog is provider-neutral JSON for products, plans, prices, usage meters,
and optional non-secret provider mappings. Stripe-specific synchronization is
handled separately by `bus operator stripe`.

`GET /api/internal/billing/accounts/{account_id}/status` returns billing status
for an operator-selected account. It requires `aud=ai.hg.fi/internal` with
`billing:read`.

`POST /api/internal/billing/entitlement-check` checks whether an account may use
a paid feature or scope such as `llm:proxy`. It is an internal service endpoint
for API providers, requires `aud=ai.hg.fi/internal` with
`billing:entitlement:check`, and rejects end-user API tokens. Denied responses
return deterministic guidance such as `billing_required` and
`bus billing setup`.

### Events

When configured with the Events backend, the provider triggers
`bus.billing.status.request`, `bus.billing.checkout_session.request`, and
`bus.billing.portal_session.request`, then returns the correlated responses.
Internal entitlement checks trigger `bus.billing.entitlement.check.request` and
return the correlated entitlement response.

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
