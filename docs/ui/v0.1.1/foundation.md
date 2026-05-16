---
title: Core foundation
description: BusDK UI core foundation concept map.
---

## Initial Patch

`v0.1.1` is the first `bus-gx` patch. It is only the deterministic
[render tree](./node), with enough structure to represent safe static HTML and
prove the renderer contract:

1. [Node](./node)
2. [Shared interfaces](./interfaces)
3. [VNode](./v-node)
4. [Text](./text)
5. [Element](./element)
6. [Fragment](./fragment)
7. [Props](./props)

[Shared interfaces](./interfaces) define how Go values become normalized
[VNode](./v-node) trees and deterministic HTML. [Text](./text) always escapes.
[Element](./element) accepts lowercase HTML-compatible names from the
[Element allowlist](./element).
[Fragment](./fragment) groups children without adding output. [Props](./props)
serializes attributes in stable order and rejects unsafe names and values.
[VNode](./v-node) is the shared immutable node shape passed to renderers and
tests.

## Ownership

`bus-gx` owns the low-level Core in this patch: nodes, props, escaped text,
safe lowercase elements, fragments, validation, deterministic rendering, and
tests for those contracts. This patch does not initialize `bus-ui`, a portal
host, product feature modules, providers, controller code, browser behavior, or
library components.

Provider/API modules own authorization, persistence, validation, and domain
operations. Product feature modules own screen-ready labels, permissions
display, disabled reasons, selected-row state, safe links, workflow copy, and
other product-specific view-model projection. Reusable low-level behavior only
moves into `bus-gx` when it is needed to build framework pieces across
products.

## Module Initialization

This version initializes the `bus-gx` submodule as Go library code, not as a CLI
tool. The module should contain normal BusDK Go development infrastructure:
`go.mod`, a module `Makefile`, package tests, formatting and lint targets, a
short `README.md`, and a `PLAN.md` that tracks the next implementation work.

The public library package is `pkg/gx`. It defines the data structures,
shared interfaces, constructors, validation, and deterministic HTML rendering
needed by the pages in this version. The package API should be small enough that
`bus-ui` can import it to build higher-level components without depending on
any command-line tooling.

[Core node acceptance](./acceptance) defines the concrete module files and
checks that prove this patch.

No `bus gx` command is required in this version. Source parsing, `.gx` files,
`bus gx fmt`, `bus gx lint`, compilation, component calls, composition,
controllers, events, lifecycle hooks, browser hydration, and generated Go
output are outside this version. The module still has ordinary Go formatting
and lint targets for the library code initialized in this patch.

## Composition Rule

Code in this iteration should stay limited to nodes, props, escaped text, safe
elements, fragments, deterministic rendering, and focused tests for those
contracts.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node concept](./node)
- [Shared interfaces](./interfaces)
- [VNode](./v-node)
- [Text](./text)
- [Element](./element)
- [Fragment](./fragment)
- [Props](./props)
- [Core node acceptance](./acceptance)
