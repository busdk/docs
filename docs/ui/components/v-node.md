---
title: VNode UI component
description: Dedicated BusDK UI reference for VNode.
---

## Purpose

`VNode` is a foundation component. Virtual DOM node shared by server and Go/WASM rendering. Use when one tree must support deterministic HTML, mounted updates, and unit inspection.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `kind` | yes | element, text, raw, or fragment | Selects the node representation. |
| `tag` | for element | HTML tag | Required for element nodes. |
| `text` | for text | string | Escaped before rendering. |
| `html` | for raw | trusted HTML string | Required for raw nodes. Raw nodes bypass escaping and require the same sanitizer/source-policy review as [RawHTML](./raw-html). |
| `attrs` | no | attribute map | Stable order. |
| `children` | no | node list | Rendered in order. |
| `key` | no | string | Used for incremental updates. |

## Boundary

Server HTML and mounted updates consume the same tree. Prefer `text` nodes for
user/provider content; use `raw` only for sanitizer-produced or framework-owned
trusted HTML.

Kind-specific validation is strict. `element` requires `tag` and may use
`attrs`, `children`, and `key`; `text` requires `text`, may use `key`, and rejects `tag`,
`attrs`, `html`, and `children`; `raw` requires `html`, may use `key`, and rejects
`children`; `fragment` uses `children` and optional `key` but rejects `tag`,
`text`, `html`, and `attrs`. Fields outside the selected kind fail validation
instead of being ignored.

## Example

```yaml
kind: element
tag: article
key: note-1
children:
  - kind: text
    text: Evidence note
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./props">Props</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./component">Component</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
