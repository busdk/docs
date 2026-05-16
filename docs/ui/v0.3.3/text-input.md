---
title: TextInput UI component
description: Dedicated BusDK UI reference for TextInput.
---

## Purpose

`TextInput` is a form component. Single-line text field. Use for short free-form text.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `value` | no | string or Go value | Current input value. Omitted renders an empty input. Values must resolve to a string or a value that can be deterministically formatted as text; invalid objects fail validation. The rendered value is escaped. |
| `placeholder` | no | string | Hint, not label. |

## Boundary

Value is escaped. `placeholder` is a hint, not a label; pair the input with
`Field` or another visible label for accessible forms.

## Example

```yaml
kind: Field
props:
  label: Title
  input:
    kind: TextInput
    props:
      name: title
      value:
        bind: draft.title
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
