---
title: bus-ui — reusable UI component module for BusDK frontends
description: Shared deterministic HTML/CSS component helpers and reusable AI UI rendering primitives for BusDK WASM frontends.
---

## `bus-ui` — reusable UI component module for BusDK frontends

### Synopsis

`bus ui [global flags] [css | version | help]`  
`bus-ui [css | version | help]`

### Description

`bus-ui` provides shared UI building blocks for BusDK frontend modules. It
includes deterministic HTML escaping and attribute ordering helpers, reusable
core controls, shared CSS tokens, generic authentication surfaces, generic form
surfaces, shared download/link actions, reusable summary and metric cards,
generic timeline and gallery renderers, and generic AI interface components.

The public surface is node-first: reusable components build `gx.Node` trees,
checked helpers validate public inputs before render, and HTML output happens
through the shared render boundary or explicitly named HTML adapters. The
`Checked` and silent string helpers remain compatibility and migration
vocabulary rather than the preferred authoring shape.

Current implemented UI roadmap milestone: **FC-011 Assistant composer and
attachments**.

Use `bus-ui` when a BusDK frontend needs shared presentation pieces instead of
module-local markup. Stable exported surfaces include form controls, buttons,
cards, tables, shells, shared CSS, assistant panels, terminal panes, evidence
surfaces, browser/WASM helpers, VDOM mounting, and compiled template helpers.
The preferred public `pkg/ui` facade also re-exports `Fragment` and
`RenderHTML` so callers can compose `gx.Node` trees at the page boundary while
keeping the older string helpers available for compatibility.

For assistant frontends, `bus-ui` keeps generic panel rendering, message
formatting, model selection, approval cards, activity status, close guards, and
drop handling out of product modules. FC-011 adds checked assistant draft
primitives: `AIComposerChecked` renders controlled draft input with source-only
send and interrupt callbacks, `AIAttachmentListChecked` renders approved
attachment chips with callback-gated controls, and
`ApplyAIAttachmentStateEventChecked` applies host-owned attachment state
changes. Browser file access, upload policy, authorization, provider transfer,
and product-specific behavior stay in the owning module.

The focused UI framework references describe the public contracts for
[assistant panels](../ui/fc-009-assistant-workbench-shell/assistant-panel),
[assistant messages](../ui/fc-010-assistant-threads-messages/assistant-messages),
[assistant composer and attachments](../ui/fc-011-assistant-composer-attachments/),
[forms](../ui/v0.3.1/forms),
[shells](../ui/v0.2.6/shells), and
[terminal panes](../ui/fc-015-terminal-io/terminal-output).

### Portal-family adoption readiness

`bus-ui` owns the shared readiness contract for `bus-portal-*` modules before
they move to final compiled `.gx` roots and the shared `MountedApp` testkit
path. Product policy stays outside `bus-ui`: accounting copy and evidence
rules, auth session and CSRF behavior, Notes permission and Markdown safety,
provider routes, DTO projection, and authorization decisions remain in the
owning module or provider.

The pre-final bridge pattern is:

- keep deterministic render seams that can later be replaced one shell at a
  time
- keep module-owned action and resource registries explicit while using shared
  `bus-ui` validation, result, resource, and logging contracts
- declare WASM assets and runtime configuration through the portal host/module
  metadata instead of hidden module-local script behavior
- cover fake-provider success and failure paths for action/resource dispatch
- prove mounted runtime behavior with shared `MountApp` / `MountedApp` and
  `uikittest` harnesses before accepting compiled-root handoff

The current module-owned readiness plans are:

- `bus-portal-accounting/PLAN.md`
- `bus-portal-auth/PLAN.md`
- `bus-portal-notes/PLAN.md`

Final compiled-root migration for those modules should wait until the shared
`MountedApp` / testkit path and `bus-portal` host metadata handoff prove
module metadata, declared assets, public runtime config, provider-origin CSP,
teardown, rerender, and hook-state continuity.

### Commands

`css` writes the embedded shared CSS bundle to stdout. Use shell redirection or
the standard `--output` flag when a frontend needs a checked-in or served CSS
asset. `version` prints module version information, and `help` prints usage
text.

### Examples

```bash
bus ui css > ./assets/bus-ui.css
bus ui --output ./assets/bus-ui.css css
bus ui version
bus-ui help
```

### Using from `.bus` files

```bus
# same as: bus ui --output ./assets/bus-ui.css css
ui --output ./assets/bus-ui.css css
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-timeline">bus-timeline</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module repository](https://github.com/busdk/bus-ui)
- [Assistant composer and attachments](../ui/fc-011-assistant-composer-attachments/)
