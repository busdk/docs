---
title: Portal UI modules
description: How BusDK portal feature modules use the shared UI framework and host contract.
---

## Module Contract

A portal feature module is a pluggable UI module mounted by `bus-portal`. It
has a stable ID, title, readiness state, default-enabled flag, navigation
items, and an HTTP handler. The host normalizes module IDs, deduplicates
modules, sorts metadata deterministically, and routes requests to the mounted
handler.

Feature modules should expose product routes beneath their mounted module path.
They should not assume they are served at the web root. All links, form actions,
API calls, asset references, and redirects should resolve through the host
context.

## Host Context

The host context should provide:

- canonical module base path;
- token-aware URL builders;
- shared CSS and asset URLs;
- API URL resolution;
- public runtime configuration;
- session and auth helper references;
- logger and client-log endpoints;
- security-header and connect-src declarations;
- frontend-auth and local token gate state.

The purpose is to remove hard-coded relative paths from feature modules. A
module should render the same route correctly when mounted locally, under a
token URL, or behind a portal distribution wrapper.

The same host context must be available to HTTP handlers, deterministic Go
render tests, and Go/WASM runtime setup. Tests should be able to assert the
same base path, asset URL, API resolver, runtime config, and security metadata
that the browser app receives.

## Module Descriptor

The portal module descriptor should be strict at the operator-facing boundary.
It should validate stable ID, title, readiness, default enablement, navigation
items, route/page specs, deterministic server-render entry points, WASM assets
and hooks, public runtime config keys, declared provider API origins, and asset
declarations.

Validation should fail loudly for invalid IDs, duplicate IDs, bad nav paths,
missing titles, unsupported readiness, nil handlers or pages, missing render or
runtime declarations, unsafe public config keys, and undeclared provider
origins. Defensive metadata normalization can still exist for internal
robustness, but it should not hide invalid operator configuration.

## Product Module Responsibilities

A product module owns its DTO adapters, view models, provider clients, copy,
permissions display, route handlers, and action registration. It decides which
provider fields are safe to display and which operations are available for a
state.

The module should render through shared `bus-ui` blocks. For example, an auth
module configures credential fields and scopes; `bus-ui` renders the form and
session request mechanics. A notes module configures note filters, note rows,
review actions, visibility, and safety labels; `bus-ui` renders filters, tables,
status tags, action bars, reader surfaces, and safe links.

Auth policy remains outside the portal renderer. Session validation, CSRF
enforcement, account or waitlist state, approval and billing state, token
eligibility, and authorization are provider/API responsibilities; portal
modules project safe state and dispatch actions.

## Registration And Distribution

The generic portal server should stay focused on hosting behavior. Product
module registration belongs to distribution or CLI wiring. This keeps the host
small and lets different deployments mount different module sets without
changing core server behavior.

Module readiness state controls normal enablement. Stable modules may be
enabled for normal opt-in use. Experimental modules require explicit opt-in.
Default-enabled modules are included when the user does not request a specific
module set.

## Security

The portal host applies the outer token gate and security headers. Provider APIs
remain authoritative for data access and business permissions. Browser code can
hide unavailable actions for usability, but the API must still reject
unauthorized requests.

Public runtime config must not contain secrets. Client logs must not include
tokens, passwords, provider credentials, private customer data, or raw sensitive
payloads. If a module needs to show diagnostic detail, it should project the
provider error into safe public fields first.

## Local Apps And Portal Apps

Some BusDK UIs run as local app-style servers with Go/WASM clients. Others run
as portal modules. They should still use the same building blocks. A local app
may own its own shell, but form controls, tables, assistant panels, terminal
panes, evidence links, action routing, and runtime helpers should be shared.

This makes local server plus WASM apps and portal-mounted apps easier to test
with the same component fixtures.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./declarative-documents">Declarative UI documents</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./testing">Testing UI apps</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-portal module reference](../modules/bus-portal)
- [bus-portal-auth module reference](../modules/bus-portal-auth)
- [bus-portal-ai module reference](../modules/bus-portal-ai)
- [bus-portal-accounting module reference](../modules/bus-portal-accounting)
- [bus-portal-notes module reference](../modules/bus-portal-notes)
