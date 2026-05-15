---
title: ProviderError UI component
description: Dedicated BusDK UI reference for ProviderError.
---

## Purpose

`ProviderError` is an event/resource/effect component. Safe provider failure surface. Use for structured provider failures.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string | Error heading. |
| `status` | yes | HTTP/provider status code or symbolic status | Numeric HTTP status such as `403`, provider code such as `quota_exceeded`, or fallback `unknown`. `5xx` and authentication/authorization failures render as danger, quota/rate-limit/conflict statuses render as warning, and `unknown` renders as neutral unless the host supplies stronger severity. |
| `summary` | yes | public-safe string | Safe explanation for the user. It may summarize a provider message only after secrets, tokens, raw payloads, stack traces, account identifiers, and private customer data are removed; otherwise replace it with a generic explanation. |
| `requestID` | no | string | Trace identifier. |

## Boundary

Raw provider payloads are not displayed. `requestID` may show a support-safe
trace identifier, but it must not contain credentials or user-private payload
data.

## Example

```yaml
kind: ProviderError
props:
  title: Upload failed
  status: 403
  summary: Access denied
  requestID: req-123
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
