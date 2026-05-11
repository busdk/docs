---
title: StatusPill UI component
description: Dedicated BusDK UI reference for StatusPill.
---

## Purpose

`StatusPill` is a data display component. Compact semantic status. Use for row
state and compact workflow labels. It is non-interactive status text; wrap it in
an action component only when the surrounding UI needs a separate control.

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

```yaml
kind: StatusPill
props:
  label: Review
  status: warning
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./tabs">Tabs</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./icon">Icon</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
