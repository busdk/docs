---
title: SplitLayout UI component
description: Dedicated BusDK UI reference for SplitLayout.
---

## Purpose

`SplitLayout` is a shell/layout component. Resizable pane layout. Use for list/detail or detail/evidence views.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `slots` | yes | named pane slots | Two named pane slots. Horizontal layouts use `left` and `right`; vertical layouts use `top` and `bottom`. Slots are the pane contract; there is no separate `panes` prop. Unsupported pane names fail validation. |
| `widths` | no | map from slot name to CSS length | Initial pane sizes. Keys must match the supported `slots` names; values use stable CSS lengths such as `18rem`, `320px`, or `40%`. Omitted widths let the host layout choose defaults. |
| `resize` | no | none, horizontal, vertical | Defaults `none`. `none` fixes pane sizes from CSS/defaults, `horizontal` lets users adjust side-by-side pane widths, and `vertical` lets users adjust stacked pane heights. |

## Boundary

Pane sizes use stable CSS variables on the SplitLayout root:
`--bus-ui-split-left`, `--bus-ui-split-right`, `--bus-ui-split-top`, and
`--bus-ui-split-bottom`. The host may set initial values through `widths` or
CSS; omitted variables fall back to equal pane distribution. Product code may
override the variables for layout, but component content should not depend on
pixel-exact values.

## Example

```gx
package reviewui

var reviewSplit = (
  <SplitLayout resize="horizontal">
    <RecordList slot="left" items={notes}></RecordList>
    <Panel slot="right" title="Detail"></Panel>
  </SplitLayout>
)
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
