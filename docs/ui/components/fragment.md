---
title: Fragment UI component
description: Dedicated BusDK UI reference for Fragment.
---

## Purpose

`Fragment` is a foundation component. Child group without a wrapper element. Use inside slots or conditional branches where the parent owns the semantic element.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `children` | yes | component node list | Rendered in order. |
| `key` | no | string | Controls child identity across mounted updates; omitted means children are reconciled by position. |

## Boundary

No extra wrapper appears in the rendered tree.

## Example

```yaml
kind: Fragment
children:
  - kind: Text
    props: { value: First }
  - kind: Text
    props: { value: Second }
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./element">Element</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./props">Props</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
