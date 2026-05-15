---
title: Static render
description: BusDK UI v0.1.3 static HTML render check.
---

## Contract

`bus gx render` renders one compiled [template entry](./template-entries) to
deterministic escaped HTML using the [v0.1.1 renderer](../v0.1.1/interfaces).

Usage:

```sh
bus gx render <file.gx> --entry <name> --format html
```

`<file.gx>` is the checked GX source file. `<name>` is a package-local
[template entry](./template-entries) declared in that file.

`--format html` is the only output format in this patch. The command writes
HTML to stdout and diagnostics to stderr. Unknown entries, invalid source, and
unsupported output formats exit non-zero.

## Boundary

Static render does not load model data, binding files, controller code, runtime
fixtures, browser APIs, or host resources. It checks that a compiled static GX
entry can produce deterministic Core HTML.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Generated Go](./generated-go)
- [Shared interfaces](../v0.1.1/interfaces)
