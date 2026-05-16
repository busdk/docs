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
| `onInput` | no | Go callback | Receives live string edits when the parent tracks partial edits. |
| `onChange` | no | Go callback | Receives committed date string changes. |

## Boundary

Value uses an exact `YYYY-MM-DD` date string. Datetime or timezone-bearing
values are rejected instead of truncated or normalized.
An empty value submits an empty string for the named field.

## Example

```gx
func DueDateField(dueDate string, setDueDate func(string)) gx.Node {
  return (
    <Field label="Due date">
      <DateInput name="due_date" value={dueDate} onChange={setDueDate}></DateInput>
    </Field>
  )
}
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
