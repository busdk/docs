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
| `id` | yes | string | Stable source identifier used as `SourceID` in callbacks and as the key for controller-owned credential state. |
| `usernameLabel` | yes | string | First field label. |
| `passwordLabel` | yes | string | Secret/code field label. |
| `onSubmit` | yes | `func(CredentialSubmitEvent) gx.Result` | Fires on form submit with this component as source. |
| `onRequest` | no | `func(CredentialRequestEvent) gx.Result` | Shows a secondary request control. The default label is `Send code`; override it with `requestLabel`. The control is hidden when omitted. |
| `requestLabel` | no | string | Visible label for the secondary request control. |

## Boundary

The component only collects credentials and dispatches events. Auth APIs must
perform credential validation, OTP/token checks, rate limiting, session
creation, and authorization policy.
Events identify the card source; credential values stay in component/controller
state and are never copied into public markup or diagnostics.

## Example

These snippets are embedded in one `.gx` file where the callbacks are declared
before the component value.

```go
package loginui

import (
	"github.com/busdk/bus-gx/pkg/gx"
	. "github.com/busdk/bus-ui/pkg/uiauth"
)

type CredentialState interface {
	Username(sourceID string) string
	Secret(sourceID string) string
}

type AuthClient interface {
	SendCode(username string) gx.Result
	VerifyCode(username string, secret string) gx.Result
}

var loginState CredentialState
var authClient AuthClient

func bindLoginController(controller *CredentialController) {
	loginState = controller.CredentialState()
}

func requestOTP(event CredentialRequestEvent) gx.Result {
	username := loginState.Username(event.SourceID)
	return authClient.SendCode(username)
}

func verifyOTP(event CredentialSubmitEvent) gx.Result {
	username := loginState.Username(event.SourceID)
	secret := loginState.Secret(event.SourceID)
	return authClient.VerifyCode(username, secret)
}
```

`authClient` is application-owned. `loginState` is initialized from the
`CredentialController` that mounts this component through `bindLoginController`;
applications do not pass credential state as a prop. The component package
supplies `CredentialSubmitEvent` and `CredentialRequestEvent`; each event has a
`SourceID string` field.

```gx
var otpLogin = (
  <CredentialLoginCard
    id="otp-login"
    usernameLabel="Email"
    passwordLabel="One-time code"
    requestLabel="Send one-time code"
    onRequest={requestOTP}
    onSubmit={verifyOTP}>
  </CredentialLoginCard>
)
```

## Runtime Terms

`onSubmit` and `onRequest` are Go callback props for this library component.
The event contains only the `SourceID`, which is copied from the required `id`
prop. The component controller initializes credential state for that id when the
card mounts. Callback code reads `username` and `secret` from controller-owned
state for that source at handling time. Credential values must not be copied into
event payloads, public markup, logs, or diagnostics.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
