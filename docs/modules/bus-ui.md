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
owns deterministic HTML escaping and attribute ordering helpers, reusable core
controls, shared CSS tokens, and generic AI interface components.

The module also owns generic assistant text rendering and generic approval-card
formatting so module frontends can keep only workspace-specific behavior and
action wiring in their local code. It also provides shared reusable AI runtime
state objects (`AIPanelSessionState`, `AIConversationState`) so modules avoid
duplicating generic assistant state models, plus interface-based AI refresh
host orchestration (`AIRefreshHost`) for clean state integration boundaries.
It also provides a reusable AI drop-controller (`NewAIDropController`) that
centralizes dropped-path/file import lifecycle wiring for assistant panels.
It also provides a reusable WASM app-scaffold (`WASMAppScaffold`) for generic
logger/error/callback retention and panic-safe async helper wiring.
The app scaffold also tracks explicit wiring teardown callbacks so modules can
dispose listeners/timers deterministically in reusable hosts and tests.
For module test suites, it also provides reusable testkit helpers under
`pkg/uikit/uikittest` (gateway/API stubs and deterministic fixture builders).
For ledger-style frontends, it also provides shared projection DTO contracts
and a reusable JSON-over-HTTP projection query client scaffold.
For AI-enabled frontends, it also provides a reusable AI action controller for
DOM action routing and shared panel action lifecycles.
The module also includes reusable WASM event wiring and DOM error-host helpers
so module frontends do not reimplement common browser wiring patterns.
Those wiring helpers now return disposer callbacks for explicit lifecycle
ownership (`WireAIPanelEvents`, `RegisterAIDropZoneHandlers`,
`WireSplitResize`).
It also provides shared callback-registry state (`AICallbackRegistry`), shared
AI-preserving mount behavior (`MountAIPreservedView`), shared standard table
composition (`TextTable`), and shared locale-aware field value formatting
(`LocaleFieldFormatter`) so module-level view code can stay focused on domain
composition.
For CLI modules that open local UI servers, it also provides shared
cross-platform browser opener helpers (`OpenURLInBrowser`,
`BrowserOpenCommandForOS`) so modules do not duplicate OS command mapping.
It also provides a reusable virtual DOM runtime (`VNode`,
`RenderVNodeComponent`, `VDOMMount`) so state updates can re-run component
functions and patch DOM incrementally instead of replacing full `innerHTML`.
For low-allocation hot paths, it also provides a compiled template API
(`Tpl(...)`, `TemplateValues`, `TemplateMount`) that mounts once and updates
only pre-bound text/attribute slots.

### Commands

`css` prints embedded shared CSS, `version` prints module version information,
and `help` prints usage text.

### Examples

```bash
bus ui css
bus ui version
bus-ui help
```

### Using from `.bus` files

```bus
ui css
```

### Development state

**Value promise:** one reusable UI component surface for BusDK frontends.

**Completeness:** 100% for current generic component scope.

**Current:** deterministic core controls, AI panel components, shared inline
AI markdown rendering, approval formatting helpers, shared virtual DOM patching
runtime, and shared CSS assets.

**Planned next:** expand component coverage only when reused by at least one
additional frontend module.

**Blockers:** None known.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-timeline">bus-timeline</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-vat">bus-vat</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui SDD](../sdd/bus-ui)
