---
title: GX source tools
description: BusDK UI v0.1.2 source tool patch overview.
---

## Purpose

`v0.1.2` adds the first `.gx` source toolchain on top of the `v0.1.1` node
foundation. It introduces the `bus gx fmt` and `bus gx lint` command surface
and the parser support those commands need. The module binary also accepts
`gx fmt` and `gx lint` aliases after the binary name for module-local tests.

This patch is source-only. It validates and normalizes `.gx` files before the
compiler exists. It does not render templates, compile generated Go, resolve
custom component functions, load data, evaluate runtime values, run controllers, or
mount browser UI.

## Deliverables

1. Define the [.gx source file shape](./source-files).
2. Provide deterministic [formatting](./formatter).
3. Provide source-only [linting](./linter).
4. Emit stable [diagnostics](./diagnostics) for humans and agents.
5. Define the public [acceptance checks](./acceptance) for this patch.

## Result

After this patch, authors can create a `.gx` file, canonicalize it, and get
source diagnostics before any later render or runtime work exists.

The public module result is:

```sh
bus gx fmt --check hello.gx

bus gx lint --format json hello.gx
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node concept](../v0.1.1/node)
- [Shared interfaces](../v0.1.1/interfaces)
