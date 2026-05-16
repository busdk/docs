---
title: TextInput UI component
description: Dedicated BusDK UI reference for TextInput.
---

## Purpose

`TextInput` is a single-line text helper for short free-form values.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `value` | no | string | Current input value. Omitted renders an empty input. The rendered value is escaped. |
| `placeholder` | no | string | Hint, not label. |
| `onInput` | no | Go callback | Receives live edits as a simple string callback or typed input event callback. |
| `onChange` | no | Go callback | Receives committed changes when the parent needs change semantics instead of live input. |

## Boundary

Value is escaped. `placeholder` is a hint, not a label; pair the input with
`Field` or another visible label for accessible forms.

## Example

```gx
func TitleField(draft Draft, setTitle func(string)) gx.Node {
  return (
    <Field label="Title">
      <TextInput name="title" value={draft.Title} onInput={setTitle}></TextInput>
    </Field>
  )
}
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go
expressions inside markup bodies. [Typed event payloads](../v0.1.15/typed-event-payloads)
document when an `onInput` callback uses a payload instead of a plain string.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
