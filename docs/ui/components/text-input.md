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
| `value` | no | string or binding | Current input value. Omitted renders an empty input. Bindings must resolve to a string or a value that can be deterministically formatted as text; invalid objects fail validation. The rendered value is escaped. |
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
      value: { bind: draft.title }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./input">Input</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./password-input">PasswordInput</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
