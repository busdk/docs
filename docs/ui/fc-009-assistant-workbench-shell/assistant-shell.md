---
title: AssistantShell UI component
description: Dedicated BusDK UI reference for AssistantShell.
---

## Purpose

`AssistantShell` is a two-pane shell for product screens that keep their
primary workflow visible while an assistant pane is open. Use it when AI helps
with an existing task instead of replacing the task surface.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `business` | yes | `gx.Node` slot | Primary workflow content. |
| `assistant` | yes | `gx.Node` slot | Assistant pane content. |
| `width` | no | CSS length | Default `24rem`; accepts `rem`, `px`, or `%`. The built-in bounds are `18rem` to `40rem` unless [runtime config](../fc-004-runtime-config-api-urls/runtime-config) sets `assistantMinWidth` and `assistantMaxWidth` with the same units. |
| `collapsed` | no | bool | Default false. When true, the assistant pane is hidden and business content remains mounted. |
| `onToggle` | no | `func(AssistantToggleEvent) gx.Result` | Enables the shell toggle control. Omitted means the host may still collapse the pane, but the shell renders no local toggle button. |
| `header` | no | `gx.Node` slot | Optional shell header. |

## Boundary

Toggling the assistant preserves business content. `AssistantToggleEvent`
contains `Collapsed bool` with the next requested state; the parent component
owns whether that state is accepted and passed back through `collapsed`.

## Example

```gx
var shell = <AssistantShell collapsed={assistantCollapsed} onToggle={toggleAssistant}>
  <Panel slot="business" title="Workspace"></Panel>
  <AIPanel slot="assistant" title="Assistant">
    <Text value={assistantSummary}></Text>
  </AIPanel>
</AssistantShell>
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
