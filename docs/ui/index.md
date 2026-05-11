---
title: BusDK UI framework
description: Public reference for the reusable BusDK UI framework used by portal and local browser applications.
---

## Purpose

The BusDK UI framework is the shared contract for building browser interfaces
inside the Bus ecosystem. It gives product modules a small set of deterministic
Go components, browser runtime hooks, and test helpers so that a module can
focus on its business view model instead of rebuilding page shells, forms,
tables, navigation, assistant panels, terminal panes, file evidence surfaces,
and browser wiring.

The framework is intentionally Go-first. The same application view should be
composable from Go when rendered on the server, mounted in a Go/WASM browser
runtime, or inspected in unit tests. JavaScript remains an interoperability
detail for browser APIs and legacy hosts, not the primary application language.

## Framework Pipeline

BusDK UI applications use a narrow data flow:

`business DTO -> product view model -> bus-ui nodes/components -> renderer target`

Business DTOs are provider or module API data. Product view models belong to
the product module and describe the exact screen state, copy, permissions,
actions, and errors for that module. `bus-ui` owns the generic components used
to render those view models. Renderer targets turn the component tree into
server HTML, a Go/WASM mounted app, or a deterministic unit-test artifact.

This boundary keeps reusable UI code small. `bus-ui` should not know what an
accounting voucher, auth session, note review, or AI provider policy means.
Those concepts stay in the owning product module. `bus-ui` should know how to
render a form field, status tag, data table, action bar, terminal session, safe
artifact link, error panel, or assistant message once the product module has
already projected domain data into a generic shape.

## Minimal Model

The framework should stay small enough to explain in one pass:

- `Node` is the deterministic render tree.
- `Component` is a reusable function from props, slots, and view-model data to
  nodes.
- `Shell` is a component that owns page-level slots such as navigation, body,
  assistant, and footer.
- `Collection` is a component for repeated data: tables, lists, timelines, and
  galleries.
- `State` is visible status: empty, loading, result, warning, error, and busy
  states.
- `Action` is user-triggered behavior: submit, click, approve, upload, send,
  stop, archive, or start a provider job.
- `Resource` is external data or media: API endpoint, artifact link, evidence
  preview, provider request, or upload target.
- `Effect` is lifecycle behavior: polling, event streams, close guards, drops,
  resize, logging, and cleanup.

Specific helpers such as `CredentialLoginCard`, `TerminalSessionPanel`,
`AIPanel`, `SidebarShell`, `TextTable`, or provider resource adapters are
variants of those concepts, not separate architectural layers. When a proposed
feature cannot fit this model, it should be questioned before a new framework
concept is added.

## Modules

`bus-ui` owns reusable building blocks. Its public surface includes deterministic
HTML helpers, virtual DOM nodes, component hooks, form and content primitives,
shared CSS tokens, action/resource/effect helpers, AI workbench components,
terminal session components, evidence helpers, and test fakes.

`bus-portal` owns the host. It mounts feature modules, serves the shared CSS and
static assets, applies security headers, exposes module metadata, passes runtime
context to modules, and routes token-gated requests under canonical module
paths.

`bus-portal-*` modules own product views. Examples include auth, AI,
accounting, and notes. They convert provider DTOs into product view models,
configure generic components, register module routes, and test business
projection logic without duplicating shared UI infrastructure.

Provider modules such as `bus-api-provider-*` and integration modules own data
and behavior behind APIs. A portal module may call them, but the UI framework
does not move provider authorization or business policy into the browser.

## Documentation Map

- [Architecture](./architecture/) describes the package boundaries, data flow,
  host contract, and ownership rules.
- [Design system](./architecture/design-system) defines the visual and interaction language.
- [Rendering model](./architecture/rendering) explains deterministic HTML, Go/WASM mounting,
  templates, lifecycle ownership, and renderer tests.
- [Building block reference](./reference/components) lists the generic components and
  runtime helpers UI apps should compose.
- [Component catalog](./reference/component-catalog) gives the complete reusable
  component vocabulary with inputs, outputs, and test expectations.
- [Component reference](./reference/component-reference) gives practical usage guidance
  for every catalog component and runtime block.
- [Declarative UI documents](./reference/declarative-documents) defines the JSON/YAML
  document format that lets `bus-ui sample.yml` render reviewable UI samples.
- [Examples](./examples/) shows complete YAML documents for notes, auth,
  assistant, terminal, and evidence workflows.
- [Portal modules](./guides/portal-modules) explains how feature modules plug into the
  portal host.
- [Testing UI apps](./guides/testing) describes the unit-first testing model and the
  thin e2e layer.
- [Reference checklist](./reference/) gives a compact implementation checklist
  for new UI modules.

## Core Rules

A BusDK UI module should keep business decisions in its own view-model layer,
then render through generic `bus-ui` components. It should not hand-assemble a
full page with raw strings when a shared shell, form, table, status, action, or
runtime helper exists.

Every reusable component must be deterministic. Escaped text, stable attribute
ordering, stable action tokens, and predictable class names are part of the
contract because they let unit tests verify UI behavior without broad browser
automation.

Browser behavior should be Go/WASM-first. The framework may provide thin
JavaScript shims where the browser requires them, but product modules should
not carry local JavaScript for ordinary form submission, action dispatch,
polling, session requests, drop handling, close guards, resize behavior, or
client logging when a shared Go runtime helper can do the job.

UI samples and fixtures should be representable as declarative JSON or YAML
documents. A declarative document uses the same component catalog as Go code,
so a command such as `bus-ui sample.yml` can render a deterministic screen for
review, testing, documentation, or a small tool. This gives AI agents a simple
artifact to propose and modify while keeping runtime behavior attached to typed
Go handlers.

E2e tests still exist, but they should prove that the host, mounting path, auth
gate, assets, and the real browser bridge work. Product correctness should come
mostly from focused unit tests over view models, generic component renders,
action handlers, and fake provider clients.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../architecture/">System architecture</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">Documentation index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./architecture/">Architecture</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../modules/bus-ui)
- [bus-portal module reference](../modules/bus-portal)
- [System architecture](../architecture/)
