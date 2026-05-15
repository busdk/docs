---
title: UI runtime errors
description: BusDK UI runtime error reporting and provider error projection.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Core foundation](../v0.1.1/foundation)

## Contract

Runtime errors flow through the versioned diagnostics contract. The diagnostic
channel accepts safe browser diagnostics such as component name, event name,
public error code, request ID, and redacted message. The reporter logs the
failure, presents safe visible state, and recovers panic payloads from Go
WebAssembly callbacks where possible.

Product modules should not copy local error banner markup or panic-recovery
wrappers.

Errors returned by providers should be projected into product view models
before rendering. Generic provider-error components may show a title, summary,
status, request ID, retry affordance, and public details such as field names or
validation codes. They must not show bearer tokens, raw provider payloads,
private customer data, stack traces, SQL, internal hostnames, or credential
headers.

## Consequence

Product modules decide which provider error fields are safe to expose.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core diagnostics](../v0.1.8/)
- ProviderError
