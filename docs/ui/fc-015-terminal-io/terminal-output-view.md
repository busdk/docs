---
title: TerminalOutputView UI component
description: Dedicated BusDK UI reference for TerminalOutputView.
---

## Purpose

`TerminalOutputView` is a terminal component. Streamed output view. Use inside terminal or log surfaces.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `chunks` | yes | `[]TerminalOutputChunk` | Output chunks in display order. Each chunk requires non-empty `Text`. `Stream` is optional and defaults to `system`; when present it accepts `stdout`, `stderr`, `stdin`, `system`, or aliases normalized below. Optional `Sequence` is `*int`; when present it must be non-negative and unique. When any chunk has `Sequence`, all chunks must have `Sequence` and the slice must already be sorted by ascending sequence. The component validates order but does not reorder. Missing text, invalid stream values, duplicate sequence values, mixed sequence presence, or descending sequence order fail validation before render. |
| `emptyText` | no | string | Shown when `chunks` is empty. Defaults to no visible empty text. Empty string is allowed and renders no text. |

## Boundary

Stream labels are normalized before display: `out` and `standard-output` become
`stdout`; `err` and `standard-error` become `stderr`; `input` becomes `stdin`;
unknown stream labels fail validation before render.

## Example

```gx
var seq1 = 1
var seq2 = 2

var terminalOutput = []TerminalOutputChunk{
  {Stream: "stdout", Text: "build started", Sequence: &seq1},
  {Stream: "stderr", Text: "warning: retrying", Sequence: &seq2},
}

var outputView = <TerminalOutputView
    chunks={terminalOutput}
    emptyText="No output yet">
</TerminalOutputView>
```

```go
type TerminalOutputChunk struct {
	Stream   string
	Text     string
	Sequence *int
}
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
