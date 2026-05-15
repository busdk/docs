---
title: Library input controls
description: BusDK UI library text, password, date, textarea, and select input contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Binding](../v0.1.5/binding)

## Contract

Input controls render editable values supplied by the view model.
[`Input`](./input), [`TextInput`](./text-input),
[`PasswordInput`](./password-input), [`DateInput`](./date-input),
[`TextArea`](./text-area), and [`Select`](./select)
provide generic input surfaces.

Controls receive `name`, current value, disabled state, and optional change
event names. Provider validation, normalization, and persistence stay in the
controller/provider layer.

| Field | Required | Behavior |
| --- | --- | --- |
| `name` | yes | Native form field name included in form state. |
| `value` | no | `Input`, `TextInput`, `PasswordInput`, and `TextArea` accept string values; numbers must be formatted by the controller before render. `DateInput` accepts `YYYY-MM-DD` or empty string. `Select` accepts an option id string. Missing or null renders the native empty value. Invalid values fail validation before render. |
| `disabled` | no | Boolean; defaults false and prevents user edits when true. |
| `change` | no | Runtime event name emitted with source identity when the value changes. |
| `options` | yes for `Select` | Array of `{id,label}` objects. `id` is a unique string and `label` is public-safe text. `value` must equal one option id or be empty. |

Change events use this shape:

```yaml
event: title-changed
source:
  id: title
  path: /Form[0]/TextInput[0]
```

The controller reads current model/form state after receiving the event. The
event does not carry provider payloads or a request body.

## Consequence

Input controls are reusable because they know control mechanics, not product
meaning.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Input](./input)
- [TextInput](./text-input)
- [Select](./select)
