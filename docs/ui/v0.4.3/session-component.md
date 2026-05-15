---
title: Session UI runtime block
description: Dedicated BusDK UI reference for Session.
---

## Purpose

`Session` is an event/resource/effect runtime block. Safe browser session view. Use for frontend session display. Request headers are derived by the host API client from its private session store, not from values rendered by this component.

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
  identityLabel: user@example.com
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
