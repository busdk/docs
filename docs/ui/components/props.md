---
title: Props UI component
description: Dedicated BusDK UI reference for Props.
---

## Purpose

`Props` is a foundation component. Deterministic attribute map. Use from Go helpers when stable HTML attributes matter.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `attributes` | yes | map of string keys to scalar values | Keys are sorted before rendering. Values may be string, number, boolean, or null. Strings and numbers are escaped as attribute text, regular `true` renders the string value `"true"`, `false` and `null` omit the attribute, and empty string renders an empty attribute value. Use `bool:<name>` for HTML boolean attributes that should render without a value. |
| `bool:<name>` | no | boolean attribute entry | Boolean attribute syntax for flags such as `bool:disabled: true`. True renders `<name>` without a value, false or omitted leaves it out. |

## Boundary

Attribute ordering is stable across renders. Attribute names must be valid HTML
attribute names or `data-*`/`aria-*` names. Direct `Props` validation rejects
event handler attributes such as `onclick`. URL-bearing attributes such as
`href` or `src` must use safe same-origin or host-resolved values; higher-level
link/media components add stricter URL checks for their own props.

## Example

```yaml
attributes:
  class: bus-ui-button
  data-ui-action: save-draft
  bool:disabled: false
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fragment">Fragment</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./v-node">VNode</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
