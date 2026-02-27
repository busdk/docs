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
action wiring in their local code.

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
AI markdown rendering, approval formatting helpers, and shared CSS assets.

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
