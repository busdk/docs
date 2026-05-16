---
title: GX source files
description: BusDK UI v0.1.2 .gx source file shape.
---

## Contract

A `.gx` file is a Go package source file with GX markup literals in top-level
Go declarations. The file keeps the Go package boundary, so later generated
Go, tests, and editor tooling can work with the same package.

The preferred human-authored UI format is `.gx`, not a YAML or JSON component
tree. YAML and JSON remain data and configuration formats; template structure
is written as HTML-like markup inside Go source.

The v0.1.2 parser preserves tag case and source locations. Lowercase tags
resolve to safe HTML element names from the [v0.1.1 element](../v0.1.1/element)
allowlist. The built-in uppercase `Text` source primitive is allowed for text
content. Other uppercase tags are recognized as component syntax so the linter
can report unsupported use clearly.

The source language is constrained to safe structural markup and Go values. It
does not run browser JavaScript, shell commands, provider calls, or a separate
expression runtime.

Raw text inside markup is unsupported in v0.1.2. Use the `Text` source primitive
for text content so formatting cannot drop content accidentally.

## Minimal File

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

v0.1.2 can format and lint the file. It does not compile or render `.gx`
source.

This file is intentionally invalid in `v0.1.2`:

```gx
package notesui

var hello = <p>Hello Bus</p>
```

The source tools report a diagnostic that asks the author to use `Text`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source tools](./source-tools)
- [Element node](../v0.1.1/element)
