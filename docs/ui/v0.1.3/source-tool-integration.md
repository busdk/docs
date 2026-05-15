---
title: Source-tool integration
description: Required BusDK UI v0.1.3 source checks before compilation.
---

## Contract

`v0.1.3` compilation starts from a `.gx` file that already passes the
[v0.1.2 formatter](../v0.1.2/formatter) and
[v0.1.2 linter](../v0.1.2/linter). The compiler reuses the v0.1.2 parser and
diagnostic shape instead of defining another GX grammar.

Run source checks before compile:

```sh
bus-gx fmt --check hello.gx

bus-gx lint --format json hello.gx
```

`bus-gx compile` must stop on source diagnostics and must report the same file,
line, column, code, severity, and message shape as the source tools.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source files](../v0.1.2/source-files)
- [GX source diagnostics](../v0.1.2/diagnostics)
