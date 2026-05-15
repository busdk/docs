---
title: DateInput UI component
description: Dedicated BusDK UI reference for DateInput.
---

## Purpose

`DateInput` is a form field for collecting and submitting date-only values.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `value` | no | YYYY-MM-DD string | Empty when omitted. Invalid dates fail validation instead of being normalized. |

## Boundary

Value uses an exact `YYYY-MM-DD` date string. Datetime or timezone-bearing
values are rejected instead of truncated or normalized.
An empty value submits an empty string for the named field.

## Example

```yaml
kind: DateInput
props:
  name: due_date
  value: '2026-05-10'
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
