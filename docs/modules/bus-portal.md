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
bus portal serve --print-url --experimental --enable-module ai
```

The portal host is frontend infrastructure. Server-side behavior such as
registration, billing, LLM access, container lifecycle, terminal sessions,
workspace reads, uploads, report generation, and artifact access is provided by
Bus API providers. Portal modules call those APIs from the browser; they do
not call backend integration workers directly.

In local mode, the server prints a capability URL containing a random token.
Opening that URL gives access to the local portal session. Use `--print-url`
for scripts or terminals, or the default webview behavior for local desktop
use. Hosted deployments normally place `bus-portal` behind the deployment's
normal public route and rely on API-provider authentication for protected
data.

The host applies a Content Security Policy, `Referrer-Policy: no-referrer`,
`X-Content-Type-Options: nosniff`, frame restrictions, and a restrictive
permissions policy. Add API origins to CSP `connect-src` with
`--api-connect-src <source>` or `BUS_PORTAL_API_CONNECT_SRC`.

Themes are runtime configuration. A theme file contains validated design tokens
that become CSS variables. The host rejects values that can break out of CSS
declarations or load external resources, including `url(...)`, `@import`,
`expression(...)`, `javascript:`, `data:`, and nested `var(...)` references.

Local workspace upload routes are protected by configurable limits for total
request size, per-file size, aggregate uploaded bytes, file count, and
multipart memory. Configure them with `--max-upload-request-bytes`,
`--max-upload-file-bytes`, `--max-upload-aggregate-bytes`,
`--max-upload-files`, and `--upload-memory-bytes`, or the matching
`BUS_PORTAL_*` environment variables. Public frontend-only deployments can
disable local workspace APIs with `--disable-legacy-local-apis` or
`BUS_PORTAL_DISABLE_LEGACY_LOCAL_APIS=1`.

### Sources

- [bus-portal-auth](./bus-portal-auth)
- [bus-portal-ai](./bus-portal-ai)
- [bus-portal-accounting](./bus-portal-accounting)
