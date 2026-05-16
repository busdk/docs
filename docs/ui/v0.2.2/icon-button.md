---
title: IconButton UI component
description: Dedicated BusDK UI reference for IconButton.
---

## Purpose

`IconButton` is an icon-only button for compact repeated controls.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `icon` | yes | icon name | One of the shared names from the [v0.2.1 icon registry](../v0.2.1/icon), which remains the required registry for this patch. Unknown names fail validation. |
| `ariaLabel` | yes | string | Non-empty descriptive accessible name for the icon-only control. |
| `onClick` | no | function | Go callback invoked when the enabled control is clicked. Omit only when `disabled: true`; enabled IconButtons without `onClick` fail validation. |
| `disabled` | no | boolean | Default `false`; disabled icon buttons do not emit events. |
| `variant` | no | primary, secondary, danger, ghost | Default secondary. |

## Boundary

Icon-only controls remain accessible.

## Example

```gx
var archiveAction = (
  <IconButton icon="archive" ariaLabel="Archive note" onClick={archiveNote}></IconButton>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
