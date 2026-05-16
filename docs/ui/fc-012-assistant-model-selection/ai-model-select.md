---
title: AIModelSelect UI component
description: Dedicated BusDK UI reference for AIModelSelect.
---

## Purpose

`AIModelSelect` is an assistant component. Assistant model picker. Use when model choice is visible.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended | string | Stable selector id included in `AIModelChangeEvent.SourceID`. If omitted, the renderer-generated tree path identifies the selector. |
| `current` | yes | string | Current model id. Must equal an `options[].id` or render with `fallback`. |
| `options` | yes | `[]AIModelOption` | `ID` is required; `Label` defaults to `ID`; disabled choices render but cannot be selected, and `Reason` is required when `Disabled` is true. |
| `onChange` | yes | `func(AIModelChangeEvent) gx.Result` | Runs when model selection changes. The event includes `SourceID` and `ModelID`; `AIModelSelect` stores nothing itself, so the caller must validate and persist the selected `ModelID`. |
| `fallback` | no | string | Display label for unavailable `current`; default is `current`. |

## Boundary

Unavailable provider models should be shown disabled when the provider returned
a reason the user can act on, otherwise omitted. Disabled options require a
short `reason` string for visible guidance.

## Example

```gx
var modelSelect = <AIModelSelect
  id="model-selector"
  current="gpt-5.4"
  options={modelOptions}
  onChange={setModel}>
</AIModelSelect>
```

```go
var modelOptions = []AIModelOption{
	{ID: "gpt-5.4", Label: "GPT-5.4"},
}

type AIModelChangeEvent struct {
	SourceID string
	ModelID string
}

type AIModelOption struct {
	ID string
	Label string
	Disabled bool
	Reason string
}

func setModel(event AIModelChangeEvent) gx.Result {
	return ai.SetModel(event.ModelID)
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
