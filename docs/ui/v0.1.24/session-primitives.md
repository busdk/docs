---
title: Session primitives
description: BusDK UI v0.1.24 safe session views and request helpers for GX apps.
---

## Contract

`v0.1.24` adds session primitives for Go/WASM GX apps. A session value exposes
safe public identity, expiry, scopes, and request helpers without exposing raw
tokens to templates or component props.

```gx
type SessionView struct {
	UserID      string
	DisplayName string
	Scopes      []string
	ExpiresAt   time.Time
}

func Drafts(session uisession.Session) gx.Node {
	view := session.View()
	return <p><Text value={view.DisplayName}></Text></p>
}
```

Request helpers apply bearer and CSRF behavior to approved requests. Browser
storage adapters may persist non-secret session markers or public preferences,
but token storage, cookie policy, login challenges, and credential validation
belong to the host and auth modules.

## Requirements

- Templates and component props receive safe session views, not raw tokens.
- Request helpers apply bearer or CSRF behavior only to approved same-origin
  or host-resolved requests.
- Browser storage is optional and fakeable in tests.
- Redirect helpers expose safe login, logout, and expired-session navigation
  requests without deciding host routes.
- Session errors map to action/resource result states.

## Boundary

This patch does not implement login screens, token minting, credential checks,
security headers, or portal routing. It gives runtime components a safe way to
consume host session behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Minimal browser adapters](../v0.1.16/minimal-browser-adapters)
- [Action primitives](../v0.1.22/action-primitives)
- [Resource primitives](../v0.1.23/resource-primitives)
