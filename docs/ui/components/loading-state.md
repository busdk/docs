---
title: LoadingState UI component
description: Dedicated BusDK UI reference for LoadingState.
---

## Purpose

`LoadingState` is a data display component. Visible loading state. Use while resources or effects fetch data.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `message` | yes | string | Visible loading text. |
| `busy` | no | boolean | Default `true`; when true, sets busy semantics for assistive technology, and when false the component is only informational. |
| `progress` | no | number or string | Number is percent `0` through `100`; string is a display label such as `3 of 10`; omitted renders indeterminate loading. |

## Boundary

Loading states must always render the required `message` and expose busy
semantics when `busy` is true.

## Example

```yaml
kind: LoadingState
props:
  message: Loading notes
  busy: true
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./empty-state">EmptyState</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./result-panel">ResultPanel</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
