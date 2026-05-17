---
title: ProviderError UI component
description: Shared BusDK UI provider error props and validation.
---

## Purpose

`ProviderErrorChecked` renders a public-safe provider failure returned from a
callback, resource request, or background effect. `ProviderErrorHTML` is the
string-returning compatibility helper for callers that need fail-closed markup.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `Title` | yes | `string` | Error heading. |
| `Summary` | no | `string` | Public-safe explanation; `Message` is accepted as a compatibility alias. |
| `Code` | no | `string` | Public code-like metadata. |
| `Status` | no | `any` | Numeric HTTP status, numeric string, accepted symbolic status, or empty for `unknown`. |
| `RequestID` | no | `string` | Support-safe trace identifier. |
| `Fields` | no | `map[string]string` | Public field path to public-safe validation message. |
| `FieldErrors` | no | `[]FieldError` | Structured field validation messages. |
| `RetryLabel`, `Retry` | no | `string`, `ControlProps` | Retry control label and action metadata. |
| `DismissLabel`, `Dismiss` | no | `string`, `ControlProps` | Dismiss control label and action metadata. |
| `Severity` | no | `StatusSurfaceStatus` | Optional shared severity override. |
| `HeadingLevel` | no | `int` | Heading level for the rendered title; defaults to 3. |

Accepted symbolic statuses are:

| Status | Severity |
| --- | --- |
| `"unauthenticated"` | danger |
| `"unauthorized"` | danger |
| `"forbidden"` | danger |
| `"quota_exceeded"` | warning |
| `"rate_limited"` | warning |
| `"conflict"` | warning |
| `"unavailable"` | warning |
| `"unknown"` | neutral |

## Boundary

Raw provider payloads are not displayed. `requestID` may show a support-safe
trace identifier, but it must not contain credentials or user-private payload
data. Provider transport, retry policy, credential handling, raw payload
storage, and product-specific error meaning stay outside `bus-ui`.

## Example

```go
package notesui

import "github.com/busdk/bus-ui/pkg/uikit"

func UploadError() (string, error) {
	return uikit.ProviderErrorChecked(uikit.ProviderErrorProps{
		Title:     "Upload failed",
		Summary:   "Access denied",
		Status:    403,
		RequestID: "req-123",
		RetryLabel: "Try again",
		Retry: uikit.ControlProps{
			Action:   "provider.retry",
			SourceID: "upload",
		},
	})
}
```

`ProviderErrorFromResult` projects a public-safe provider-error `Result` into
render props. `RedactProviderErrorText` and `RedactProviderRequestID` are
available for hosts that adapt provider diagnostics before checked rendering.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Library provider errors](./provider-errors)
- [bus-ui module reference](../../modules/bus-ui)
