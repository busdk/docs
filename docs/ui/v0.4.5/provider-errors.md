---
title: Library provider errors
description: BusDK UI library safe provider failure display contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`ProviderError`](../v0.4.5/provider-error-component) renders public-safe provider
failure display. Request id, status, retry event, and validation fields are
optional. Raw payloads, tokens, SQL, stack traces, and private customer data
fail validation.

| Field | Required | Behavior |
| --- | --- | --- |
| `title` | yes | Public-safe string shown as the error heading. |
| `message` | no | Public-safe string; omitted when no user action is available. |
| `code` | no | Public provider/application error code string; omitted when unavailable. |
| `status` | no | HTTP or provider status code as string or number. |
| `requestID` | no | Public support identifier. |
| `retry` | no | Runtime event name for retry control. |
| `fields` | no | Map of field name to public-safe validation string. |

Missing `title` or unsafe text fails validation before render.

Provider modules own error meaning. Product modules project provider errors
into safe title, message, code, request id, retry state, and field validation
before rendering.

```yaml
title: Could not save note
message: Check the title and try again.
status: 422
requestID: req_123
fields:
  title: Title is required.
```

This raw payload is rejected:

```yaml
title: SQL failed
message: "token=secret SELECT * FROM customers"
```

## Consequence

Users see actionable errors without exposing provider internals or credentials.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [ProviderError](../v0.4.5/provider-error-component)
- [Render tree contract](../v0.1.1/render-tree-contract)
