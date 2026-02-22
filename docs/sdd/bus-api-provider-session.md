---
title: "bus-api-provider-session — session provider SDD"
description: "Software Design Document for bus-api-provider-session: session schema, lifecycle states, identity binding model, TTL and rotation policy, and deterministic session operations."
---

## bus-api-provider-session

### Introduction and Overview

`bus-api-provider-session` owns session lifecycle and token introspection behavior for the provider-based `bus-api` architecture. A session is transport and policy context, not the same thing as an authenticated identity. Identity authentication may attach identity context to an existing session later.

The provider exists to make session behavior explicit, deterministic, and reusable across identity, billing, entitlement, and artifact providers.

### Requirements

FR-SES-001 Session create. The provider MUST expose `session.create` to create a new active session with deterministic defaults and server-generated identifiers.

FR-SES-002 Session refresh. The provider MUST expose `session.refresh` to rotate session token material while preserving session identity and policy context.

FR-SES-003 Session revoke. The provider MUST expose `session.revoke` to invalidate a session immediately.

FR-SES-004 Session introspection. The provider MUST expose `session.introspect` to return deterministic session validity and context projection.

FR-SES-005 Session lifecycle state. Each session MUST have lifecycle state values `active`, `revoked`, or `expired`.

FR-SES-006 Identity binding model. Session lifecycle state MUST remain separate from identity authentication. Identity binding MUST be represented separately (for example `identity_binding_state` with values `none` and `bound`).

FR-SES-007 Pre-auth usage scope. Sessions without bound identity MUST be allowed only for explicitly approved constrained flows (for example free binary download flow scopes).

FR-SES-008 Deterministic diagnostics. Failed introspection and mutation operations MUST return stable reason codes (`not_found`, `expired`, `revoked`, `invalid_token`, `forbidden_scope`, `conflict`).

NFR-SES-001 Token secrecy. Session tokens MUST be high-entropy opaque values and MUST NOT be derivable from session metadata.

NFR-SES-002 Storage safety. Session token secrets MUST be stored hashed at rest.

NFR-SES-003 Idempotency. `session.revoke` MUST be idempotent and deterministic when repeated for the same session identifier.

NFR-SES-004 Concurrency safety. Concurrent refresh and revoke calls MUST converge deterministically without split-brain session validity.

### System Architecture

The provider has four components. The token issuer creates opaque token material and session identifiers. The session store persists session records and lifecycle metadata. The policy gate validates allowed scopes for pre-auth sessions. The introspection adapter resolves request token material into normalized session context and deterministic status.

Identity and verification providers are external to this module. They may bind identity context to an existing session through identity-domain operations, but they do not own session lifecycle transitions.

### Component Design and Interfaces

Provider operations:

- `session.create`
- `session.refresh`
- `session.revoke`
- `session.introspect`

Session record contract:

- `session_id`: stable opaque identifier
- `lifecycle_state`: `active | revoked | expired`
- `identity_binding_state`: `none | bound`
- `identity_id`: optional; present when `identity_binding_state=bound`
- `scopes`: deterministic sorted list of scope strings
- `created_at`: RFC3339 timestamp
- `expires_at`: RFC3339 timestamp
- `last_seen_at`: RFC3339 timestamp
- `revoked_at`: optional RFC3339 timestamp
- `source`: stable source label (`cli`, `api`, `internal`)

Lifecycle transitions:

| From | Trigger | To | Notes |
| --- | --- | --- | --- |
| `active` | time >= `expires_at` | `expired` | Derived or materialized deterministically. |
| `active` | `session.revoke` | `revoked` | Immediate and idempotent. |
| `revoked` | `session.revoke` | `revoked` | No-op idempotent repeat. |
| `expired` | `session.refresh` | denied | Must return `expired` reason code. |

Identity binding transitions:

| From | Trigger | To | Notes |
| --- | --- | --- | --- |
| `none` | identity provider authenticate success | `bound` | Session remains same `session_id`. |
| `bound` | identity switch not allowed | denied | Must return `conflict` unless explicit policy exists. |

### Data Design

Session persistence may use any implementation backend, but behavior must match this contract. Token lookup keys must never contain raw token material in logs. Hash algorithm and parameters must be configuration-controlled and deterministic in verification behavior.

Default policy values:

- default TTL: 24h
- refresh window: allow refresh only when remaining TTL <= 12h
- maximum rolling lifetime: 30d
- pre-auth scope default: empty

These defaults are module configuration values and may be overridden locally, but outputs for the same configured values and inputs must remain deterministic.

### Assumptions and Dependencies

Identity binding is provided by `bus-api-provider-identity` operations (for example `identity.authenticate`). Entitlement and artifact providers consume session introspection output but do not mutate session lifecycle state directly.

Clock source for expiry checks is a deterministic provider clock abstraction so tests and replay behavior remain stable.

### Glossary and Terminology

Session: provider-managed execution and policy context keyed by opaque token material.

Lifecycle state: validity state of the session record (`active`, `revoked`, `expired`).

Identity binding state: separate flag indicating whether authenticated identity context is attached (`none`, `bound`).

Pre-auth session: a session with `identity_binding_state=none` used only for approved constrained flows.

### Document control

Title: bus-api-provider-session SDD  
Project: BusDK  
Document ID: BUSDK-API-SES  
Version: 2026-02-22  
Status: Draft  
Last updated: 2026-02-22  
Owner: BusDK development team

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api-providers">bus-api providers</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-agent">bus-agent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-api providers — architecture and operation catalog](./bus-api-providers)
- [bus-api module SDD](./bus-api)
- [BusDK Software Design Document (SDD)](https://docs.busdk.com/sdd)
