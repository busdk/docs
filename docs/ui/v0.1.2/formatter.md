---
title: GX formatter
description: BusDK UI v0.1.2 bus gx fmt command contract.
---

## Contract

`bus gx fmt` canonicalizes `.gx` source files without changing their meaning.
It owns whitespace, indentation, markup literal layout, attribute ordering in
source where ordering is semantically irrelevant, and stable newline behavior.

`bus gx fmt --check` verifies that files are already canonical and does not
write files. It exits `0` when every checked file is canonical and `1` when any
file would change.

`bus gx fmt` exits `0` after a successful rewrite. It exits non-zero when
parsing fails before any file is rewritten.

Module-local tests may call `./bin/bus-gx gx fmt` after `make build`, but
user-facing commands go through the `bus` dispatcher.

## Example

```sh
bus gx fmt --check hello.gx

bus gx fmt hello.gx
```

The formatter reports parse diagnostics using the shared
[diagnostic shape](./diagnostics). Formatting-only changes belong to
`bus gx fmt`, not to linter fixes.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source files](./source-files)
- [GX diagnostics](./diagnostics)
