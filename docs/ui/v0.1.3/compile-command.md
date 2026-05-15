---
title: Compile command
description: BusDK UI v0.1.3 bus-gx compile command contract.
---

## Contract

`bus-gx compile` lowers `.gx` source into generated Go without rendering it.

Usage:

```sh
bus-gx compile <file.gx> --output <file_gx.go>
```

The command accepts one explicit `.gx` input file and one explicit output path.
It exits `0` after writing canonical generated Go. It exits non-zero without
writing output when source parsing, linting, or generation fails.

The module binary may also accept `bus-gx gx compile` as a local alias for the
same command shape.

## Boundary

The compiler does not read data, bindings, runtime config, controllers, custom
component registries, browser state, or host resources.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Source-tool integration](./source-tool-integration)
- [Generated Go](./generated-go)
