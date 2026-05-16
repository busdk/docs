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

Request helpers apply bearer and CSRF behavior to approved requests. Bearer
behavior means setting `Authorization: Bearer <token>` on the private request
object passed to the resource client. CSRF behavior means setting the
host-approved CSRF header, such as `X-CSRF-Token`, on same-origin unsafe
methods. The values come from host-owned session helpers and are never exposed
to templates or component props. When a request is public, cross-origin without
allowlist approval, or outside the declared API routes, no credential is
attached and authorization returns an error.

Browser storage adapters may persist non-secret session markers or public
preferences, but token storage, cookie policy, login challenges, and credential
validation belong to the host and auth modules.

An approved request is same-origin or host-resolved by the portal/app host and
matches a declared API origin from host runtime config or the portal module
descriptor. Host-resolved means `Base` is a host-owned resolver such as
`uiresource.ModuleAPI` or `uiresource.PortalAPI`; the resolver supplies the
origin and path prefix. Requests pass only when the resolved origin is
same-origin or exactly allowlisted, the path starts with `/`, and the path does
not contain `..`. For example:

```go
request := uiresource.Request{
	Method: "POST",
	Base:   uiresource.ModuleAPI,
	Path:   "/v1/drafts",
}
authorized, err := session.Authorize(request)
```

`Authorize` applies bearer behavior only to approved API requests. It applies
CSRF behavior only to same-origin unsafe methods such as `POST`, `PUT`,
`PATCH`, and `DELETE`. External origins require an exact host allowlist entry;
credential-bearing URLs, wildcard origins, `javascript:`, `data:`, and `..`
paths are rejected before credentials are attached.

Navigation helpers return host route requests, not URLs with secrets:

```go
login := session.LoginRedirect("expired")
logout := session.LogoutRedirect()
expired := session.ExpiredRedirect()
```

Each value is a `uisession.NavigationRequest` with `Kind`, `Reason`, and
optional `ReturnPath`. The host decides the concrete login, logout, and
expired-session routes. `Kind` is one of `login`, `logout`, or `expired`.
`Reason` is lower-case kebab-case, such as `expired` or `missing-scope`.
`ReturnPath` is optional, same-origin, starts with `/`, and rejects `..`,
absolute URLs, protocol-relative URLs, and `javascript:` or `data:` schemes.

## Requirements

- Templates and component props receive safe session views, not raw tokens.
- Request helpers apply bearer or CSRF behavior only to approved same-origin
  or host-resolved requests.
- Browser storage is optional and fakeable in tests.
- Redirect helpers expose safe login, logout, and expired-session navigation
  requests without deciding host routes.
- `ErrExpired` maps to `SessionExpired`, `ErrMissingScope` maps to
  `AccessDenied`, and request-helper failures map to `ProviderError` with
  public status and request id fields only.

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

- [Browser storage adapter](../v0.1.16/browser-storage)
- [Action primitives](../v0.1.22/action-primitives)
- [Resource primitives](../v0.1.23/resource-primitives)
