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

### API

`GET /api/v1/billing/status` returns billing state, enabled features, current
quota usage, setup guidance, and upgrade guidance for the caller. It requires
an end-user API JWT with `aud=ai.hg.fi/api` and `billing:read`.

`POST /api/v1/billing/checkout-session` creates a hosted billing setup URL for
the caller. It requires `aud=ai.hg.fi/api` with `billing:setup`. The response
is provider-neutral and contains a URL that may point to Stripe Checkout or
another configured payment provider.

`POST /api/v1/billing/portal-session` creates a hosted billing portal URL for
the caller. It requires `aud=ai.hg.fi/api` with `billing:read`. The portal is
for payment method, invoice, and subscription management in the configured
payment provider.

`GET /readyz` reports process readiness.

`GET /api/internal/billing/catalog` returns the active provider-neutral billing
catalog. It requires `aud=ai.hg.fi/internal` with `billing:catalog:read`.

`PUT /api/internal/billing/catalog` replaces the active provider-neutral billing
catalog. It requires `aud=ai.hg.fi/internal` with `billing:catalog:write`.

The catalog is provider-neutral JSON for products, plans, prices, usage meters,
plan quotas, and optional non-secret provider mappings. A plan may define
multiple quota windows at the same time, such as `minute`, `hour`, `day`,
`week`, `month`, and `total`. Stripe-specific synchronization is handled
separately by `bus operator stripe`; quota enforcement is handled by
`bus-integration-billing`.

Catalog data should describe the commercial plan in Bus terms: feature scopes
such as `llm:proxy` and `container:run`, meter names such as
`bus_llm_tokens` and `bus_container_runtime_seconds`, limits, and optional
upgrade targets. Keep secret provider credentials out of the catalog.

`GET /api/internal/billing/accounts/{account_id}/status` returns billing status
for an operator-selected account. It requires `aud=ai.hg.fi/internal` with
`billing:read`.

`POST /api/internal/billing/entitlement-check` checks whether an account may use
a paid feature or scope such as `llm:proxy` or `container:run`. It is an
internal service endpoint for API providers, requires
`aud=ai.hg.fi/internal` with `billing:entitlement:check`, and rejects end-user
API tokens. Denied responses return deterministic guidance such as
`billing_required` and `bus billing setup`; exhausted quotas return
`quota_exceeded` with quota details.

LLM and container API providers call this endpoint before starting billable
work when billing enforcement is enabled. This prevents GPU wake-up, backend
proxying, or container runner delegation for accounts that are unpaid,
inactive, or over quota.

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
