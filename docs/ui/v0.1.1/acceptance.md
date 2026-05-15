---
title: Core node acceptance
description: BusDK UI v0.1.1 implementation and verification contract.
---

## Purpose

This patch is complete when the `bus-gx` module exposes the library-only
[Core foundation](./foundation) through `github.com/busdk/bus-gx/pkg/gx` and
the module checks prove the public contract.

## Files

The patch initializes these public implementation files:

| Path | Purpose |
| --- | --- |
| `go.mod` | Go module `github.com/busdk/bus-gx`. |
| `pkg/gx/node.go` | [Node](./node), shared interfaces, [VNode](./v-node), and constructors. |
| `pkg/gx/props.go` | [Props](./props) validation and deterministic attribute rendering. |
| `pkg/gx/render.go` | Deterministic escaped HTML renderer. |
| `pkg/gx/validate.go` | Strict node, tag, and child validation. |
| `pkg/gx/gx_test.go` | Unit tests for the v0.1.1 public contract. |
| `tests/e2e.sh` | Module e2e smoke for the library-only renderer. |

## Checks

Run the checks from the `bus-gx` module root:

```sh
make fmt
make test
make lint
make check
```

`make check` formats, vets, lints, runs package tests, builds the library-only
module, and runs the e2e smoke. A successful library build prints that there is
no `cmd/bus-gx/main.go`; that is expected in this version because no `bus gx`
CLI exists yet.

Unit tests must cover escaped text, deterministic attribute order, boolean
attributes, omitted false/null props, invalid attributes, invalid tags, invalid
prop values, strict kind-specific [VNode](./v-node) validation, nil inputs,
defensive VNode copies, fragment rendering, the [Renderer](./interfaces)
interface, and the default `RenderHTML` function.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./foundation)
- [Shared interfaces](./interfaces)
- [Node concept](./node)
- [Props reference](./props)
