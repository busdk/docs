---
title: Library provider errors
description: BusDK UI provider error projection and public-safety boundary.
---

## Foundations

[ProviderError](./provider-error-component) gives products a shared display
surface for provider failures after the owning module has projected raw
provider data into public-safe facts.

## Contract

Preferred rendering uses `ui.ProviderError` plus `ui.RenderHTML`. The checked
`ProviderErrorChecked` helper remains available for compatibility. Missing
titles, invalid status values, unsafe request ids, invalid field paths,
duplicate field projections, and unsafe text fail before render.

Public-safe text may include the failed action, a short user action, a status
code, a public request id, and field-level validation messages. It must not
include credentials, bearer tokens, raw provider responses, SQL, stack traces,
account identifiers, customer-private data, file contents, prompt text, cookies,
private keys, or secret-bearing key/value fragments.

| Field | Required | Behavior |
| --- | --- | --- |
| `Title` | yes | Public-safe string shown as the error heading. |
| `Summary` or `Message` | no | Public-safe user-facing explanation. |
| `Code` | no | Public provider or application error code. |
| `Status` | no | Numeric HTTP status, numeric string, or `unauthenticated`, `unauthorized`, `forbidden`, `quota_exceeded`, `rate_limited`, `conflict`, `unavailable`, or `unknown`. |
| `RequestID` | no | Support-safe trace identifier. It must start with a letter or digit and then use only letters, digits, `.`, `_`, `:`, or `-`, up to 128 characters. Omit or redact provider ids that do not match. |
| `Fields` | no | Map of field path to public-safe validation string. Field paths use dot-separated identifiers or non-negative indexes, such as `title` or `items.0.name`. |
| `FieldErrors` | no | Structured field errors with public path, lower-kebab code, and public-safe message. A path may appear only once across `Fields` and `FieldErrors`. |
| `RetryLabel`, `DismissLabel` | no | Visible labels for optional retry and dismiss controls. A control renders when its label or `ControlProps` is configured. |
| `Retry`, `Dismiss` | no | `ControlProps` carrying public action metadata for retry and dismiss controls. |

Provider modules own error meaning. Product modules project provider errors
into safe title, summary, code, status, request id, controls, and field
validation before rendering.

```go
package notesui

import "github.com/busdk/bus-ui/pkg/ui"

safeError := ui.ProviderErrorProps{
	Title:     "Could not save note",
	Summary:   "Check the title and try again.",
	Code:      "validation.failed",
	Status:    422,
	RequestID: "req_123",
	Fields: map[string]string{
		"title": "Title is required.",
	},
	RetryLabel: "Try again",
	Retry: ui.ControlProps{
		Action:   "provider.retry",
		SourceID: "note-save",
	},
}
```

This raw payload is rejected:

```go
unsafeError := ui.ProviderErrorProps{
	Title:   "SQL failed",
	Summary: "token=secret SELECT * FROM customers",
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

- [ProviderError](./provider-error-component)
- [Render tree contract](../v0.1.1/render-tree-contract)
- [bus-ui module reference](../../modules/bus-ui)
