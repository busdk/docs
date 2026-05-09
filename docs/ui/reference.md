---
title: UI framework reference checklist
description: Compact checklist for building BusDK UI modules with the shared UI framework.
---

## New UI Module Checklist

Start with the product boundary. Identify provider DTOs, API routes,
permissions, product copy, safe-link rules, and the exact user workflows the UI
must support. Keep those in the product module.

Define view models before rendering. Each view model should describe visible
data, controls, actions, errors, loading state, empty state, selected state,
links, and permissions without requiring the renderer to call providers or
infer business rules.

Choose the host shape. A portal module implements the portal module contract
and receives paths, assets, and runtime config from `bus-portal`. A local app
may use an app shell directly, but it should still consume shared components
and runtime helpers.

Compose generic components. Use shared shells, navigation, forms, fields,
buttons, action bars, data tables, status tags, panels, error surfaces, loading
surfaces, evidence links, assistant panes, terminal panes, and drop zones before
adding product-local markup.

Capture important screens as declarative JSON/YAML fixtures when practical.
Those files should use the same component catalog as Go code and should render
through `bus-ui sample.yml` or the explicit render command.

Wire actions through stable tokens. Register typed Go handlers for actions and
test them with fake resources or fake provider clients.

Test in layers. Add view-model tests, renderer tests, runtime/action tests, and
only then thin e2e tests for host mounting and representative browser behavior.

## Component Selection

Use shell components when the module needs a durable page frame, sidebar,
assistant pane, split list/detail view, or portal module chrome.

Use form components when the module asks for user input, filters data, submits
credentials, configures settings, or collects workflow decisions.

Use dense-data components when the module shows rows, records, notes, files,
ledger entries, usage events, plans, invoices, or other repeatable data.

Use status and result components for empty, loading, working, success, warning,
blocked, and error states.

Use provider/session helpers when the UI calls APIs, stores bearer session
state, shows credential entry, resolves API paths, or reports provider errors.

Use assistant components when the UI supervises AI threads, model selection,
turns, approvals, review-before-apply state, attachments, or active work.

Use terminal components when the UI streams command output, waits on command
approval, accepts stdin, or shows command exit state.

Use evidence and media components when the UI opens, previews, downloads, or
lists attached files, artifacts, documents, PDFs, photos, or other media.

## What Belongs Where

`bus-ui` should get a new primitive when two or more modules need the same
generic control, lifecycle helper, renderer helper, or test fake. The primitive
must be small enough to unit-test without a product module.

A product module should keep a local component when the behavior is tied to
domain concepts, provider permissions, product copy, or workflow state that
other modules should not inherit.

`bus-portal` should get a host feature when modules need consistent mounting,
asset delivery, security headers, path resolution, runtime config, or metadata.
It should not absorb product rendering or provider policy.

## UI Work Checklist

UI work is done when the product behavior is represented in view models, generic
components render the states deterministically, browser actions are wired
through typed handlers, automated tests cover projection/render/action behavior,
and thin e2e coverage proves the mounted host path.

Documentation should update the module README or public docs when the user
visible contract changes. CLI help or metadata should update when a UI command,
module registration option, or runtime flag changes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./testing">Testing UI apps</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/bus-ui">bus-ui module</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](./)
- [bus-ui module reference](../modules/bus-ui)
- [bus-portal module reference](../modules/bus-portal)
