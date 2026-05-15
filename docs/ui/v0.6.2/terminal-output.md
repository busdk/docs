---
title: Library terminal output
description: BusDK UI library terminal output rendering contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Binding](../v0.1.5/binding)

## Contract

[`TerminalOutputView`](./terminal-output-view) renders ordered
output chunks with required `text`, optional `stream`, and optional numeric
`sequence`. Output text is escaped. Missing output stream defaults to `stdout`.
Supported streams are `stdout`, `stderr`, `stdin`, and `system`; unknown
streams fail validation before render.

Chunks render in array order. When `sequence` is present, every chunk in the
array must have a unique monotonic integer sequence and the array must already
be sorted by it; the component validates order but does not reorder. The
controller owns chunk ordering, truncation, redaction, and retention.

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
