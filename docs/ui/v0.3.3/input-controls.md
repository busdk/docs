---
title: Library input controls
description: BusDK UI library text, password, date, textarea, and select input contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Expression children](../v0.1.5/expression-children)

## Contract

Input controls render editable values supplied by the view model.
[`Input`](./input), [`TextInput`](./text-input),
[`PasswordInput`](./password-input), [`DateInput`](./date-input),
[`TextArea`](./text-area), and [`Select`](./select)
provide reusable `bus-ui` form controls built from the lower-level GX form
elements.

Controls receive `name`, current value, disabled state, and optional Go
callbacks. Provider validation, normalization, and persistence stay in the
parent component and provider layer. Data reaches the control through ordinary
Go props and lexical scope, not through an external binding map or string event
registry.

| Field | Required | Behavior |
| --- | --- | --- |
| `name` | yes | Native form field name included in form state. |
| `type` | no | `Input` native control type. Defaults to `text`. Allowed values in this patch are `text`, `password`, `date`, `checkbox`, and `radio`; helper components set the matching type for their control. Unsupported values fail validation before render. |
| `value` | no | `Input`, `TextInput`, `PasswordInput`, and `TextArea` accept string values; numbers must be formatted by the parent before render. `DateInput` accepts `YYYY-MM-DD` or empty string. Missing values render the native empty value. Invalid values fail validation before render. |
| `selected` | no | `Select` accepts a selected option id string or an empty string. A non-empty value must match an option. |
| `checked` | no | `Input` accepts checked state for checkbox and radio controls. Named text helpers do not use `checked`. |
| `disabled` | no | Boolean; defaults false and prevents user edits when true. |
| `onInput` | no | Go callback for live text-like edits. Simple callbacks may accept the current string value. |
| `onChange` | no | Go callback for committed value changes, checkbox/radio changes, and select changes. |
| `options` | yes for `Select` | `[]SelectOption` values. `ID` is a unique non-empty string, `Label` is public-safe text, and optional `Disabled` prevents choosing that option. `selected` must equal one enabled option ID or be empty. |

```go
type SelectOption struct {
	ID       string
	Label    string
	Disabled bool
}
```

Callbacks use the DOM-compatible names defined by
[intrinsic callback naming](../v0.1.12/intrinsic-callback-naming) and the typed
payloads from [v0.1.15](../v0.1.15/typed-event-payloads). Simple text,
password, date, textarea, select, and radio callbacks may use `func(string)`;
checkbox `onChange` may use `func(bool)` for checked state. Handlers that need
source identity use `func(gx.InputEvent)` for `onInput` and
`func(gx.ChangeEvent)` for `onChange`. Other signatures fail validation before
render. Parent components may keep form state in Go and pass simple value
setters when source identity is not needed:

```gx
func NoteFields(p NoteFieldsProps) gx.Node {
  return (
    <Form id="note-fields" onSubmit={p.Save}>
      <Field label="Title">
        <TextInput name="title" value={p.Title} onInput={p.SetTitle}></TextInput>
      </Field>
      <Field label="Status">
        <Select name="status" selected={p.Status} options={p.StatusOptions} onChange={p.SetStatus}></Select>
      </Field>
    </Form>
  )
}
```

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
- [Intrinsic callback naming](../v0.1.12/intrinsic-callback-naming)
- [Typed event payloads](../v0.1.15/typed-event-payloads)
