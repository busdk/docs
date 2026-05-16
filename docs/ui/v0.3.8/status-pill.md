---
title: StatusPill UI component
description: Dedicated BusDK UI reference for StatusPill.
---

## Purpose

`StatusPill` is a data display component. Compact semantic status. Use for row
state and compact workflow labels. It is non-interactive status text; wrap it in
an event component only when the surrounding UI needs a separate control.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `label` | yes | string | Visible status. |
| `status` | yes | neutral, working, success, warning, danger, muted | Semantic class. |

## Boundary

Status text is visible, not color-only.

Status values carry these meanings: `neutral` is informational with no state
judgment, `working` means in progress, `success` means completed successfully,
`warning` means usable but attention is needed, `danger` means failed or unsafe
until corrected, and `muted` means inactive or secondary context. Do not use
color alone to communicate the value; the label must remain meaningful.

## Example

```gx
package notesui

var reviewStatus = (
  <StatusPill label="Review" status="warning"></StatusPill>
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
