---
title: Library terminal output
description: BusDK UI library terminal output rendering contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Expression children](../v0.1.5/expression-children)

## Contract

[`TerminalOutputView`](./terminal-output-view) renders ordered
output chunks with required `text`, optional `stream`, and optional numeric
`sequence`. Output text is escaped. Missing output stream defaults to `stdout`.
Supported streams are `stdout`, `stderr`, `stdin`, and `system`; unknown
streams fail validation before render.

Chunks render in array order. When `Sequence` is present, every chunk in the
slice must have a unique monotonic integer sequence and the slice must already
be sorted by it; the component validates order but does not reorder. The
component caller owns chunk ordering, truncation, redaction, and retention
through ordinary Go state and callbacks in the [UI runtime contract](../v0.4.1/runtime-contract).

## Consequence

Terminal output rendering stays deterministic and safe.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [TerminalOutputView](./terminal-output-view)
- [Render tree contract](../v0.1.1/render-tree-contract)
