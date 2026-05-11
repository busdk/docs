---
title: PasswordInput UI component
description: Dedicated BusDK UI reference for PasswordInput.
---

## Purpose

`PasswordInput` is a navigation/action/form component. Password or token field. Use for secrets and one-time codes.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | string | Submitted field name. |
| `placeholder` | no | string | Input hint. |
| `autocomplete` | no | current-password, new-password, one-time-code, off | Default `current-password`; use `one-time-code` for OTP fields and `new-password` for password creation/change. |

## Boundary

Current secret values are not rendered. When editing an existing secret, a blank
submitted value means "leave unchanged" only when the owning form/action
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

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./text-input">TextInput</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./date-input">DateInput</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
