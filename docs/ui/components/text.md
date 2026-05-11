---
title: Text UI component
description: Dedicated BusDK UI reference for Text.
---

## Purpose

`Text` is a foundation component. Escaped scalar text node. Use for labels, messages, cells, and captions. It never accepts trusted HTML.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `value` | yes | string, number, boolean, or binding | Escaped before rendering. |
| `format` | no | registered formatter name | Formats the value before escaping. Valid names come from the host or `bus-ui` formatter registry, such as `date`, `number`, or product-registered names. Unknown formatter names fail validation. |

## Boundary

Rendered text is escaped and contains no raw markup.

## Example

```yaml
kind: Text
props:
  value: { bind: row.title }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./raw-html">RawHTML</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
