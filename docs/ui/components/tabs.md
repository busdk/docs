---
title: Tabs UI component
description: Dedicated BusDK UI reference for Tabs.
---

## Purpose

`Tabs` is a navigation/action/form component. Sibling view switcher. Use for sibling views at the same hierarchy level.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | array of `{id,label,href|action}` | Each item has stable string `id`, non-empty `label`, and exactly one of `href` or `action`. `href` accepts relative module routes, same-origin absolute paths, or resolver objects `{base,path}` where `base` is `module`, `portal`, or a named host route resolver and `path` begins with `/`. External origins require the host navigation allowlist. `action` is a token declared in the document top-level `actions` map or registered in the Go/WASM action handler map, and it runs when the tab is activated. Duplicate ids, missing labels, unknown action tokens, unsafe URLs, and mixed `href`+`action` entries fail validation. |
| `active` | yes | string | Current item id. Must match one `items[].id`; unknown active ids fail validation. |

## Boundary

Active tab is visible.

## Example

```yaml
kind: Tabs
props:
  active: files
  items:
    - { id: overview, label: Overview, href: ./ }
    - { id: files, label: Files, href: ./files }
```

## Runtime Terms

Tab links accept relative module routes such as `./files`, same-origin absolute
paths beginning with `/`, or host route resolver objects. Relative routes are
resolved against the current module route and must not escape it with `..`.
External `https:` links require the host navigation allowlist. `javascript:`,
`data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./menu">Menu</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./status-pill">StatusPill</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
