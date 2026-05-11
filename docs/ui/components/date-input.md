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

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./password-input">PasswordInput</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./text-area">TextArea</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
