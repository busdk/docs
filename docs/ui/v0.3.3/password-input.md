---
title: PasswordInput UI component
description: Dedicated BusDK UI reference for PasswordInput.
---

## Purpose

`PasswordInput` is a password or token helper. Use it for secrets,
confirmation codes, and one-time codes.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `value` | no | string | Current entered value for transient fields such as one-time codes. Omit when editing an existing stored secret. |
| `placeholder` | no | string | Input hint. |
| `autocomplete` | no | current-password, new-password, one-time-code, off | Default `current-password`; use `one-time-code` for OTP fields and `new-password` for password creation/change. |
| `onInput` | no | Go callback | Receives the current entered value when the parent tracks edits. |
| `onChange` | no | Go callback | Receives committed changes when the parent waits for change semantics. |

## Boundary

Current secret values are not rendered. When editing an existing secret, a blank
submitted value means "leave unchanged" only when the owning form/event
explicitly declares preserve-on-blank behavior. Otherwise blank is submitted as
an empty replacement and the handler decides whether that is valid. To replace a
secret safely, submit a new value; to preserve one, omit the field or use the
form's documented preserve marker instead of echoing the current secret.

## Example

```gx
func OneTimeCodeField(code string, setCode func(string)) gx.Node {
  return (
    <Field label="One-time code">
      <PasswordInput
        name="otp"
        placeholder="One-time code"
        autocomplete="one-time-code"
        value={code}
        onInput={setCode}>
      </PasswordInput>
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
