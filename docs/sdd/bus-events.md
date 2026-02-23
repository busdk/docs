---
title: bus-events — event envelope and bus abstraction (SDD)
description: Software Design Document for bus-events shared envelope, publish/subscribe bus abstractions, and in-memory reference transport.
---

## bus-events — event envelope and bus abstraction

### Introduction and Overview

`bus-events` defines the shared event envelope and transport abstraction used by `bus-api` and provider modules. The module keeps event transport details isolated from application and provider business logic so API dispatch, provider processing, and future transport adapters can evolve independently.

The current reference transport is an in-memory publish/subscribe bus used for local process integration and deterministic tests. The abstraction boundary supports additional transport implementations later (for example queue-backed or broker-backed adapters) without changing event payload contracts.

### Requirements

FR-EVT-001 Shared envelope contract. The module MUST define a stable event envelope with `version`, `name`, `correlationId`, `source`, `timestamp`, `metadata`, `payload`, and optional structured `error`.

FR-EVT-002 Envelope validation. The module MUST validate envelopes before publish and reject invalid events with deterministic errors.

FR-EVT-003 Publish/subscribe abstraction. The module MUST expose transport interfaces for `Publish` and `Subscribe` so application services do not depend on a concrete transport implementation.

FR-EVT-004 Deterministic defaults. Missing required defaultable fields (`version`, `timestamp`) MUST be normalized deterministically.

NFR-EVT-001 Minimal dependency surface. The shared module MUST not depend on business modules.

NFR-EVT-002 Testability. In-memory transport behavior MUST be deterministic and test-covered.

### System Architecture

The module has three parts: event envelope model, bus interfaces, and in-memory transport implementation. Application services publish request and mutation events through the bus interface. Providers subscribe to relevant event names and publish response events with matching correlation identifiers.

### Component Design and Interfaces

Interface IF-EVT-001 Event envelope.

The Go envelope type includes:

- `version` string. Current version is `v1`.
- `name` string. Required event name.
- `correlationId` string. Request/reply correlation identifier.
- `source` string. Producer identifier.
- `timestamp` time. Publish timestamp in UTC.
- `metadata` object. Optional key/value metadata.
- `payload` raw JSON payload.
- `error` object. Optional `{ code, message }` error details.

Interface IF-EVT-002 Bus transport.

`Bus.Publish(ctx, event)` publishes one envelope and `Bus.Subscribe(ctx, names...)` creates a filtered subscription. A subscription exposes an event channel and a `Close()` method.

### Data Design

The module owns no persistent on-disk data. Event envelopes are transport messages; in-memory transport is non-durable and drops newest messages on subscriber backpressure.

### Assumptions and Dependencies

The module assumes consumers use correlation IDs for request/reply matching and treat unknown event names and extra fields as forward-compatible.

The module depends only on Go standard library packages.

### Glossary and Terminology

Event envelope: versioned message wrapper shared across producers and consumers.

Correlation ID: request/reply link key that binds one response event to one originating request event.

Transport adapter: concrete `Bus` implementation (for example in-memory or broker-backed).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-api-provider-session">bus-api-provider-session</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD Index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./modules">modules</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-events implementation](../../../bus-events/pkg/events/events.go)
- [bus-api route mapping and dispatch](../../../bus-api/internal/server/route_mapping.go)
