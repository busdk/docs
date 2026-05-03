---
title: bus-portal
description: Generic frontend portal host for Bus portal UI modules.
---

## Overview

`bus-portal` serves the Bus web portal shell. It hosts browser UI modules,
serves shared frontend assets, applies the portal theme, and sets browser
security headers for the app surface. Operators use it when they want a local
or hosted browser entry point for Bus account, AI, accounting, and other portal
modules.

Portal modules are mounted explicitly. With no module flags, the portal starts
with the default module set. Add modules with `--enable-module <id>`; repeat
the flag to mount several modules. `--enable-module all` selects all modules
that are available without the extra `--experimental` opt-in.

```bash
bus portal serve --print-url
bus portal serve --print-url --enable-module auth
bus portal serve --print-url --enable-module ai
```

The portal host is frontend infrastructure. Server-side behavior such as
registration, billing, LLM access, container lifecycle, terminal sessions,
workspace reads, uploads, report generation, and artifact access is provided by
Bus API providers. Portal modules call those APIs from the browser; they do
not call backend integration workers directly.

For an end-user AI services portal, enable the auth and AI portal modules and
provide browser-reachable API base URLs for auth, billing, LLM, containers, and
terminal APIs. Users register and log in through the auth module, complete
billing through the billing API, and then use chat or container-backed terminal
features through the AI module.

When those APIs are on one gateway origin, allow that origin in the portal CSP
and enable the modules explicitly:

```sh
bus portal serve --print-url \
  --enable-module auth \
  --enable-module ai \
  --api-connect-src https://api.example.test
```

The gateway should route the browser-facing API paths used by the modules, such
as `/api/v1/auth/*`, `/api/v1/billing/*`, `/v1/*`,
`/api/v1/containers/*`, and terminal API paths. The equivalent environment
setting for CSP is `BUS_PORTAL_API_CONNECT_SRC=https://api.example.test`. When
the portal and APIs share the same origin through a reverse proxy, no separate
module URL attributes are required.

In local mode, the server prints a capability URL containing a random token.
Opening that URL gives access to the local portal session. Use `--print-url`
for scripts or terminals, or the default webview behavior for local desktop
use. Hosted deployments normally place `bus-portal` behind the deployment's
normal public route and rely on API-provider authentication for protected
data.

### Protected Frontend Mode

`bus-portal` can require a frontend JWT before it serves portal assets and
mounted modules. This is useful when the frontend itself should not be public,
for example for private customer portals or operator-only deployments.

Enable it with `--require-frontend-auth` and provide the signing secret through
`--frontend-auth-secret-file <path>` or `BUS_PORTAL_FRONTEND_AUTH_SECRET`.
The secret file takes precedence when both are set.

```bash
bus portal serve --print-url \
  --require-frontend-auth \
  --frontend-auth-secret-file /run/secrets/bus-portal-frontend-jwt
```

The portal accepts the JWT from `Authorization: Bearer ...` or from the
configured cookie. Defaults are audience `ai.hg.fi/api`, scope `portal:read`,
and cookie name `bus_portal_token`. Override them with
`--frontend-auth-audience`, `--frontend-auth-scope`, and
`--frontend-auth-cookie`.

Frontend tokens use HS256 with the configured secret. They must include `sub`,
`aud`, `scope`, `iat`, and `exp`. The configured scope is represented inside
the space-separated `scope` claim, for example `"scope":"portal:read"`.

For a local protected-frontend check, create a short-lived JWT with the same
HS256 secret and pass it as either a bearer token or the configured cookie:

```sh
mkdir -p ./local
printf '%s' 'local-portal-secret' > ./local/portal-frontend.secret
BUS_AUTH_HS256_SECRET=local-portal-secret \
bus operator token --format token issue --local \
  --subject portal-user \
  --audience ai.hg.fi/api \
  --scope portal:read \
  --ttl 1h > ./local/portal-frontend.jwt

bus portal serve --print-url \
  --require-frontend-auth \
  --frontend-auth-secret-file ./local/portal-frontend.secret

curl -fsS -H "Authorization: Bearer $(cat ./local/portal-frontend.jwt)" \
  http://127.0.0.1:<port>/<token>/
```

Run the `bus portal serve` command in one terminal and the `curl` command in a
second terminal, using the URL printed by the server.
For browser testing, set cookie `bus_portal_token` to the same JWT unless the
deployment overrides the cookie name with `--frontend-auth-cookie`.

Protected frontend mode only controls delivery of the browser app. The API
providers still enforce account ownership, feature scopes, billing state,
quota limits, and all business authorization.

The host applies a Content Security Policy, `Referrer-Policy: no-referrer`,
`X-Content-Type-Options: nosniff`, frame restrictions, and a restrictive
permissions policy. Add API origins to CSP `connect-src` with
`--api-connect-src <source>` or `BUS_PORTAL_API_CONNECT_SRC`.

Themes are runtime configuration. A theme file contains validated design tokens
that become CSS variables. The host rejects values that can break out of CSS
declarations or load external resources, including `url(...)`, `@import`,
`expression(...)`, `javascript:`, `data:`, and nested `var(...)` references.

`bus-portal` does not serve upload, report-generation, accounting-data, or
artifact APIs. Those routes belong to authenticated Bus API providers. Portal
modules should render provider-returned links for previews and downloads
rather than exposing local files from the portal host.

### Module Configuration

`bus-portal-auth` provides registration, OTP login, logout, session discovery,
and account status UI. It calls `bus-api-provider-auth`.

`bus-portal-ai` provides chat, billing prompts, container session controls, and
terminal entry points. It calls `bus-api-provider-billing`,
`bus-api-provider-llm`, `bus-api-provider-containers`, and
`bus-api-provider-terminal`.

Portal modules should receive API base URLs through runtime configuration or
deployment HTML data attributes. The portal host does not embed payment
provider secrets, API tokens, database credentials, or integration worker
credentials.

### Local Compose Stack

The BusDK superproject `compose.yaml` starts `bus-portal` behind nginx at
`/portal/local-dev/`. The compose command enables the auth, AI, and accounting
portal modules, opts into experimental modules, and sets
`BUS_PORTAL_API_CONNECT_SRC` to the local API gateway origin. The local stack
uses a stable portal capability token only inside the private compose network;
browser API calls still go to the JWT-secured auth, billing, LLM, VM, and
container provider routes exposed by nginx.

### Deployment Notes

Use HTTPS for hosted deployments. Configure CSP `connect-src` for every API
origin the browser needs. Keep browser session state short-lived and rely on
API-provider JWT validation and scope checks for protected data.

Do not put payment provider secrets, database credentials, API keys, or worker
credentials into portal frontend configuration. Browser code should receive
only public API base URLs and short-lived user/session credentials.

### Sources

- [bus-portal-auth](./bus-portal-auth)
- [bus-portal-ai](./bus-portal-ai)
- [bus-portal-accounting](./bus-portal-accounting)
