---
title: Element UI component
description: Dedicated BusDK UI reference for Element.
---

## Purpose

`Element` is a foundation component. Generic HTML element. Use when no named component exists and the structure is still generic.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `tag` | yes | HTML tag name | Complete allowlist: `div`, `span`, `section`, `article`, `header`, `footer`, `main`, `nav`, `p`, `ul`, `ol`, `li`, `table`, `thead`, `tbody`, `tr`, `th`, and `td`; unsupported tags fail validation. |
| `children` | yes | component node list | Rendered in order. |
| `attrs` | no | attribute map | String, boolean, and number values only; event-handler attributes, unsafe URLs, and raw style strings are rejected. |
| `key` | no | string | Stable identity within the parent child list; duplicate sibling keys fail validation. Omitted keys reconcile by position. |

## Boundary

Output uses the requested safe tag and stable attributes.

## Example

```yaml
kind: Element
props:
  tag: section
  attrs:
    class: bus-ui-panel
children:
  - kind: Text
    props: { value: Generic content }
```

## Runtime Terms

Generic `Element` does not create links because `a` is outside its tag
allowlist. Use `LinkButton`, `EvidenceLink`, or media components when URL
policy or provider authorization is needed.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./raw-html">RawHTML</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fragment">Fragment</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
