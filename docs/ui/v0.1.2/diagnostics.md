---
title: GX source diagnostics
description: BusDK UI v0.1.2 source diagnostic shape.
---

## Shape

Diagnostics include `file`, `line`, `column`, `endLine`, `endColumn`, `code`,
`severity`, `message`, and optional `fix` fields. A fix contains a replacement
range and replacement text.

Fixes must be small, deterministic, and safe to apply independently.
Formatting-only fixes belong to [`bus gx fmt`](./formatter).

## Coordinates

Diagnostic positions are 1-based UTF-8 source coordinates. `line` and `column`
point at the first byte of the diagnostic range. `endLine` and `endColumn` are
exclusive: they point immediately after the last byte in the range.

A diagnostic covering one character at line 3, column 5 ends at line 3,
column 6.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX formatter](./formatter)
- [GX linter](./linter)
