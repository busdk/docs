---
title: UI browser API boundaries
description: BusDK UI browser API isolation, JavaScript boundaries, and streaming ownership.
---

## Contract

Browser-only behavior should be isolated behind small helpers. This includes
DOM selection, click binding, file drop access, multipart upload, beforeunload
close guards, resize tracking, local storage access, current location parsing,
client logging, and app-style browser opening.

When a helper needs JavaScript because the browser API requires it, expose a
Go-facing API and keep product modules in Go.

Product modules should not expose global `window.<Module>` facades. If a
browser API requires JavaScript, keep it in a framework-owned helper with
content-security-policy-safe loading, no secrets in DOM data, and a Go-facing
API.

A product module may add local JavaScript only for a documented browser API
that has no `bus-gx` runtime helper yet. The product page must name the API,
explain why the helper is missing, cover the behavior with unit tests and a
browser e2e check, and keep provider credentials outside scripts, markup,
fixture data, bundles, and client-visible runtime config.

Streaming readers need the same ownership discipline. Provider event streams
and SSE-like flows should expose explicit abort handles, disposer cleanup,
typed parsers, and pure parser tests for chunk boundaries, malformed payloads,
provider errors, and user-initiated abort.

## Consequence

Local hand-written JavaScript in a product module usually means a reusable
helper is missing.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Effect UI concept](../v0.1.7/effect)
- [Core diagnostics](../v0.1.8/)
