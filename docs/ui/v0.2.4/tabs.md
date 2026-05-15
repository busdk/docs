---
title: Tabs UI component
description: Dedicated BusDK UI reference for Tabs.
---

## Purpose

`Tabs` is a navigation/event/form component. Sibling view switcher. Use for sibling views at the same hierarchy level.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array | Each item has stable string `id`, non-empty `label`, and exactly one of `href` or `click`. `href` accepts relative module routes, same-origin absolute paths, or resolver objects with `base` and `path`, where `base` is `module`, `portal`, or a named host route resolver and `path` begins with `/`. External origins require the host navigation allowlist. `click` is declared in the runtime `events` map or registered in the Go WebAssembly event handler map, and it emits when the tab is activated. Duplicate ids, missing labels, unknown event names, unsafe URLs, and mixed `href`+`click` entries fail validation. |
| `active` | yes | string | Current item id. Must match one `items[].id`; unknown active ids fail validation. |

## Boundary

Active tab is visible.

## Example

```yaml
kind: Tabs
props:
  active: files
  items:
    - id: overview
      label: Overview
      href: ./
    - id: files
      label: Files
      href: ./files
```

## Runtime Terms

Tab links accept relative module routes such as `./files`, same-origin absolute
paths beginning with `/`, or host route resolver objects. Relative routes are
resolved against the current module route and must not escape it with `..`.
External `https:` links require the host navigation allowlist. `javascript:`,
`data:`, path traversal, and unresolved authorization failures are rejected.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
