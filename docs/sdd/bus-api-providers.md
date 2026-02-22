---
title: "bus-api providers — architecture and operation catalog (SDD)"
description: "Provider architecture for bus-api as an API application service and dispatcher, with module purposes and operation-level catalog."
---

## Overview

This page defines the provider model for `bus-api`. `bus-api` is an API application service and dispatcher: it owns transport, routing, request and response contracts, provider registration, lifecycle management, and deterministic error envelopes. Provider modules own domain behavior.

The provider split keeps command and service boundaries explicit. User-facing CLIs such as `bus auth`, `bus plan`, and `bus update` remain thin clients, while private backend behavior is implemented by `bus-api-provider-*` modules loaded by explicit API service configuration.

### Provider inventory

| Provider module | Purpose | Operation count |
| --- | --- | --- |
| `bus-api-provider-session` | Session lifecycle and token introspection trust anchor for downstream providers. | 4 |
| `bus-api-provider-identity` | Identity profile, linked-identity management, and identity authentication lifecycle for downstream providers. | 5 |
| `bus-api-provider-auth-email` | Email-channel authentication and verification flows. | 2 |
| `bus-api-provider-auth-sms` | SMS-channel authentication and phone verification orchestration. | 2 |
| `bus-api-provider-plan` | Plan catalog and purchase policy evaluation sourced from local configuration. | 3 |
| `bus-api-provider-billing` | Canonical billing-domain event handling, subscription/payment state projection, and billing decision reads. | 8 |
| `bus-api-provider-stripe` | Stripe adapter for hosted checkout/portal and Stripe-to-billing event mapping. | 6 |
| `bus-api-provider-twilio` | Twilio integration adapter for phone verification challenge delivery and callback normalization. | 8 |
| `bus-api-provider-entitlement` | Central decision engine for resource access rights and decision traceability. | 9 |
| `bus-api-provider-artifacts` | Secure binary and package release exposure plus entitlement-gated download grants. | 11 |
| `bus-api-provider-books` | Accounting and bookkeeping domain provider extracted from existing `bus-api` implementations for books-facing workflows and models. | 4 |

Total operation count across the initial provider set is 62.

### Operation catalog: `bus-api-provider-session`

`bus-api-provider-session` owns session lifecycle and introspection trust behavior. A session is independent from authenticated-user state.

Detailed session contract is defined in [bus-api-provider-session](./bus-api-provider-session).

| Operation | Description | Design state |
| --- | --- | --- |
| `session.create` | Creates a session context used by verification flows and constrained free-download flows. | Approved |
| `session.refresh` | Rotates or renews an active session token set before expiry. | Approved |
| `session.revoke` | Invalidates an active session immediately. | Approved |
| `session.introspect` | Validates token or session material and returns normalized auth context. | Approved |
 
### Operation catalog: `bus-api-provider-identity`

`bus-api-provider-identity` owns identity-profile, linked-identity lifecycle, and identity authentication behavior.

| Operation | Description | Design state |
| --- | --- | --- |
| `identity.register` | Creates a new identity record independent of authentication channel. | Draft |
| `identity.authenticate` | Authenticates an identity and attaches authenticated-user context to an existing session after required verification policy succeeds. | Draft |
| `identity.profile.get` | Returns identity profile metadata for the caller or requested identity. | Draft |
| `identity.profile.update` | Updates allowed identity profile fields with deterministic validation. | Draft |
| `identity.external_identity.link` | Links a verified external identity record to an existing identity. | Draft |

### Operation catalog: `bus-api-provider-auth-email`

`bus-api-provider-auth-email` owns email-channel authentication and email ownership verification behavior. The authentication model is passwordless; password-based login is out of scope.

| Operation | Description | Design state |
| --- | --- | --- |
| `auth.email.verify_start` | Starts an email ownership challenge for verification. | Draft |
| `auth.email.verify_complete` | Completes the email verification challenge and marks email as verified. | Draft |

### Operation catalog: `bus-api-provider-auth-sms`

`bus-api-provider-auth-sms` owns SMS-channel authentication and phone ownership verification orchestration.

| Operation | Description | Design state |
| --- | --- | --- |
| `auth.sms.verify_start` | Starts a phone ownership challenge for verification by SMS. | Draft |
| `auth.sms.verify_complete` | Completes the phone verification challenge and marks phone as verified. | Draft |

### Operation catalog: `bus-api-provider-plan`

`bus-api-provider-plan` owns plan catalog and policy evaluation behavior sourced from local configuration. Runtime API operations read and evaluate policy only; they do not mutate plan configuration.

| Operation | Description | Design state |
| --- | --- | --- |
| `plan.catalog.list` | Lists plans that are visible for self-service purchase. | Draft |
| `plan.catalog.get` | Returns a single plan definition and policy configuration. | Draft |
| `plan.policy.evaluate_purchase` | Evaluates whether a subject is currently eligible to start purchase. | Draft |

### Operation catalog: `bus-api-provider-billing`

`bus-api-provider-billing` owns canonical billing-domain behavior. It consumes explicit `billing.*` domain events and projects subscription, invoice, and payment state for downstream policy and entitlement decisions.

| Operation | Description | Design state |
| --- | --- | --- |
| `billing.event.apply` | Applies one canonical billing domain event (for example `billing.subscription.started`, `billing.payment.failed`) to billing state projection. | Draft |
| `billing.subscription.get` | Returns current subscription projection for one subscription identifier. | Draft |
| `billing.subscription.list_identity` | Lists subscription projections for one identity. | Draft |
| `billing.subscription.preview_change` | Returns billing impact preview for a planned subscription change. | Draft |
| `billing.subscription.request_cancel` | Requests cancellation behavior for a subscription lifecycle change. | Draft |
| `billing.invoice.get` | Returns invoice projection details for one invoice identifier. | Draft |
| `billing.payment.get_status` | Returns payment status projection for one payment or invoice context. | Draft |
| `billing.reconcile.identity` | Reconciles billing state for one identity from provider snapshots and canonical events. | Draft |

### Operation catalog: `bus-api-provider-stripe`

`bus-api-provider-stripe` is a provider adapter for Stripe-specific transport and API behaviors. It verifies Stripe callbacks and maps Stripe event payloads into explicit `billing.*` domain events for `bus-api-provider-billing`.

| Operation | Description | Design state |
| --- | --- | --- |
| `stripe.checkout.create_session` | Creates a Stripe-hosted checkout session for a plan purchase. | Draft |
| `stripe.portal.create_session` | Creates a Stripe-hosted customer portal session. | Draft |
| `stripe.customer.ensure` | Creates or retrieves the Stripe customer mapped to a Bus subject. | Draft |
| `stripe.webhook.verify_signature` | Verifies Stripe webhook signature and accepted timestamp window. | Draft |
| `stripe.webhook.to_billing_event` | Maps a Stripe webhook payload into an explicit canonical `billing.*` domain event. | Draft |
| `stripe.reconcile.account_snapshot` | Retrieves Stripe account snapshot data used by billing reconciliation flows. | Draft |

### Operation catalog: `bus-api-provider-twilio`

`bus-api-provider-twilio` owns phone verification delivery and callback integration through Twilio. It handles verification challenge lifecycle mapping and Twilio callback normalization and reconciliation.

| Operation | Description | Design state |
| --- | --- | --- |
| `twilio.verify.challenge_start` | Starts a Twilio-backed verification challenge for a phone number. | Draft |
| `twilio.verify.challenge_check` | Checks or confirms a submitted verification code for a challenge. | Draft |
| `twilio.verify.challenge_cancel` | Cancels an active verification challenge. | Draft |
| `twilio.verify.webhook.verify_signature` | Verifies Twilio callback signature and request validity window. | Draft |
| `twilio.verify.webhook.normalize_event` | Normalizes Twilio callback payloads into canonical internal events. | Draft |
| `twilio.verify.webhook.apply_event` | Applies normalized verification callback effects to identity projection. | Draft |
| `twilio.verify.lookup_phone` | Resolves phone metadata used for policy checks and normalization. | Draft |
| `twilio.verify.reconcile_challenge` | Reconciles Twilio challenge state with internal verification projection. | Draft |

### Operation catalog: `bus-api-provider-entitlement`

`bus-api-provider-entitlement` owns access-right decisions for protected resources and features. It is the policy decision point for allow or deny outcomes and reason-trace auditability.

| Operation | Description | Design state |
| --- | --- | --- |
| `entitlement.check` | Evaluates whether a subject may access one resource or action at request time. | Draft |
| `entitlement.check_batch` | Evaluates multiple access decisions in a single deterministic request. | Draft |
| `entitlement.explain` | Returns a reasoned trace for one entitlement decision. | Draft |
| `entitlement.list_subject` | Lists effective entitlements for a subject. | Draft |
| `entitlement.grant_manual` | Applies a staff-issued manual grant with scope and optional expiry. | Draft |
| `entitlement.revoke_manual` | Revokes or disables a manual grant. | Draft |
| `entitlement.apply_trial_state` | Projects trial lifecycle state changes into effective entitlements. | Draft |
| `entitlement.apply_subscription_state` | Projects subscription and billing state into effective entitlements. | Draft |
| `entitlement.audit.query` | Queries entitlement and grant audit records for deterministic traceability. | Draft |

### Operation catalog: `bus-api-provider-artifacts`

`bus-api-provider-artifacts` owns secure artifact and package delivery controls after entitlement decisions. It manages download grant issuance, grant verification and consumption, release-channel resolution, and integrity metadata.

| Operation | Description | Design state |
| --- | --- | --- |
| `artifact.catalog.list` | Lists artifacts and releases visible to the caller and channel. | Draft |
| `artifact.catalog.get` | Returns metadata for one artifact or release record. | Draft |
| `artifact.release.publish` | Publishes a new artifact release into configured channels. | Draft |
| `artifact.release.deprecate` | Marks an artifact or release as deprecated. | Draft |
| `artifact.access.request_download` | Requests entitlement-gated access to a specific artifact download. | Draft |
| `artifact.access.issue_grant` | Issues a short-lived signed download grant after access approval. | Draft |
| `artifact.access.verify_grant` | Verifies grant signature, scope, and expiry before fulfillment. | Draft |
| `artifact.access.consume_grant` | Consumes a one-time grant and enforces replay policy rules. | Draft |
| `artifact.channel.resolve` | Resolves caller eligibility to release channel targets. | Draft |
| `artifact.integrity.get_hashes` | Returns checksums and signature metadata for integrity verification. | Draft |
| `artifact.download.audit` | Records and queries download audit events for traceability. | Draft |

### Operation catalog: `bus-api-provider-books`

`bus-api-provider-books` owns accounting and bookkeeping domain behavior extracted from existing `bus-api` implementations. It keeps books-specific request and response contracts in a dedicated provider while preserving compatibility with existing `pkg/booksapi` surfaces.

| Operation | Description | Design state |
| --- | --- | --- |
| `books.module.get_info` | Returns module capabilities and route metadata required by books-facing clients. | Draft |
| `books.resource.list` | Lists books-visible resources and projections used by books workflows. | Draft |
| `books.resource.get` | Returns one books-visible resource projection with contract-stable shape. | Draft |
| `books.workflow.run` | Runs a books-scoped workflow operation through provider-backed business logic. | Draft |

### Document control

Title: bus-api provider architecture and operation catalog (SDD)  
Project: BusDK  
Document ID: BUSDK-API-PROVIDERS  
Version: 2026-02-22  
Status: Draft  
Last updated: 2026-02-22  
Owner: BusDK development team

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api">bus-api</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-agent">bus-agent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-api module SDD](./bus-api)
- [bus-api-provider-session SDD](./bus-api-provider-session)
- [bus-api module CLI reference](../modules/bus-api)
- [Stripe documentation](https://docs.stripe.com/)
- [Twilio Verify documentation](https://www.twilio.com/docs/verify)
