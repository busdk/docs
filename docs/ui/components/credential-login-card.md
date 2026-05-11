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
| `submitAction` | yes | action token | Fires on form submit with `{username, secret}` from the two fields. |
| `requestAction` | no | action token | Shows a secondary request control, such as "send code"; emits `{username}` and is hidden when omitted. |

## Boundary

The component only collects credentials and dispatches actions. Auth APIs must
perform credential validation, OTP/token checks, rate limiting, session
creation, and authorization policy.

## Example

This component-only example assumes `request-otp` and `verify-otp` are already
declared in the document `actions` map or registered by Go code.

```yaml
kind: CredentialLoginCard
props:
  usernameLabel: Email
  passwordLabel: One-time code
  requestAction: request-otp
  submitAction: verify-otp
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./effect">Effect</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./provider-error">ProviderError</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
