---
title: AIModelSelect UI component
description: Dedicated BusDK UI reference for AIModelSelect.
---

## Purpose

`AIModelSelect` is an assistant component. Assistant model picker. Use when model choice is visible.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended | string | Stable selector id included in the emitted source. If omitted, the renderer-generated tree path identifies the selector. |
| `current` | yes | string | Current model id. Must equal an `options[].id` or render with `fallback`. |
| `options` | yes | array of `{id,label,disabled,reason}` | `id` is required; `label` defaults to `id`; disabled choices render but cannot be selected. |
| `onChange` | yes | event name | Runs when model selection changes. The emitted event includes `source.id` or `source.path` plus `value.modelID` containing the selected option id; the controller validates and stores the model choice. |
| `fallback` | no | string | Display label for unavailable `current`; default is `current`. |

## Boundary

Unavailable provider models should be shown disabled when the provider returned
a reason the user can act on, otherwise omitted. Disabled options require a
short `reason` string for visible guidance.

## Example

This component-only example assumes `set-model` is already declared in the
runtime `events` map or registered by Go code.

```yaml
kind: AIModelSelect
props:
  id: model-selector
  current: gpt-5.4
  options:
    - id: gpt-5.4
      label: GPT-5.4
    - id: gpt-5.4-mini
      label: GPT-5.4 Mini
  onChange: set-model
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
