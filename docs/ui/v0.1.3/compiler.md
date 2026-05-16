---
title: GX compiler
description: BusDK UI v0.1.3 compiler patch overview.
---

## Purpose

`v0.1.3` turns source-checked `.gx` files into pure `.go` files. It builds on the
[v0.1.2 GX source tools](../v0.1.2/) and the [v0.1.1 node
interfaces](../v0.1.1/interfaces).

## Deliverables

1. Reuse the [source-tool checks](./source-tool-integration) before compile.
2. Add the [`bus gx compile`](./compile-command) command.
3. Define the [generated Go](./generated-go) artifact shape.
4. Define [template entries](./template-entries).
5. Define [acceptance checks](./acceptance) for compiler output.

## Boundary

This patch compiles static top-level template entries only. It does not lower
component function bodies, load data, read runtime data files, run controllers,
resolve custom component registries, execute events, mount browser UI, or
provide lifecycle behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node concept](../v0.1.1/node)
- [v0.1.2 GX source tools](../v0.1.2/)
