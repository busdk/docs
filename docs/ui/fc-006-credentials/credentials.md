---
title: Library credentials
description: BusDK UI credential entry boundary and identity-only event model.
---

## Foundations

[CredentialLoginCard](./credential-login-card) builds on checked form,
field, input, password-input, and button primitives. The card gives products a
shared credential surface without moving authentication authority into
`bus-ui`.

## Contract

[`CredentialLoginCard`](./credential-login-card) renders escaped public copy,
a required username field, a required secret field, a native POST form, a
submit button, and an optional secondary request-code button. Preferred
rendering uses `ui.CredentialLoginCard` plus `ui.RenderHTML`.

## Legacy compatibility

The compatibility helper remains available for callers that still need the
historical string-returning helper.

Credential callbacks are identity-only. `CredentialSubmitEvent` carries source
and submit routing metadata; `CredentialRequestEvent` identifies a secondary
request action. Neither event carries username, password, token, one-time code,
or other credential values.

| Event | Field | Behavior |
| --- | --- | --- |
| `CredentialSubmitEvent` | `SourceID` | Card id used to look up host-owned credential state. |
| `CredentialSubmitEvent` | `Action` | Public routing token; defaults to `credential.submit` when a submit callback is configured. |
| `CredentialSubmitEvent` | `Method`, `FormAction`, `Target` | Normalized POST submit metadata from the checked form. |
| `CredentialSubmitEvent` | `SubmitterID`, `SubmitterName`, `SubmitterValue` | Public submit button identity for hosts that route multiple controls through one handler. |
| `CredentialSubmitEvent` | `DefaultPrevented` | Records whether an adapter prevented the browser default; it does not carry field values. |
| `CredentialRequestEvent` | `SourceID` | Card id used to look up the username before requesting a code or token. |
| `CredentialRequestEvent` | `Action` | Public routing token; defaults to `credential.request` when a request callback is configured. |
| `CredentialRequestEvent` | `RequestID` | Derived request-control id, normally `<card-id>-request`. |
| `CredentialRequestEvent` | `DefaultPrevented` | Records adapter default-prevention state without carrying credential values. |

Host controllers read field state from their own model at handling time, send
provider requests, apply rate limits, create sessions, mutate CSRF state, and
project provider errors into public-safe UI. The card validates presentation
configuration only: id, labels, POST method, safe form action and target, and
safe action tokens.

Credential components must not log, echo, or expose secrets in runtime config,
client logs, HTML attributes, callback payloads, or diagnostics.

## Consequence

Credential entry stays reusable while authentication policy, token handling,
provider errors, route ownership, credential storage, and session creation stay
in the product or host module.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [CredentialLoginCard](./credential-login-card)
- [Form submission](../v0.3.1/form-submission)
- [bus-ui module reference](../../modules/bus-ui)
