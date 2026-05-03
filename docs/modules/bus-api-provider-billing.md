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
Send the token as `Authorization: Bearer <jwt>` on every public request.

### Internal Authentication

Internal endpoints require audience `ai.hg.fi/internal` and narrow billing
scopes. End-user API tokens are rejected.
Send the internal token as `Authorization: Bearer <jwt>` on every internal
request.

### `GET /api/v1/billing/status`

Returns billing state for the authenticated account.

The response can include enabled features, current quota usage, setup guidance,
and upgrade guidance. Requires `billing:read`.

### `POST /api/v1/billing/checkout-session`

Creates a hosted billing setup URL for the authenticated account.

The URL may point to Stripe Checkout or another configured provider. Requires
`billing:setup`.
Send `Content-Type: application/json` with either `{}` or
`{"feature":"llm:proxy","return_url":"https://app.example.test/billing/return"}`.
Success returns `200 OK` with `{"url":"https://...","provider":"stripe"}`.

### `POST /api/v1/billing/portal-session`

Creates a hosted billing portal URL for the authenticated account.

Users manage payment methods, invoices, and subscriptions in the provider
portal. Requires `billing:read`.
Send `Content-Type: application/json` with `{}` or
`{"return_url":"https://app.example.test/billing/return"}`.
Success returns `200 OK` with `{"url":"https://...","provider":"stripe"}`.

### `GET /api/internal/billing/catalog`

Returns the active provider-neutral billing catalog.

Requires `billing:catalog:read` with the internal audience.

### `PUT /api/internal/billing/catalog`

Replaces the active provider-neutral billing catalog.

Requires `billing:catalog:write` with the internal audience.

The catalog describes products, plans, prices, meters, feature scopes, quota
rules, and optional non-secret provider mappings.
Send JSON with top-level `products`, `plans`, and `meters` arrays. Product and
plan IDs must be stable strings, prices use integer minor units, and quota
limits must be positive integers. A minimal accepted catalog is:

```json
{
  "products": [{"id": "llm", "name": "LLM access"}],
  "meters": [{"name": "bus_llm_tokens", "unit": "tokens"}],
  "plans": [{
    "id": "llm-basic",
    "product_id": "llm",
    "features": ["llm:proxy"],
    "prices": [{"currency": "eur", "unit_amount": 1000, "interval": "month"}],
    "quotas": [{"feature": "llm:proxy", "meter_event_name": "bus_llm_tokens", "window": "month", "limit": 1000000}]
  }]
}
```

Success returns `200 OK` with the stored catalog or update status. Invalid
catalog JSON returns `400`, missing internal audience or
`billing:catalog:write` returns `401` or `403`, and unavailable catalog storage
returns `503`.

### `GET /api/internal/billing/accounts/{account_id}/status`

Returns billing status for an operator-selected account.

Requires `billing:read` with the internal audience.
`account_id` must be the stable account UUID used as the API token subject.
Success returns the same billing status shape as the public status endpoint for
that account. Invalid UUIDs return `400`; missing internal authority returns
`401` or `403`.

### `POST /api/internal/billing/entitlement-check`

Checks whether an account may use a paid feature such as `llm:proxy` or
`container:run`.

Requires `billing:entitlement:check` with the internal audience. LLM and
container providers call this before starting billable work.

Denied responses use stable reasons such as `billing_required` and
`quota_exceeded`, with user-facing guidance when available.
Use the stable account UUID from the auth provider or API token `sub`; for
example, send
`{"account_id":"00000000-0000-4000-8000-000000000001","scope":"llm:proxy","usage":{"meter_event_name":"bus_llm_tokens","quantity":1200}}`.
`usage` is optional for setup-only checks and required when the caller wants a
quota-aware decision for a specific unit count. Success returns `200 OK` with
`{"allowed":true,"reason":"billing_active"}` or
`{"allowed":false,"reason":"quota_exceeded","command":"bus billing setup"}`.
Invalid requests return `400`, missing or wrong internal authority returns
`401` or `403`, and unavailable billing storage returns `503`.

### `GET /readyz`

Reports process readiness.

Use this for load balancers and service supervisors. A ready process returns
`200 OK` with `{"ok":true}`. If the process is not accepting requests, the
supervisor or load balancer sees a connection failure or another non-2xx HTTP
status and should keep the instance out of rotation.

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
Use a PostgreSQL URL with a role that can create and update the billing catalog
tables and indexes in the selected database/schema:

```text
postgres://bus_billing:password@postgres.example.internal:5432/bus_billing?sslmode=require
```

Use `sslmode=disable` only for trusted local development networks.

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

### Local Compose Stack

The BusDK superproject `compose.yaml` starts this provider as
`bus-billing-api` with `--backend events` and `--events-url
http://bus-events:8081`. Nginx publishes public billing endpoints at
`/api/v1/billing/*` and internal billing endpoints at
`/api/internal/billing/*` on the local API port. Billing state and entitlement
answers come from `bus-integration-billing`; this provider remains the
JWT-secured HTTP boundary for browser and API clients.

### Deployment Checklist

Configure the provider with the same JWT audience and signing secret policy as
the rest of the Bus API deployment. Public billing endpoints accept only
end-user API JWTs. Internal endpoints accept only internal-audience JWTs.
Set `BUS_BILLING_JWT_SECRET` to the HS256 secret trusted for billing API
tokens, or use the deployment's configured JWT secret source. Public requests
use audience `ai.hg.fi/api`; internal requests use `ai.hg.fi/internal`. The
scope contract is documented in
[Bus API JWT audiences and scopes](../architecture/api-jwt-audiences-and-scopes).

Start the provider with either the local deterministic backend or the Events
backend. Events mode requires the Events URL and a provider token with billing
event scopes:

```sh
bus operator token \
  --api-url https://api.example.test \
  --internal-key-file /run/secrets/bus-auth-internal-key \
  --format token \
  issue \
  --subject billing-provider \
  --audience ai.hg.fi/api \
  --scope "billing:read billing:setup billing:entitlement:check billing:subscription:write billing:usage:export billing:provider" \
  --ttl 1h > /run/secrets/bus-billing-provider.token

BUS_BILLING_JWT_SECRET="$(cat /run/secrets/bus-api-jwt-secret)" \
BUS_BILLING_DATABASE_URL="$(cat /run/secrets/bus-billing-database-url)" \
BUS_API_TOKEN="$(cat /run/secrets/bus-billing-provider.token)" \
bus-api-provider-billing \
  --addr 0.0.0.0:8083 \
  --backend events \
  --events-url http://bus-events:8081
```

Run `bus-integration-billing` with durable storage so subscription state,
entitlements, idempotency keys, usage export state, and quota buckets survive
restarts. Run `bus-integration-stripe` or another payment-provider integration
when hosted setup, portal sessions, webhooks, and payment-meter events should
use a real provider.

Create a provider-neutral catalog file, publish it, and verify it through the
operator API:
the operator token must target the Billing API deployment and include
`billing:catalog:read` and `billing:catalog:write`.

```sh
bus operator token \
  --api-url https://api.example.test \
  --internal-key-file /run/secrets/bus-auth-internal-key \
  --format token \
  issue \
  --subject billing-operator \
  --audience ai.hg.fi/internal \
  --scope "billing:catalog:read billing:catalog:write" \
  --ttl 1h > /run/secrets/bus-billing-operator.token

mkdir -p ./local
bus operator billing catalog template > ./local/billing-catalog.json
bus operator billing \
  --api-url https://api.example.test \
  --token-file /run/secrets/bus-billing-operator.token \
  catalog put --file ./local/billing-catalog.json
bus operator billing \
  --api-url https://api.example.test \
  --token-file /run/secrets/bus-billing-operator.token \
  catalog get
```

Use `bus operator stripe catalog sync --file ./local/billing-catalog.json` when
Stripe products and prices should be synchronized from the same catalog.

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
