---
title: Library provider errors
description: BusDK UI library safe provider failure display contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`ProviderError`](../fc-007-provider-errors/provider-error-component) renders public-safe provider
failure display. Request id, status, retry event, and validation fields are
optional. Raw payloads, tokens, SQL, stack traces, and private customer data
fail validation.

Public-safe text may include the failed action, a short user action, a status
code, a public request id, and field-level validation messages. It must not
include credentials, bearer tokens, raw provider responses, SQL, stack traces,
account identifiers, customer-private data, file contents, or prompt text.

| Field | Required | Behavior |
| --- | --- | --- |
| `title` | yes | Public-safe string shown as the error heading. |
| `message` | no | Public-safe string; omitted when no user action is available. |
| `code` | no | Public provider/application error code string; omitted when unavailable. |
| `status` | no | HTTP or provider status code as string or number. |
| `requestID` | no | Public support identifier. |
| `retry` | no | `func() gx.Result` callback for a retry control. The callback repeats the safe product action and returns the [runtime result](../fc-003-resources/runtime-contract); success clears or refreshes the error, provider failure renders another safe error, and no-op leaves state unchanged. It does not receive raw provider payloads. |
| `fields` | no | Map of field name to public-safe validation string. |

Missing `title` or unsafe text fails validation before render.

Provider modules own error meaning. Product modules project provider errors
into safe title, message, code, request id, retry state, and field validation
before rendering.

```go
safeError := ProviderErrorProps{
	Title:     "Could not save note",
	Message:   "Check the title and try again.",
	Status:    422,
	RequestID: "req_123",
	Fields: map[string]string{
		"title": "Title is required.",
	},
}
```

This raw payload is rejected:

```go
unsafeError := ProviderErrorProps{
	Title:   "SQL failed",
	Message: "token=secret SELECT * FROM customers",
}
```

## Consequence

Users see actionable errors without exposing provider internals or credentials.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [ProviderError](../fc-007-provider-errors/provider-error-component)
- [Render tree contract](../v0.1.1/render-tree-contract)
