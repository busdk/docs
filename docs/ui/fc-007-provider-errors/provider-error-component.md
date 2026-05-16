---
title: ProviderError UI component
description: Dedicated BusDK UI reference for ProviderError.
---

## Purpose

`ProviderError` renders a public-safe provider failure returned from a callback,
resource request, or background effect.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string | Error heading. |
| `status` | yes | `int` or `string` | Numeric HTTP status such as `403`, symbolic provider code such as `"quota_exceeded"`, or fallback `"unknown"`. Integer values from 500 through 599 render as danger; the string `"5xx"` is not accepted. Authentication and authorization failures render as danger, quota/rate-limit/conflict statuses render as warning, and `"unknown"` renders as neutral unless the host supplies stronger severity. |
| `summary` | yes | public-safe string | Safe explanation for the user. It may summarize a provider message only after secrets, tokens, raw payloads, stack traces, account identifiers, and private customer data are removed; otherwise replace it with a generic explanation. |
| `requestID` | no | string | Trace identifier. |

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
data.

## Example

```gx
package notesui

import . "github.com/busdk/bus-ui/pkg/uiprovider"

var uploadError = (
  <ProviderError
    title="Upload failed"
    status={403}
    summary="Access denied"
    requestID="req-123">
  </ProviderError>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
