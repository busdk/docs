---
title: Field UI component
description: Dedicated BusDK UI reference for Field.
---

## Purpose

`Field` wraps one visible form control with its label, hint, and validation
message.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `label` | yes | string | Visible label; empty labels fail validation. |
| `children` | yes | one control node | Input/select/textarea. |
| `hint` | no | string | Help text associated through `aria-describedby`; omitted renders no hint. |
| `error` | no | string | Validation error associated through `aria-describedby` and marks the control invalid. |

## Boundary

`Field` associates the label with the child control automatically when the
child has `name` and no `id`; otherwise it uses the child `id`. A child with
neither `id` nor `name` fails validation because the label would be inaccessible.

## Example

```yaml
kind: Field
props:
  label: Search
children:
  - kind: TextInput
    props:
      name: q
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
