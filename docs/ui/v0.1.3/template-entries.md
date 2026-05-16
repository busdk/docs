---
title: Template entries
description: BusDK UI v0.1.3 named template entry contract.
---

## Contract

A template entry is a top-level Go declaration in a `.gx` file whose value is a
GX markup literal. The entry name is the Go identifier on that declaration.

Example:

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

The entry name is `hello`.

`v0.1.3` entries may contain lowercase
[safe element tags](../v0.1.1/element), attributes accepted by the
[v0.1.2 linter](../v0.1.2/linter), nested markup, and the built-in `Text`
source primitive with a quoted or braced value. Entry lookup is case-sensitive
and package-local. Duplicate names are rejected by the source linter before
compile.

Entries that require function component resolution are rejected in this patch:

```gx
package notesui

var card = <Card></Card>
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source files](../v0.1.2/source-files)
- [Compile command](./compile-command)
