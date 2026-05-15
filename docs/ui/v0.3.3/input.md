---
title: Input UI component
description: Dedicated BusDK UI reference for Input.
---

## Purpose

`Input` is a navigation/event/form component. Generic typed input. Use when no named input helper exists, and pair visible inputs with a `Field` label or an explicit accessible label supplied by the surrounding form.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `type` | yes | HTML input type | Exact accepted set: `text`, `search`, `email`, `url`, `number`, `date`, `password`, `checkbox`, `radio`, `file`, `hidden`. Unsupported values fail validation. |
| `name` | yes | string | Submitted field name. |
| `value` | no | scalar | Current value; omitted for file. Required for each `radio` option so options sharing a `name` submit distinct values instead of browser default `on`. |
| `checked` | no | boolean | Applies only to checkbox/radio controls. Default `false`; checked checkbox controls submit `value` or `on` when value is omitted, checked radio controls submit their explicit `value`, and unchecked controls submit nothing. |
| `labelledBy` | no | element id | Associates a bare input with external visible label text when it is not wrapped by `Field`. Either `Field` or `labelledBy` must provide the accessible name for visible inputs. |

## Boundary

File inputs do not echo file values. Bare visible inputs must have an accessible
name through `Field` or `labelledBy`; hidden inputs do not need a visible label.

## Example

```yaml
kind: Field
props:
  label: Quantity
children:
  - kind: Input
    props:
      type: number
      name: quantity
      value: 3
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
