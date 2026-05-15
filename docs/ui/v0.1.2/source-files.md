---
title: GX source files
description: BusDK UI v0.1.2 .gx source file shape.
---

## Contract

A `.gx` file is a Go package source file with GX markup literals in ordinary Go
declarations, functions, or methods. The file keeps the Go package boundary, so
later generated Go, controller code, tests, and editor tooling can work with
the same package.

The preferred human-authored UI format is `.gx`, not a YAML or JSON component
tree. YAML and JSON remain useful later for fixture data and fixture bindings,
but template structure is written as HTML-like markup inside Go source.

The v0.1.2 parser preserves tag case and source locations. Lowercase tags
resolve to safe HTML element names from the [v0.1.1 element](../v0.1.1/element)
allowlist. Uppercase tags are recognized as component syntax so the linter can
report unsupported use clearly, but reusable component declarations and
registry resolution are introduced in a later patch.

The source language is constrained to safe structural markup and Go values. It
does not run browser JavaScript, shell commands, provider calls, or a separate
expression runtime.

## Minimal File

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

This version can format and lint the file. Rendering is introduced by the
compiler patch.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source tools](./source-tools)
- [Element node](../v0.1.1/element)
