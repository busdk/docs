---
title: TerminalOutputView UI component
description: Dedicated BusDK UI reference for TerminalOutputView.
---

## Purpose

`TerminalOutputView` is a terminal component. Streamed output view. Use inside terminal or log surfaces.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `chunks` | yes | array of `{stream,text,sequence}` | Output chunks in display order. Each chunk requires non-empty string `text`. `stream` is optional and defaults to `system`; when present it accepts `stdout`, `stderr`, `stdin`, `system`, or aliases normalized below. Optional `sequence` must be a number and is used to stabilize ordering when chunks arrive out of order. Missing text, non-string text, or non-numeric sequence values fail validation. |
| `emptyText` | no | string | Shown when `chunks` is empty. Defaults to no visible empty text. Empty string is allowed and renders no text. |

## Boundary

Stream labels are normalized before display: `out` and `standard-output` become
`stdout`; `err` and `standard-error` become `stderr`; `input` becomes `stdin`;
unknown stream labels become `system` and are reported through diagnostics.

## Example

```yaml
kind: TerminalOutputView
props:
  chunks:
    bind: terminal.output
  emptyText: No output yet
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
