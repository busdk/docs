---
title: bus-portal
description: Generic frontend portal host for Bus portal UI modules.
---

## Overview

`bus-portal` is being refactored into the generic modular frontend portal host
for `bus-portal-*` UI modules. The host owns frontend app serving, module
mounting, theme CSS variables, browser security headers, shared static assets,
and browser-facing configuration.

`bus-portal` does not own server-side Bus business logic. Auth, registration,
billing, LLM access, container lifecycle, terminal sessions, uploads,
accounting workspace reads, report generation, and artifact access must be
provided through `bus-api` / `bus-api-provider-*` HTTP APIs. Portal frontend
modules consume those APIs and must not call `bus-integration-*` workers.

The current built-in accounting customer view remains available during the
split. It opens a local customer view for the current BusDK workspace. The
page groups `Yleiskuva`, `Tilikartta`, `Aineisto`, and `Tilinpäätös` behind a
collapsible left sidebar and shows workspace business details, the full chart
of accounts, customer upload controls, and the latest evidence-pack outputs in
those separate views.

Portal modules are UI modules only. They use `bus-api-*` /
`bus-api-provider-*` APIs for backend behavior and must not integrate directly
with `bus-integration-*` workers.

Capability-token URLs are valid for local/development "secret URL" mode. In
that mode the full URL is intentionally shown to the user starting the service.
Public web deployments should use normal frontend routes plus API-provider
authentication/session handling instead of relying on secret URLs.

For publish-oriented frontend hosting before the legacy accounting routes are
fully migrated, run with `--disable-legacy-local-apis` or
`BUS_PORTAL_DISABLE_LEGACY_LOCAL_APIS=1`. This leaves frontend assets and
mounted modules available but returns 404 for temporary `/v1/demo*` and
`/v1/submissions*` routes.

Generated or customer-controlled artifacts should not be served directly from
the portal frontend host in public portal mode. Artifact metadata, previews,
and downloads should come from authenticated API/provider routes that enforce
the caller's account/workspace access.

The portal host is responsible for frontend-host security such as browser
security headers and safe theme CSS output. API authentication, authorization,
account isolation, session/CSRF checks, quota checks, and billing entitlement
decisions are API-provider responsibilities.

Themes are runtime configuration and may later be customized by end users with
AI assistance. Theme customization must use validated structured design tokens,
not raw CSS. Public deployments may also require JWT/session-protected frontend
modules or assets; that mode should use `bus-portal-auth` session/client
functionality while keeping sensitive data behind API providers.

Runtime theme files are validated before CSS variables are emitted. The host
rejects values that can break out of CSS declarations or load external
resources, including `url(...)`, `@import`, `expression(...)`, `javascript:`,
`data:`, and nested `var(...)` references.

While legacy local uploads remain, deployments must use explicit upload limits
for total request size, per-file size, aggregate uploaded bytes, and file count.
The public portal architecture should move uploads behind authenticated
provider APIs.

`bus-portal` now applies frontend security headers to index, static asset, API,
and mounted module responses. Configure extra API origins for CSP `connect-src`
with `--api-connect-src` or `BUS_PORTAL_API_CONNECT_SRC`.

Legacy upload limits are configurable with `--max-upload-request-bytes`,
`--max-upload-file-bytes`, `--max-upload-aggregate-bytes`,
`--max-upload-files`, and `--upload-memory-bytes`; matching environment
variables use the `BUS_PORTAL_*` names documented in the module README.
Set `BUS_PORTAL_DISABLE_LEGACY_LOCAL_APIS=1` or pass
`--disable-legacy-local-apis` for frontend-only publish deployments.

Legacy migration note: the current local accounting view still runs
`bus-reports evidence-pack`, stores uploads through `bus-attachments`, and
serves generated evidence artifacts directly. Treat this as temporary migration
debt while the accounting behavior moves to `bus-portal-accounting` and
provider-backed APIs. Active legacy artifact formats (`.html`, `.htm`, and
`.svg`) are forced to attachment downloads and rendered in previews only as
escaped text so generated/customer-controlled active content does not execute
in the portal origin.

### E2E Levels

`make test-e2e` in `bus-portal` runs fast smoke checks by default. The default
suite is for generic portal host behavior, safe theme loading, disabled legacy
local APIs, and mounted portal modules.

Browser, Docker image, and Docker Compose checks are intentionally opt-in
because they are much slower and validate runtime packaging rather than normal
source-level portal behavior:

```bash
RUN_BROWSER_E2E=1 make test-e2e
RUN_DOCKER_E2E=1 make test-e2e
E2E_SCOPE=full make test-e2e
```

Legacy local accounting route e2e scripts are not part of the `bus-portal`
suite. Accounting behavior belongs in `bus-api-provider-books` and
`bus-portal-accounting`.

### Sources

- [bus-portal module page](/Users/jhh/git/busdk/busdk/docs/docs/modules/bus-portal.md)
- [bus-portal README](/Users/jhh/git/busdk/busdk/bus-portal/README.md)
