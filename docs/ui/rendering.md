---
title: UI rendering model
description: Deterministic server rendering, Go/WASM mounting, templates, and lifecycle rules for BusDK UI apps.
---

## Renderer Targets

The same view model should be renderable through three targets.

Deterministic server rendering returns HTML strings for route handlers,
snapshots, and simple local portals. It is the lowest-friction target and the
baseline for testability. Server-rendered output must escape text, order
attributes deterministically, use stable class names, and avoid hidden browser
state.

Go/WASM mounting runs the same component functions in the browser and updates
the mounted DOM after state changes. It is the preferred target for rich local
apps that need action dispatch, polling, file drops, terminal input, assistant
workbench state, or live provider interaction.

The test renderer exposes deterministic artifacts for unit tests. Tests should
assert semantic output, stable action tokens, important attributes, rendered
states, and view-model projection. Snapshot tests are useful when they stay
focused on a small fixture state instead of freezing a whole product page for
every change.

## Node APIs

`Node` is a deterministic HTML fragment. `Props` stores attributes. Helpers
such as `P`, `Txt`, `Unsafe`, `El`, `Div`, `Section`, `Table`, `Tr`, `Td`, and
`Th` let components assemble escaped HTML with stable attributes. These helpers
are useful for low-level composition and for compatibility with string-based
components.

`VNode` is the preferred virtual DOM shape. It represents an element, escaped
text, or trusted raw fragment. It can carry a key for incremental updates and
renders to deterministic HTML. `VEl`, `VText`, and `VRaw` are the small building
blocks for `VNode` trees.

Component hooks such as state, refs, memo values, and child render slots belong
to a `RenderRuntime`. They let function components keep small local UI state
without moving product business state into the framework.

## Templates

Compiled templates are for low-allocation hot paths where the element structure
is stable and only a few text or attribute slots change. A template declares
static nodes, static attributes, dynamic text slots, and dynamic attribute
slots. `TemplateValues` holds reusable slot values across rerenders.

Use templates for repeated or frequently refreshed surfaces such as live rows,
terminal output frames, or compact status blocks. Use normal components when
the tree structure is easier to read or changes substantially by state.

## Mounting And Updates

A mounted Go/WASM app should own:

- the root element selector;
- the current product view model or app state;
- the render function;
- action handler registration;
- gateway clients and API URL resolution;
- lifecycle disposers for listeners, timers, and retained callbacks;
- error reporting and logging.

Mounting should preserve user state where the framework supports it. For
example, an AI panel may preserve active thread state, draft input, scroll
position, pending approvals, or close-guard state while rerendering the rest of
the app.

Every listener, timer, retained JavaScript callback, and browser subscription
needs an explicit disposer. The disposer chain must be safe to call more than
once. This keeps local apps testable and prevents stale callbacks when a module
is remounted.

## Runtime Errors

Runtime errors should flow through a shared error reporter. The reporter logs
the failure, presents a dismissible error host, and recovers panic payloads from
Go/WASM callbacks where possible. Product modules should not copy local error
banner markup or panic-recovery wrappers.

Errors returned by providers should be projected into product view models before
rendering. Generic provider-error components may show a title, summary, status,
request ID, retry affordance, and safe detail fields, but product modules decide
which fields are safe to expose.

## Browser API Boundaries

Browser-only behavior should be isolated behind small helpers. This includes
DOM selection, click binding, file drop access, multipart upload, beforeunload
close guards, resize tracking, local storage access, current location parsing,
client logging, and app-style browser opening.

When a helper needs JavaScript because the browser API requires it, expose a
Go-facing API and keep product modules in Go. Local hand-written JavaScript in a
product module is a sign that a reusable helper may be missing.

Existing modules may temporarily keep external JavaScript files or legacy
`window.<Module>` compatibility facades while migrating to Go/WASM helpers.
That compatibility must have an owner, a removal condition, CSP-safe external
loading, no secrets in DOM data, and a Go-facing replacement path.

Streaming readers need the same ownership discipline. Provider event streams
and SSE-like flows should expose explicit abort handles, disposer cleanup,
typed parsers, and pure parser tests for chunk boundaries, malformed payloads,
provider errors, and user-initiated abort.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./design-system">Design system</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./components">Building blocks</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../modules/bus-ui)
- [Testing](../testing/)
