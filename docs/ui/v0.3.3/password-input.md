---
title: PasswordInput UI component
description: Dedicated BusDK UI reference for PasswordInput.
---

## Purpose

`PasswordInput` is a navigation/event/form component. Password or token field. Use for secrets and one-time codes.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `placeholder` | no | string | Input hint. |
| `autocomplete` | no | current-password, new-password, one-time-code, off | Default `current-password`; use `one-time-code` for OTP fields and `new-password` for password creation/change. |

## Boundary

Current secret values are not rendered. When editing an existing secret, a blank
submitted value means "leave unchanged" only when the owning form/event
explicitly declares preserve-on-blank behavior. Otherwise blank is submitted as
an empty replacement and the handler decides whether that is valid. To replace a
secret safely, submit a new value; to preserve one, omit the field or use the
form's documented preserve marker instead of echoing the current secret.

## Example

```yaml
kind: PasswordInput
props:
  name: otp
  placeholder: One-time code
  autocomplete: one-time-code
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
