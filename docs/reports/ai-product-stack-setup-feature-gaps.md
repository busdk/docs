---
title: "AI Product Stack Setup feature gaps"
description: "Module-based feature-gap report for making BusDK AI Product Stack Setup commercially credible with buyer-facing proof, diagnostics, and a deployable stack path."
---

## Scope

This report identifies the software features still needed to sell a BusDK AI
Product Stack Setup package credibly. The review focuses on the current BusDK
modules that already support the AI product platform path: auth, billing,
Stripe, usage, LLM proxying, Codex execution, Events, portal UI, services,
tasks, workers, VM/container APIs, documentation, and the `busdk.com` product
site.

The main conclusion is that BusDK does not need a new auth, billing, event, or
LLM foundation for the first commercial pilot. Those pieces mostly exist. The
missing work is the product proof layer: one reproducible setup path, one
buyer-safe evidence bundle, one diagnostic bundle, clear acceptance criteria,
and a narrower lifecycle/orchestration surface around the modules that are
still pre-product.

## Existing capability

The local AI platform stack already has a broad compose entrypoint in the
BusDK superproject. It includes PostgreSQL, token service, Events, auth, usage,
billing, Stripe integration, notes, VM/container APIs, LLM proxying, Codex
integration, portal modules, Nginx routing, and a testing agent. The
superproject tests already validate the compose configuration and smoke-check
readiness, `/v1/models`, VM/container routes, notes persistence, portal module
mounting, auth waitlist routing, and optional live Codex chat when credentials
are explicitly enabled.

The LLM module already exposes an OpenAI-compatible `/v1/*` surface with JWT
scope checks, event-backed execution, usage recording, runtime wake-up hooks,
model catalog support, and optional billing entitlement checks. The Codex
integration already consumes provider-neutral `bus.llm.*` events and routes
them through Codex App Server via `bus-agent`.

The auth module already supports approval-gated passwordless registration,
OTP flows, waitlist approval, and scoped API tokens. The billing modules
already provide provider-neutral billing APIs, catalog and entitlement checks,
and event-backed billing workers. Stripe integration already covers webhook
verification, catalog sync, test-mode checkout, subscription status mapping,
and secure webhook ingress. Usage integration already records generic usage
events and supports billing export.

Events, task, and portal capabilities are also substantial. Events provides
domain ACLs, protected task and worker events, PostgreSQL persistence, retry
and dead-letter diagnostics, and capability discovery. Task tooling already
uses Events for task threads. The AI portal module is implemented against auth,
billing, quota, LLM, container, and terminal API providers and is marked stable
after production-readiness work in its module plan.

## P0 features

These features are required before selling the first paid AI Product Stack
Setup pilot, unless the offer explicitly scopes them out.

### One-command proof harness

Implement a buyer-facing proof command or script for the local AI product
stack. It should start or attach to the stack, wait for readiness, run a fixed
set of API checks, and write a redacted Markdown or JSON evidence report.

Definition of done:

- Proves `/readyz`, `/v1/models`, auth registration or waitlist route,
  billing status or entitlement route, usage event ingestion, Events
  send/replay, portal health, notes persistence, VM/container status, and the
  dev-task route.
- Supports optional live Codex proof when `BUS_LOCAL_AI_PLATFORM_LIVE_CODEX=1`
  and credentials are present.
- Reports `PASS`, `SKIP`, or `FAIL` per check with exact command, URL, service,
  and redacted environment context.
- Fails closed if required local-only defaults are missing or if tracked config
  contains real Stripe/OpenAI/Codex secrets.

Current owner candidates: BusDK superproject tests/docs, `bus-api-provider-llm`,
`bus-integration-codex`, `bus-api-provider-auth`,
`bus-api-provider-billing`, `bus-integration-usage`, and `bus-portal`.

Current state: smoke tests exist, but they are developer/CI checks. They do
not yet produce a polished buyer-safe proof artifact.

### Single setup profile

Create one explicit AI Product Stack Setup entrypoint. For the first weekend
pilot, this can be a documented compose profile or wrapper around the existing
`compose.yaml`. Longer term it should become a normal Services profile.

Definition of done:

- One documented command starts the stack from a clean checkout.
- One documented command prints service status and public/internal URLs.
- One documented command stops the stack.
- The profile states which services are local demo services, which require
  credentials, and which are intentionally skipped.
- The profile does not depend on hidden local paths or real secrets.

Current owner candidates: BusDK superproject, `bus-services`,
`bus-api-provider-services`, `bus-integration-services`.

Current state: `compose.yaml` and `services.yml` both exist, but they are not
yet one productized setup surface.

### Buyer-facing acceptance checklist

Add a public checklist that defines what a customer receives from an AI Product
Stack Setup engagement and what proof they can verify before paying for
additional work.

Definition of done:

- Lists deliverables: running stack, route catalog, credentials/secrets
  handoff rules, proof report, diagnostic bundle, support window, known
  limitations, and optional Stripe/Codex live proof.
- Separates local proof, hosted proof, and production pilot proof.
- States explicit non-goals for the first paid pilot.

Current owner candidates: `busdk.com`, BusDK docs.

Current state: `busdk.com` describes BusDK as a self-hostable AI product
platform, but does not yet define this specific setup package or its acceptance
criteria.

### Redacted diagnostic bundle

Implement a support diagnostic command for the AI stack. The first version can
be a wrapper script, but it must be deterministic and safe to send to support.

Definition of done:

- Collects module commit pins, compose/service profile, exposed routes,
  readiness status, health endpoints, selected logs, model catalog, billing
  backend mode, auth backend mode, and non-secret environment key presence.
- Redacts token, key, secret, password, cookie, DSN password, and webhook
  fields.
- Includes proof harness result links or embedded summaries.
- Refuses to write raw `.env` or credential files into the bundle.

Current owner candidates: BusDK superproject, `bus-services`, docs.

Current state: individual smoke checks exist, but there is no customer-safe
diagnostic artifact.

### Local billing and entitlement proof

Add a deterministic local billing proof mode for the AI stack. The first paid
pilot cannot require live Stripe just to demonstrate entitlement decisions.

Definition of done:

- Demonstrates a local catalog item, customer/account mapping, entitlement
  check, quota or plan status, and usage record export.
- Shows how live Stripe test mode can replace the local fixture.
- Keeps real Stripe keys absent from default tracked config.

Current owner candidates: `bus-api-provider-billing`,
`bus-integration-billing`, `bus-integration-stripe`,
`bus-integration-usage`, BusDK superproject.

Current state: billing, Stripe, and usage modules are strong, but the compose
stack defaults are not yet packaged as a customer-facing entitlement proof.

### Live Codex preflight and proof mode

Make the live Codex path explicit and auditable.

Definition of done:

- Checks whether Codex credentials and opt-in environment are present without
  printing secrets.
- Runs one live model request only when explicitly enabled.
- Distinguishes missing credentials from platform failure.
- Records model alias, route, latency, and usage event evidence.

Current owner candidates: `bus-api-provider-llm`,
`bus-integration-codex`, BusDK superproject tests.

Current state: optional live Codex smoke exists, but it is not yet a polished
buyer-facing proof.

### Public product status page

Add a status and limitations page for the AI Product Stack Setup package.

Definition of done:

- States that the current commercial offer is a paid setup/pilot, not an
  unqualified production SaaS promise.
- Lists stable modules, demo-only defaults, credential requirements, Docker
  requirement for the local compose path, and known lifecycle gaps.
- Links to the proof harness and acceptance checklist.

Current owner candidates: `busdk.com`, BusDK docs.

Current state: `busdk.com` already marks the platform as pre-release and under
active development, but not at the package/feature level a buyer needs.

## P1 features

These are needed for a credible production-readiness pilot after the first
paid setup offer.

### Services lifecycle contract

Complete the first Services lifecycle contract and AI stack service profile.

Definition of done:

- `bus.services.*` contracts cover create, start, stop, restart, status,
  verify, logs/attach refs, lifecycle phases, validation errors, and redaction
  rules.
- `bus services` has list/show/status output and explicit lifecycle behavior.
- `bus-integration-services` can plan, start, stop, and inspect a stack profile
  with provider-owned runtime mechanics.
- PostgreSQL and container-backed services are represented through provider
  boundaries rather than hardcoded in Services.

Current owner candidates: `bus-services`, `bus-api-provider-services`,
`bus-integration-services`, `bus-integration-containers`,
`bus-integration-postgres`.

Current state: the relevant module plans still have these items open.

### Worker lifecycle productization

Stabilize the worker/task lifecycle enough that the AI setup package can
create, inspect, and explain workers without supervisor-only knowledge.

Definition of done:

- Workers provider is mounted through the real `bus-api` provider layer.
- Task-to-worker API boundary is documented and tested.
- Worker claim contract is stable.
- Worker-start ownership lives under worker integration.
- Atomic claim and capacity orchestration are implemented.
- Worker-owned service loop has status, diagnostics, and failure reporting.

Current owner candidates: `bus-api-provider-worker`,
`bus-integration-worker`, `bus-worker`, `bus-dev`.

Current state: task threading is usable and several worker pieces exist, but
the worker integration plan still lists lifecycle, claim, ownership, and
capacity work as open.

### Setup route catalog

Generate a machine-readable and human-readable route catalog for the stack.

Definition of done:

- Lists public and internal routes, owning module, required audience/scope,
  backend service, and proof command.
- Flags local/demo-only routes separately from production routes.
- Can be included in the diagnostic bundle.

Current owner candidates: BusDK superproject, `bus-api`, API provider modules,
docs.

Current state: Nginx routing and module docs exist, but no generated setup
catalog ties them together for a customer installation.

### Support entitlement surface

Tie commercial support status to the billing/catalog model.

Definition of done:

- A setup customer has a support entitlement record.
- Support entitlement can be checked without exposing billing secrets.
- Diagnostic bundle includes support package id/status, not private billing
  details.

Current owner candidates: `bus-api-provider-billing`,
`bus-integration-billing`, `busdk.com`, docs.

Current state: billing entitlements exist for product access. The setup/support
package itself is not yet modeled as a buyer-facing entitlement.

## P2 features

These are not required for the first weekend offer, but they become important
for scaling the business.

- Hosted UpCloud setup automation with repeatable secret handling and service
  status.
- Stripe live-mode onboarding and customer portal setup for the package.
- Admin portal for setup state, support entitlement, proof reports, usage, and
  billing status.
- Backup, migration, and rollback runbooks for customer-operated stacks.
- Self-hosted package channel with versioned artifacts, checksums, upgrade
  notes, and license terms.
- Observability dashboard for Events lag, worker state, LLM usage, billing
  worker state, and route health.

## Recommended first implementation slice

For the first commercial weekend slice, implement the following in order:

1. Add an AI Product Stack Setup docs/site page with deliverables,
   prerequisites, acceptance criteria, status, and limitations.
2. Turn the existing local AI platform smoke checks into a proof harness that
   writes a redacted report.
3. Add a diagnostic bundle command or script that includes the proof result.
4. Add deterministic local billing entitlement proof.
5. Add live Codex preflight and optional proof.

That path uses existing modules and produces evidence a buyer can verify. It
also avoids pretending that the Services and worker lifecycle modules are more
finished than their current plans show.

## Sources

- [bus-api-provider-llm](../modules/bus-api-provider-llm)
- [bus-api-provider-auth](../modules/bus-api-provider-auth)
- [bus-api-provider-billing](../modules/bus-api-provider-billing)
- [bus-integration-codex](../modules/bus-integration-codex)
- [bus-integration-usage](../modules/bus-integration-usage)
- [bus-integration-stripe](../modules/bus-integration-stripe)
- [bus-api-provider-events](../modules/bus-api-provider-events)
- [bus-portal-ai](../modules/bus-portal-ai)
- [Deployment and data control](../integration/deployment-and-data-control)
- [UpCloud and Stripe setup](../integration/upcloud-stripe-setup)
- [No-spend worker testing](../integration/no-spend-multi-remote-worker-test)

