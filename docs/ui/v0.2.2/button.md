---
title: Button UI component
description: Dedicated BusDK UI reference for Button.
---

## Purpose

`Button` is a navigation/event/form component. Native event button. Use for
visible operations in the current workflow.

In templates, `<Button>` invokes this component. Lowercase `<button>` remains a
safe HTML-compatible element; reusable Bus UI behavior belongs in the uppercase
component.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended for events | string | Stable source id included in click events. If omitted, the renderer uses the component tree path as the source. |
| `body` | yes | text or inline node | Visible button content. Use [`IconButton`](./icon-button) for icon-only controls. |
| `ariaLabel` | no | string | Optional accessible override when visible label needs clarification. |
| `onClick` | no | function | Go callback invoked when activated; may be omitted only for submit/reset buttons or disabled display buttons. |
| `type` | no | button, submit, reset | Default `button`; `submit` and `reset` may omit `onClick` because native form behavior handles them. |
| `variant` | no | primary, secondary, danger, ghost | Default `secondary`; `primary` is the main safe event, `danger` is destructive, and `ghost` is low-emphasis chrome. |
| `size` | no | small, medium, large | Default medium. |
| `disabled` | no | boolean | Suppresses event emission. |

## Boundary

Button has visible body content. Interactive buttons use a typed click
callback; submit/reset or disabled display buttons may omit `onClick`.

## Example

```gx
package notesui

var saveAction = (
  <Button id="save-button" onClick={saveDraft} variant="primary">
    Save
  </Button>
)
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
