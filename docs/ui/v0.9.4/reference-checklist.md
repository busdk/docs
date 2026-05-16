---
title: UI framework reference checklist
description: Compact checklist for building BusDK UI modules with the shared UI framework.
---

## New UI Module Checklist

The compact design decisions are:
[layer ownership](../v0.1.1/foundation),
[declarative authoring](../v0.1.2/source-tools),
[callback props](../v0.1.6/), and
[safety and rendering](../v0.1.1/render-tree-contract).

Start with the product boundary. Provider DTOs, API route contracts,
authorization checks, permission policy, and raw provider errors stay in the
provider/API modules that own them. The UI product module consumes those stable
contracts and owns only the projected view model, product copy, safe-link
presentation rules, and the exact user workflows the screen must support.

Define view models before rendering. Each view model should describe visible
data, controls, events, errors, loading state, empty state, selected state,
links, and permissions without requiring the renderer to call providers or
infer business rules.

Choose the host shape. Default to a portal module when the UI belongs to a
pluggable Bus feature, needs shared auth/session behavior, or should run under
`bus-portal`. Choose a local app when the workflow is a standalone developer
tool, needs a local server plus Go WebAssembly client, or is not meant to be mounted
beside other portal features. A portal module implements the portal module
contract and receives paths, assets, and runtime config from `bus-portal`. A
local app may use an app shell directly, but it should still consume shared
components and runtime helpers.

Compose generic components. Use the [Core](../v0.1.1/) foundation and common
`bus-ui` libraries for icons, buttons, links, menus, tabs, panels, cards,
layout helpers, shells, forms, fields, input controls, tables, lists, and
status surfaces before adding product-local markup. Use higher-level
assistant, terminal, evidence, file, and portal libraries only when the product
needs those concerns.

Capture important screens as declarative template sets when practical. Use the
versioned [Source-tool integration](../v0.1.3/source-tool-integration) checks available for the current patch,
starting with [v0.1.2 source formatting and linting](../v0.1.2/) and adding
[v0.1.3 compile checks](../v0.1.3/) once the compiler
exists.

Wire interaction through stable events once the versioned event contract
exists. Callback prop names are part of the public UI contract, so rename them only
with a deliberate contract change across templates, fixtures, tests, and
browser behavior.

Test in layers. Add view-model tests, renderer tests, runtime/event tests, and
only then thin e2e tests for host mounting and representative browser behavior.

## Component Selection

Use [common shell components](../v0.2.6/) when the module needs a durable local
page frame.

Use [layout components](../v0.2.5/) when the module needs sidebar
navigation or stable split panes.

Use [form components](../v0.3.1/forms) when the module asks for user input,
filters data, submits credentials, configures settings, or collects workflow
decisions.

Use [table components](../v0.3.5/tables), [list components](../v0.3.6/lists),
or [timeline components](../v0.3.7/timelines) when the module shows rows,
records, notes, files, ledger entries, usage events, plans, invoices, or other
repeatable data.

Use [status surfaces](../v0.3.8/status-surfaces) for empty, loading, working,
success, warning, blocked, and error states.

Use [runtime config](../v0.4.2/runtime-config), [API URLs](../v0.4.2/api-urls),
[session](../v0.4.3/session), [credentials](../v0.4.4/credentials), and
[provider errors](../v0.4.5/provider-errors) for host and provider-adjacent
UI concerns.

Use [assistant components](../v0.5.1/assistant-workbench) when the UI
supervises AI threads, model selection, turns, approvals, review-before-apply
state, attachments, active work, or an assistant side pane.

Use [terminal components](../v0.6.1/terminal-sessions) when the UI streams
command output, waits on command approval, accepts stdin, or shows command exit
state.

Use [evidence](../v0.7.1/evidence), [file drops](../v0.8.1/file-drops), and
[image gallery](../v0.8.2/image-gallery) pages when the UI opens, previews,
downloads, accepts, or lists attached files, artifacts, documents, PDFs, photos,
or other media.

Use [portal modules](../v0.9.3/portal-modules) when the UI must be mounted by a
portal host with module descriptors, host context, shared assets, and route
resolution.

## What Belongs Where

`bus-gx` should get a new primitive when the behavior belongs to the low-level
template framework: parsing, formatting, linting, render trees, safe elements,
component composition, callback props, lifecycle, diagnostics, or core test
fakes. `bus-ui` should get a new library or component when two or more modules
need the same generic control, composed surface, runtime helper, or
higher-level UI concern. Either addition must be small enough to unit-test
without a product module.

A product module should keep a local component when the behavior is tied to
domain concepts, provider permissions, product copy, or workflow state that
other modules should not inherit.

`bus-portal` should get a host feature when modules need consistent mounting,
asset delivery, security headers, path resolution, runtime config, or metadata.
It should not absorb product rendering or provider policy.

## UI Work Checklist

UI work is done when the product behavior is represented in view models, generic
components render the states deterministically, browser interactions are wired
through typed callbacks, automated tests cover projection, rendering, and
callback behavior, and thin e2e coverage proves the mounted host path.

Documentation should update the module README or public docs when the user
visible contract changes. CLI help or metadata should update when a UI command,
module registration option, or runtime flag changes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Core](../v0.1.1/)
- [Bus UI module baseline](../v0.2.0/)
- [Source-tool integration](../v0.1.3/source-tool-integration)
- [bus-ui module reference](../../modules/bus-ui)
- [bus-portal module reference](../../modules/bus-portal)
