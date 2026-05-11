---
title: UI framework reference checklist
description: Compact checklist for building BusDK UI modules with the shared UI framework.
---

## New UI Module Checklist

Start with the product boundary. Provider DTOs, API route contracts,
authorization checks, permission policy, and raw provider errors stay in the
provider/API modules that own them. The UI product module consumes those stable
contracts and owns only the projected view model, product copy, safe-link
presentation rules, and the exact user workflows the screen must support.

Define view models before rendering. Each view model should describe visible
data, controls, actions, errors, loading state, empty state, selected state,
links, and permissions without requiring the renderer to call providers or
infer business rules.

Choose the host shape. Default to a portal module when the UI belongs to a
pluggable Bus feature, needs shared auth/session behavior, or should run under
`bus-portal`. Choose a local app when the workflow is a standalone developer
tool, needs a local server plus Go/WASM client, or is not meant to be mounted
beside other portal features. A portal module implements the portal module
contract and receives paths, assets, and runtime config from `bus-portal`. A
local app may use an app shell directly, but it should still consume shared
components and runtime helpers.

Compose generic components. Use shared shells, navigation, forms, fields,
buttons, action bars, data tables, status tags, panels, error surfaces, loading
surfaces, evidence links, assistant panes, terminal panes, and drop zones before
adding product-local markup.

Capture important screens as declarative JSON/YAML fixtures when practical.
Keep fixture files next to the module UI tests, for example
`testdata/ui/review-list.yml`, or under `docs/docs/ui/examples/` when the
fixture is public documentation. Those files should use the same component
catalog as Go code and should render through:

```sh
bus-ui render testdata/ui/review-list.yml --format html
```

The shorthand `bus-ui testdata/ui/review-list.yml` may render HTML for quick
review, but tests should prefer the explicit command so the output format is
unambiguous.

Wire actions through stable tokens. A stable token is a lower-case kebab-case
string such as `save-draft`, scoped to the current UI document or Go component
tree. Declarative documents register tokens in the top-level `actions` map;
Go callers register the same tokens with typed handlers in the runtime action
router. Once public, tokens should not be renamed without a compatibility path
because tests, fixtures, and browser events depend on them.

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
state, shows credential entry, resolves API paths, or displays sanitized API
error contracts and safe provider-error summaries.

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
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../guides/testing">Testing UI apps</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../../modules/bus-ui">bus-ui module</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [bus-ui module reference](../../modules/bus-ui)
- [bus-portal module reference](../../modules/bus-portal)
