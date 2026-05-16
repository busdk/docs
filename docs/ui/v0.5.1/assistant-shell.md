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
| `width` | no | CSS length | Default `24rem`; accepts `rem`, `px`, or `%`. The built-in bounds are `18rem` to `40rem` unless [runtime config](../v0.4.2/runtime-config) sets `assistantMinWidth` and `assistantMaxWidth` with the same units. |
| `collapsed` | no | bool | Default false. When true, the assistant pane is hidden and business content remains mounted. |
| `onToggle` | no | `func(AssistantToggleEvent) gx.Result` | Enables the shell toggle control. Omitted means the host may still collapse the pane, but the shell renders no local toggle button. |
| `slots.header` | no | slot node | Optional shell header. |

## Boundary

Toggling the assistant preserves business content. `AssistantToggleEvent`
contains `Collapsed bool` with the next requested state; the parent controller
owns whether that state is accepted and passed back through `collapsed`.

## Example

```gx
var shell = <AssistantShell collapsed={assistantCollapsed} onToggle={toggleAssistant}>
  <Panel slot="business" title="Workspace"></Panel>
  <AIPanel
    slot="assistant"
    activeThread={ai.ActiveThread}
    threads={ai.Threads}
    messages={ai.Messages}>
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
