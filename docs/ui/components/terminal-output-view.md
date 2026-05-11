---
title: TerminalOutputView UI component
description: Dedicated BusDK UI reference for TerminalOutputView.
---

## Purpose

`TerminalOutputView` is a terminal component. Streamed output view. Use inside terminal or log surfaces.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `chunks` | yes | array of `{stream,text,sequence}` | Output chunks in display order. `stream` accepts `stdout`, `stderr`, `stdin`, `system`, or aliases normalized below; `text` is raw terminal text escaped by the component before rendering; optional `sequence` is a monotonically increasing number used to stabilize ordering when chunks arrive out of order. |
| `emptyText` | no | string | Shown when `chunks` is empty. Defaults to no visible empty text. Empty string is allowed and renders no text. |

## Boundary

Stream labels are normalized before display: `out` and `standard-output` become
`stdout`; `err` and `standard-error` become `stderr`; `input` becomes `stdin`;
unknown stream labels become `system` and are reported through diagnostics.

## Example

```yaml
kind: TerminalOutputView
props:
  chunks: { bind: terminal.output }
  emptyText: No output yet
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./terminal-session-panel">TerminalSessionPanel</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./terminal-input-box">TerminalInputBox</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
