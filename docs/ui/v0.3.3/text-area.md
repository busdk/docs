---
title: TextArea UI component
description: Dedicated BusDK UI reference for TextArea.
---

## Purpose

`TextArea` is a multiline text helper. Use it for notes, comments, prompts,
and drafts.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `value` | no | string | Current multiline content. Omitted renders an empty text area. |
| `rows` | no | integer | Visible row count. Defaults to `4`; valid values are positive integers from `1` through `40`. |
| `onInput` | no | Go callback | Receives live edits as a simple string callback or typed input event callback. |
| `onChange` | no | Go callback | Receives committed changes when the parent needs change semantics. |

## Boundary

Multiline content is HTML-escaped before rendering. Markup in bound or user text
is displayed literally, not interpreted. Invalid non-text values fail
validation instead of being stringified unpredictably.

## Example

```gx
func BodyField(draft Draft, setBody func(string)) gx.Node {
  return (
    <Field label="Body">
      <TextArea name="body" rows={8} value={draft.Body} onInput={setBody}></TextArea>
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
