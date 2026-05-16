---
title: Streaming and terminal ownership
description: BusDK UI v0.1.26 ownership boundaries for stream helpers and terminal UI libraries.
---

## Contract

`v0.1.26` separates reusable stream lifecycle helpers from higher-level
terminal UI. The minimal GX framework/runtime packages inside `bus-ui` may own
generic stream readers, abort handling, effect cleanup integration, and
test fakes. A separate terminal UI library inside the same `bus-ui` Bus module
may own terminal viewport components, stdin controls, resize handling, command
session state, and terminal-specific cleanup.

Reusable non-UI transport clients, protocol parsers, retry policy, and
API-specific terminal protocols belong in separate packages when they are
useful outside browser UI.

```go
stream := uistream.UseStream(uiresource.StreamRequest{
	Path: "/v1/terminal/events",
})

return TerminalViewport(TerminalViewportProps{
	Chunks: stream.Chunks(),
	Error:  stream.Error(),
})
```

The stream helper owns cancellation, reader cleanup, backpressure signals, and
render scheduling. The terminal library owns how chunks, input, approvals, and
resize state are rendered.

## Requirements

- Stream readers use the resource and effect primitives from earlier patches.
- Abort closes the network reader and runs effect cleanup.
- Stream state is testable with fake readers and deterministic chunks.
- Terminal UI does not force terminal protocol concepts into the minimal
  runtime packages.
- Embedded JavaScript clients are replaced by Go/WASM adapters except for
  narrow browser API boundaries.

## Boundary

This patch does not define terminal components, assistant event schemas,
provider command APIs, or portal terminal routes. Those concerns can use this
ownership boundary without changing the minimal runtime.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Effect runtime](../v0.1.18/effect-runtime)
- [Resource primitives](../v0.1.23/resource-primitives)
- [Portal context consumption](../v0.1.25/portal-context-consumption)
