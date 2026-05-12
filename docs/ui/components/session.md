---
title: Session UI runtime block
description: Dedicated BusDK UI reference for Session.
---

## Purpose

`Session` is an action/resource/effect runtime block. Safe browser session view. Use for frontend session display. Request headers are derived by the host API client from its private session store, not from values rendered by this component.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `authenticated` | yes | boolean | `true` renders authenticated session state; `false` renders signed-out/limited state. Unauthenticated sessions are allowed for public or pre-auth pages. |
| `identityLabel` | no | string | Safe display name. Missing or empty identity while `authenticated: true` renders a generic authenticated label rather than failing. |
| `expiresAt` | no | RFC 3339 timestamp | Expiry display in UTC or explicit offset, for example `2026-05-11T10:30:00Z`. Expired values render expired/refresh-needed state; invalid timestamps fail validation. |
| `scopes` | no | string array | Display-only safe scope labels. They help users understand the current session but do not grant authorization; permission checks happen in the host/API layer. |

## Boundary

Secrets and raw tokens are not rendered. Do not use `Session` props to carry
authorization headers; the host API client attaches credentials outside the UI
tree.

## Example

```yaml
kind: Session
props:
  authenticated: true
  identityLabel: reviewer@example.com
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./apiurl-resolver">APIURLResolver</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./action">Action</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
