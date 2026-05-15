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

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
