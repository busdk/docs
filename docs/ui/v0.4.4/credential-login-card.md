---
title: CredentialLoginCard UI component
description: Dedicated BusDK UI reference for CredentialLoginCard.
---

## Purpose

`CredentialLoginCard` renders a reusable credential entry workflow for
email/password, token, or one-time-code sign-in.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `usernameLabel` | yes | string | First field label. |
| `passwordLabel` | yes | string | Secret/code field label. |
| `submit` | yes | event name | Fires on form submit with this component as source. The component controller exposes `username` and `secret` state under that source id; the app controller decides what to send. |
| `request` | no | event name | Shows a secondary request control, such as "send code"; the component controller exposes `username` state under this source id, and the control is hidden when omitted. |

## Boundary

The component only collects credentials and dispatches events. Auth APIs must
perform credential validation, OTP/token checks, rate limiting, session
creation, and authorization policy.
Events identify the card source; credential values stay in component/controller
state and are never copied into public markup or diagnostics.

## Example

This component-only example assumes `request-otp` and `verify-otp` are already
declared in the runtime `events` map or registered by Go code.

```yaml
kind: CredentialLoginCard
props:
  usernameLabel: Email
  passwordLabel: One-time code
  request: request-otp
  submit: verify-otp
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
