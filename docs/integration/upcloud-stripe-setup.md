---
title: "Set up UpCloud runtime and Stripe billing"
description: Operator tutorial for wiring BusDK Events, auth, billing, Stripe, usage, and UpCloud runtime workers into one deployment.
---

## Deployment Path

This tutorial wires the BusDK AI product stack so approved users can authenticate, set up billing, and run paid VM or container-backed work. UpCloud provides the runtime infrastructure. Stripe provides hosted checkout, customer portal, subscription state, and meter-event delivery. BusDK keeps public user APIs provider-neutral through [billing](../modules/bus-api-provider-billing), [usage](../modules/bus-api-provider-usage), [VM](../modules/bus-api-provider-vm), [containers](../modules/bus-api-provider-containers), and [Events](../modules/bus-api-provider-events) providers.

Use test-mode Stripe keys and non-production UpCloud resources first. Replace every placeholder value with deployment secrets from your secret manager or local untracked operator environment files. Do not commit real API keys, webhook secrets, JWT signing secrets, database URLs with passwords, or issued tokens.

## Prerequisites

Start from a Bus API deployment with the auth, events, billing, usage, VM, and container API providers enabled. The auth provider must issue `aud=ai.hg.fi/api` user tokens for public APIs. Workers that publish or listen through the Events API also use `aud=ai.hg.fi/api` tokens with narrow event-domain scopes, while internal service-only endpoints use `aud=ai.hg.fi/internal` tokens. Events should use Redis or PostgreSQL when requests must survive process restarts; memory is useful only for local development.

Prepare durable PostgreSQL databases for auth, billing, and usage state. Billing state should survive restarts because it contains catalog data, subscription state, idempotency keys, usage export progress, and quota buckets. Usage state should survive restarts because billing export and quota accounting depend on stable usage records.

Create or identify the UpCloud resources used by the deployment. A VM flow needs the UpCloud server name or UUID for the model/runtime VM. A container flow needs the container-runner server name or UUID and SSH access from the UpCloud worker to that runner. Keep the UpCloud API token in a secret manager or an untracked environment file.

Create Stripe test-mode credentials in the Stripe dashboard. The operator key used by `bus operator stripe` must be a test-mode secret key that can read balance metadata and create Products and Prices. The Stripe integration worker also needs the test-mode secret key and webhook signing secret.

## Configure Shared Environment

Use stable service URLs and token files so every worker talks to the same Bus API deployment:

```sh
export BUS_API_URL=https://api.example.test
export BUS_EVENTS_API_URL="$BUS_API_URL/api/v1/events"
export BUS_AUTH_API_URL="$BUS_API_URL/api/v1/auth"
export BUS_BILLING_API_URL="$BUS_API_URL/api/v1/billing"
```

Generate service tokens with narrow scopes. In a production deployment, issue these through the auth provider internal token endpoint or an operator token service. The examples show the command shape; store the output in private files or secret-manager entries:

```sh
mkdir -p ./local

bus operator token --format token issue \
  --subject bus-integration-billing \
  --audience ai.hg.fi/api \
  --scope "events:send events:listen billing:read billing:setup billing:entitlement:check billing:subscription:write billing:usage:export billing:provider" \
  > ./local/billing-worker.token

bus operator token --format token issue \
  --subject bus-integration-usage \
  --audience ai.hg.fi/api \
  --scope "events:send events:listen usage:write usage:read usage:delete billing:usage:export" \
  > ./local/usage-worker.token

bus operator token --format token issue \
  --subject bus-integration-upcloud \
  --audience ai.hg.fi/api \
  --scope "events:send events:listen vm:read vm:write container:read container:run container:delete ssh:run" \
  > ./local/upcloud-worker.token
```

For local-only token issuing, `BUS_AUTH_HS256_SECRET` must match the signing secret trusted by the target Bus API services. If it does not match, the command can print a token but the API rejects it.

## Publish The Billing Catalog

Create one provider-neutral catalog and use it as the source for both Bus billing and Stripe objects:

```sh
bus operator billing catalog template > catalog.json
```

Edit `catalog.json` so products, plans, features, prices, quotas, meters, and Stripe lookup keys match your product. Keep prices as integer minor units and use stable IDs. Synchronize Stripe test-mode Products and Prices first:

```sh
cat >./.env.stripe-test <<'EOF'
export BUS_STRIPE_SECRET_KEY=sk_test_replace_me
export BUS_STRIPE_WEBHOOK_SECRET=whsec_replace_me
# Optional for older Stripe test accounts:
# export BUS_STRIPE_API_VERSION=2025-02-24.acacia
EOF

. ./.env.stripe-test
bus operator stripe test
bus operator stripe catalog sync --file catalog.json
```

`bus operator stripe test` should report safe metadata such as test/live mode without printing the secret key. `catalog sync` should print a secret-safe summary containing synced Stripe Product and Price IDs.

Publish the same catalog to Bus billing:

```sh
bus operator billing catalog put --file catalog.json
bus operator billing catalog get
```

The `catalog get` response should include the plan and meter IDs that the billing API will use for checkout, entitlements, and quota checks.

## Start Billing, Stripe, And Usage Workers

Run the billing integration with durable storage and the Events API:

```sh
export BUS_API_TOKEN="$(cat ./local/billing-worker.token)"
export BUS_BILLING_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_billing?sslmode=disable'
bus-integration-billing \
  --events-url "$BUS_EVENTS_API_URL" \
  --billing-backend postgres
```

Run the Stripe integration with test-mode secrets:

```sh
. ./.env.stripe-test
export BUS_API_TOKEN="$(cat ./local/billing-worker.token)"
bus-integration-stripe \
  --events-url "$BUS_EVENTS_API_URL" \
  --webhook-addr 127.0.0.1:8081
```

Expose the webhook listener through your HTTPS reverse proxy at
`/api/internal/stripe/webhook` and configure the same path in Stripe. Subscribe
the Stripe endpoint to `checkout.session.completed`,
`customer.subscription.created`, `customer.subscription.updated`, and
`customer.subscription.deleted`. The worker verifies `Stripe-Signature` with
`BUS_STRIPE_WEBHOOK_SECRET` before it publishes Bus billing subscription
updates.

Run the usage worker with durable storage and billing export enabled:

```sh
export BUS_API_TOKEN="$(cat ./local/usage-worker.token)"
export BUS_USAGE_DATABASE_URL='postgres://bus:bus@127.0.0.1:5432/bus_usage?sslmode=disable'
bus-integration-usage \
  --usage-backend postgres \
  --events-url "$BUS_EVENTS_API_URL" \
  --billing-export default
```

The default export policy maps successful LLM token usage to `llm:proxy` / `bus_llm_tokens` and successful container runtime to `container:run` / `bus_container_runtime_seconds`. Use a policy file when your product charges additional metrics.

## Start The UpCloud Worker

Choose the worker mode that matches your runtime. For VM status and lifecycle:

```sh
printf '%s\n' "$OPERATOR_SUPPLIED_UPCLOUD_TOKEN" > ./local/upcloud-token
export BUS_API_TOKEN="$(cat ./local/upcloud-worker.token)"
export UPCLOUD_TOKEN="$(cat ./local/upcloud-token)"
export UPCLOUD_VM_NAME=ai-platform-gpu
bus-integration-upcloud \
  --provider upcloud \
  --events-url "$BUS_EVENTS_API_URL" \
  --vm-name "$UPCLOUD_VM_NAME"
```

For container runner operations:

```sh
export BUS_API_TOKEN="$(cat ./local/upcloud-worker.token)"
export UPCLOUD_TOKEN="$(cat ./local/upcloud-token)"
export UPCLOUD_CONTAINER_RUNNER_NAME=ai-platform-container-runner
bus-integration-upcloud \
  --provider upcloud \
  --events-url "$BUS_EVENTS_API_URL" \
  --container-runner-name "$UPCLOUD_CONTAINER_RUNNER_NAME"
```

Use the [UpCloud integration runbook](../modules/bus-integration-upcloud) when you need systemd service files, environment-file examples, SSH readiness checks, or troubleshooting commands.

## Enable Public User Flows

After the providers and workers are running, users follow the normal auth and billing path. A user registers, verifies the OTP, waits for approval, and requests a scoped API token:

```sh
bus auth register --email user@example.com
bus auth login --email user@example.com
bus auth verify --email user@example.com --otp <otp-from-provider>
bus auth token --scope "billing:read billing:setup vm:read container:read container:run container:delete"
```

The same account then starts billing setup:

```sh
bus billing status
bus billing setup --return-url https://app.example.test/billing/return
```

The Billing API returns a hosted Stripe URL. After checkout and webhook processing, `bus billing status` should show active billing for the account. Paid VM or container features can then pass entitlement checks before starting work:

```sh
bus vm status
bus containers status
bus containers run --profile codex -- sh -c 'printf OK'
```

If billing is missing or quota is exhausted, the public API returns setup or upgrade guidance before starting billable work.

## Smoke Checks

Check service readiness before inviting users:

```sh
curl -fsS "$BUS_API_URL/readyz"
curl -fsS "$BUS_API_URL/api/v1/billing/status" \
  -H "Authorization: Bearer $(cat ~/.config/bus/auth/api-token)"
```

Check Stripe operator access without printing secrets:

```sh
. ./.env.stripe-test
bus operator stripe test
```

Check that UpCloud status flows through the public API:

```sh
bus vm status
bus containers status
```

Inspect the usage worker and API configuration before relying on quota export:

```sh
bus-integration-usage --help
bus-api-provider-usage --help
```

## Operations Notes

Keep Stripe and UpCloud credentials out of user-facing API providers. Provider-specific secrets belong in integration workers or operator-only commands. Public APIs should see Bus JWTs, provider-neutral catalog data, usage records, and entitlement decisions.

Rotate service tokens before expiry, or issue worker tokens with a TTL that matches your operational rotation policy. Keep scopes narrow: the UpCloud worker needs only VM/container event scopes, the usage worker needs usage and billing-export scopes, and the billing/Stripe path needs billing scopes.

Use PostgreSQL for production event, billing, usage, and auth state when restart tolerance matters. Destroying these databases loses queued or replayable events, catalog/subscription state, usage export progress, quota buckets, user approval state, or token revocations depending on the service.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./deployment-and-data-control">Deployment and data control</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Integration and runtime interfaces</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/bus-integration-upcloud">bus integration upcloud</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Deployment and data control](./deployment-and-data-control)
- [bus-api-provider-billing](../modules/bus-api-provider-billing)
- [bus-integration-billing](../modules/bus-integration-billing)
- [bus-integration-stripe](../modules/bus-integration-stripe)
- [bus-operator-stripe](../modules/bus-operator-stripe)
- [bus-integration-usage](../modules/bus-integration-usage)
- [bus-integration-upcloud](../modules/bus-integration-upcloud)
- [bus-api-provider-events](../modules/bus-api-provider-events)
