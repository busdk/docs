---
title: CredentialLoginCard UI component
description: Shared BusDK UI credential card props and callbacks.
---

## Purpose

`ui.CredentialLoginCard` renders a reusable credential entry card for
email/password, token, or one-time-code sign-in. Render the returned node with
`ui.RenderHTML` at the page boundary.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `ID` | yes | `string` | Stable source identifier used as `SourceID` in callbacks and for derived field ids. |
| `Title` | no | `string` | Panel heading; defaults to `Sign in`. |
| `Copy` | no | `string` | Escaped public helper text above the form. |
| `FormMethod` | no | `FormMethod` | Must be `FormMethodPost`; empty normalizes to POST. |
| `FormAction` | no | `string` | Optional app-relative or same-origin action; schemes, protocol-relative URLs, backslashes, navigation whitespace, and `..` path segments are rejected. |
| `FormTarget` | no | `string` | Optional safe target; `_self`, `_blank`, `_parent`, `_top`, or named targets using letters, digits, `-`, `.`, or `:` are accepted. |
| `FormAttrs` | no | `map[string]string` | Extra form attributes; `method`, `action`, `target`, and `data-ui-action` are normalized with the explicit form props taking precedence. |
| `SubmitAction` | no | `string` | Submit routing token; defaults to `credential.submit` when `OnSubmit` is set and no form `data-ui-action` is supplied. |
| `RequestAction` | no | `string` | Secondary request routing token; defaults to `credential.request` when `OnRequest` is set and no request control action is supplied. |
| `OnSubmit` | yes for interactive submit | `func(CredentialSubmitEvent)` | Receives source and submit routing metadata without credential values. |
| `OnRequest` | no | `func(CredentialRequestEvent)` | Enables a secondary request-code control. |
| `RequestLabel` | no | `string` | Secondary control label; defaults to `Send code`. |
| `Request` | no | `ButtonProps` | Secondary control props; `Request.Control.Action` or `Request.Attrs["data-ui-action"]` can override `RequestAction`. |
| `UsernameLabel` | yes | `string` | Public label for the username field. |
| `UsernameName` | no | `string` | Submitted username field name; defaults to `username`. |
| `UsernameType` | no | `string` | Input type such as `email`; defaults to text. |
| `UsernameAutocomplete` | no | `string` | Browser autocomplete token such as `username` or `email`; defaults to `username`. |
| `PasswordLabel` | yes | `string` | Public label for the secret/code field. |
| `PasswordName` | no | `string` | Submitted secret field name; defaults to `password`. |
| `PasswordAutocomplete` | no | `string` | Autocomplete token such as `one-time-code`. |
| `Submit` | no | `ButtonProps` | Submit button props; the button is rendered as native `type="submit"`. |
| `Busy`, `ErrorText`, `ErrorID` | no | mixed | Shared form busy and safe error display state. |

## Boundary

The component only collects credentials and dispatches events. Auth APIs must
perform credential validation, OTP/token checks, rate limiting, session
creation, and authorization policy.

Events identify the card source and public routing metadata. Credential values
stay in browser form controls and host-owned controller state; they are never
copied into callback payloads, public markup, logs, or diagnostics.

## Example

```go
package loginui

import (
	"context"

	"github.com/busdk/bus-ui/pkg/ui"
)

type CredentialState interface {
	Username(sourceID string) string
	Secret(sourceID string) string
}

type AuthClient interface {
	SendCode(ctx context.Context, username string) error
	VerifyCode(ctx context.Context, username string, secret string) error
}

type ErrorSink interface {
	ShowProviderError(sourceID string, err error)
}

var loginState CredentialState
var authClient AuthClient
var loginErrors ErrorSink
var requestContext func(sourceID string) context.Context

func requestOTP(event ui.CredentialRequestEvent) {
	ctx := requestContext(event.SourceID)
	username := loginState.Username(event.SourceID)
	if err := authClient.SendCode(ctx, username); err != nil {
		loginErrors.ShowProviderError(event.SourceID, err)
	}
}

func verifyOTP(event ui.CredentialSubmitEvent) {
	ctx := requestContext(event.SourceID)
	username := loginState.Username(event.SourceID)
	secret := loginState.Secret(event.SourceID)
	if err := authClient.VerifyCode(ctx, username, secret); err != nil {
		loginErrors.ShowProviderError(event.SourceID, err)
	}
}

func OTPLoginCard() (string, error) {
	node, err := ui.CredentialLoginCard(ui.CredentialLoginCardProps{
		ID:                   "otp-login",
		Title:                "Sign in",
		Copy:                 "Use your work email and one-time code.",
		FormAction:           "/auth/login",
		OnRequest:            requestOTP,
		OnSubmit:             verifyOTP,
		RequestLabel:         "Send one-time code",
		UsernameLabel:        "Email",
		UsernameName:         "email",
		UsernameType:         string(ui.InputTypeEmail),
		UsernameAutocomplete: "email",
		PasswordLabel:        "One-time code",
		PasswordName:         "code",
		PasswordAutocomplete: "one-time-code",
		Submit: ui.ButtonProps{
			Label: "Continue",
		},
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
}
```

`authClient` and `loginState` are application-owned. Callback code uses the
event `SourceID` to read host-owned credential state for that card, then sends
the provider request outside `bus-ui`.

## Rendering Terms

## Legacy compatibility

The compatibility helper fails before render when required labels are missing,
the card id is unsafe, the form method is not POST, the action or target is
unsafe, or an action token is invalid. Submit action tokens come from
`SubmitAction` first, then `FormAttrs["data-ui-action"]`; request action
tokens come from `RequestAction`, then `Request.Control.Action`, then
`Request.Attrs["data-ui-action"]`. A valid token is a non-empty string using
letters, digits, `-`, `_`, `.`, `/`, or `:`. The compatibility helper keeps
historical defaults for callers that still need a string-only render path.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Library credentials](./credentials)
- [bus-ui module reference](../../modules/bus-ui)
