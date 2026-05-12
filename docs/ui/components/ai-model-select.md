---
title: AIModelSelect UI component
description: Dedicated BusDK UI reference for AIModelSelect.
---

## Purpose

`AIModelSelect` is an assistant component. Assistant model picker. Use when model choice is visible.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `current` | yes | string | Current model id. Must equal an `options[].id` or render with `fallback`. |
| `options` | yes | array of `{id,label,disabled,reason}` | `id` is required; `label` defaults to `id`; disabled choices render but cannot be selected. |
| `changeAction` | yes | action token | Emits `{model}` where `model` is the selected `options[].id`. |
| `fallback` | no | string | Display label for unavailable `current`; default is `current`. |

## Boundary

Unavailable provider models should be shown disabled when the provider returned
a reason the user can act on, otherwise omitted. Disabled options require a
short `reason` string for visible guidance.

## Example

This component-only example assumes `set-model` is already declared in the
document `actions` map or registered by Go code.

```yaml
kind: AIModelSelect
props:
  current: gpt-5.4
  options:
    - { id: gpt-5.4, label: GPT-5.4 }
    - { id: gpt-5.4-mini, label: GPT-5.4 Mini }
  changeAction: set-model
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-markdown">AIMarkdown</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ai-attachment-list">AIAttachmentList</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
