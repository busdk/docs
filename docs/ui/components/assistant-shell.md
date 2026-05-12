---
title: AssistantShell UI component
description: Dedicated BusDK UI reference for AssistantShell.
---

## Purpose

`AssistantShell` is a shell/layout component. Business surface with assistant pane. Use when AI assists an existing product workflow.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `slots.business` | yes | slot node | Primary workflow. |
| `slots.assistant` | yes | slot node | Assistant pane. |
| `props.width` | no | CSS length | Default `24rem`; accepts `rem`, `px`, or `%`. The built-in bounds are `18rem` to `40rem` unless the host runtime config overrides `assistantMinWidth` and `assistantMaxWidth` with the same units. |
| `slots.header` | no | slot node | Optional shell header. |

## Boundary

Toggling the assistant preserves business content.

## Example

```yaml
kind: AssistantShell
slots:
  business:
    kind: Panel
    props: { title: Workspace }
  assistant:
    kind: AIPanel
    props:
      threads: { bind: ai.threads }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./split-layout">SplitLayout</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./panel">Panel</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
