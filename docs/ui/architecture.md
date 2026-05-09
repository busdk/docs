---
title: UI framework architecture
description: Architecture and ownership boundaries for the BusDK UI framework.
---

## Layer Model

The framework has four layers, each with a narrow responsibility.

The provider/API layer returns data and enforces business authority. It owns
authorization, persistence, validation, and domain operations. UI code may show
errors returned by this layer, but it must not duplicate provider authority in
browser-only checks.

The product view-model layer belongs to the feature module. It turns provider
DTOs into screen-ready values: labels, empty states, disabled actions, selected
rows, safe links, permissions, status summaries, and localized copy. This layer
is where auth, notes, accounting, AI, or other product-specific meaning lives.

The `bus-ui` component layer owns reusable rendering and runtime blocks. A
component receives generic props or a generic view model and emits a
deterministic UI tree. The component should not fetch product data, infer domain
policy, or name provider-specific routes unless those routes are passed as
configuration.

The renderer layer turns the tree into HTML, a mounted Go/WASM app, or a test
artifact. The target changes, but the view-model and component contract should
remain the same.

The architecture should resist parallel abstractions. A command submit, file
upload, container run, approval decision, and AI send button are all `Action`
variants. A JSON endpoint, evidence link, preview URL, and upload target are
all `Resource` variants. Polling, event streams, drop handling, resize
listeners, close guards, and client logging are all `Effect` variants. Concrete
helpers may make common cases convenient, but they should compose through this
small model instead of creating separate runtime families. Compatibility
helpers can wrap older APIs as adapters while modules migrate toward the shared
contract.

## Ownership Boundaries

`bus-ui` owns general UI language: nodes, attributes, form controls, buttons,
tables, status tags, cards, panels, navigation primitives, page shells, action
dispatch, resource helpers, close guards, error hosts, logging, drop handling,
polling, assistant panels, terminal panes, evidence links, and test fakes.

`bus-portal` owns the host environment: module discovery and mounting, route
prefixing, token-aware URLs, public runtime config, CSS and asset delivery,
security headers, module metadata, frontend-auth gates, and the common portal
chrome.

Feature modules own product semantics: API routes, provider clients, DTO to
view-model projection, permission display, product copy, locale decisions,
domain-specific Markdown or document safety, workflow state, and any component
composition that is not reusable outside that product.

## Product Module Shape

A portal feature module should be structured around three small seams:

1. DTO adapters read provider responses and normalize error payloads.
2. View-model builders derive UI state from DTOs, permissions, request context,
   and route/query input.
3. Renderers compose `bus-ui` blocks from those view models and expose route
   handlers or Go/WASM mount functions.

This shape lets agents work effectively. One task can improve projection tests,
another can replace local markup with generic components, and another can
adjust host routing or runtime context without mixing unrelated concerns.

## Render Tree Contract

`bus-ui` supports simple escaped HTML fragments through `Node`, `Props`, and
helpers such as `El`, `Txt`, `Unsafe`, `Div`, `Section`, `Table`, `Tr`, `Td`,
and `Th`. These helpers are useful for low-level deterministic HTML and for
compatibility with existing string-based components.

The preferred app-level contract is `VNode`. A `VNode` is an element, escaped
text, or trusted raw fragment with deterministic HTML output and optional keys
for incremental browser updates. Components should move toward `VNode`-first
props because the same tree can serve server rendering, mounted Go/WASM
updates, and unit-test inspection.

Trusted raw HTML must be narrow. It is acceptable for framework-owned static
fragments, sanitized Markdown, or compatibility boundaries. Product modules
should pass escaped text and typed props wherever possible.

## Runtime Contract

Browser runtime helpers are small, composable pieces. Action dispatch maps a
stable action token to a typed handler. Resources resolve provider, artifact,
and upload targets and decode typed results. Effects own browser lifecycle
behavior such as polling, event streams, close guards, drop handlers, resize
listeners, and client logging through explicit disposer callbacks.

Every runtime helper must expose enough seams for unit tests. A module should
be able to test action behavior with fake resources and fake view state,
without opening a browser for every case.

## Portal Host Contract

A portal module implements the host module interface: stable ID, title,
readiness state, default-enabled flag, navigation items, and an HTTP handler.
The host normalizes and sorts modules, exposes deterministic module metadata,
serves shared CSS, and dispatches mounted routes under `/modules/<id>/...`
inside the token-gated portal URL.

The host context should provide canonical base paths, asset URLs, API URL
resolution, public runtime config, session/auth helpers, logging, and declared
connect-src requirements. Feature modules should not hard-code relative asset
paths, standalone `/modules/<id>/` paths, or duplicated runtime config scripts
when the host can provide them.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./">UI framework</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./design-system">Design system</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../modules/bus-ui)
- [bus-portal module reference](../modules/bus-portal)
- [bus-portal-auth module reference](../modules/bus-portal-auth)
- [bus-portal-ai module reference](../modules/bus-portal-ai)
- [bus-portal-accounting module reference](../modules/bus-portal-accounting)
- [bus-portal-notes module reference](../modules/bus-portal-notes)
