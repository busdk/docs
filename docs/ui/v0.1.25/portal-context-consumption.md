---
title: Portal context consumption
description: BusDK UI v0.1.25 small Bus UI interfaces for host-provided portal context.
---

## Contract

`v0.1.25` defines how reusable `bus-ui` runtime packages consume portal host
context. `bus-portal` owns creation, validation, routing, security headers,
module handoff, and asset delivery. `bus-ui` accepts the resulting context
through small Go interfaces and uses it to resolve paths, assets, runtime
config, session helpers, and logging callbacks.

```go
type HostContext interface {
	ModuleBase() string
	AssetBase() string
	APIBase() string
	RuntimeConfig() PublicRuntimeConfig
	Session() uisession.Session
	Logger() uilog.Logger
}
```

Components should receive only the context fields they use. Runtime helpers can
depend on a small interface such as `PathResolver`, `AssetResolver`,
`SessionProvider`, or `PublicConfigProvider` instead of accepting the full host
object everywhere.

## Requirements

- `bus-ui` consumes host context but does not create or validate portal module
  registrations.
- Base paths and asset URLs are same-origin or host-approved.
- Public runtime config rejects sensitive-looking keys before rendering.
- Session helpers come from [v0.1.24](../v0.1.24/session-primitives).
- Resource helpers come from [v0.1.23](../v0.1.23/resource-primitives).
- Logging callbacks accept redacted framework and provider-safe errors only.

## Boundary

This patch does not move portal routing, module discovery, security headers,
tenant authorization, or product provider policy into `bus-ui`. It only gives
Bus UI packages a stable way to consume context supplied by the portal host.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Action primitives](../v0.1.22/action-primitives)
- [Resource primitives](../v0.1.23/resource-primitives)
- [Session primitives](../v0.1.24/session-primitives)
- [bus-portal module reference](../../modules/bus-portal)
