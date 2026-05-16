---
title: Library assistant composer
description: BusDK UI library assistant draft input contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`AIComposer`](./ai-composer) renders assistant draft input. Draft
text comes from the controller. Omitted send or interrupt event names hide the
matching interactive control.

| Prop | Required | Behavior |
| --- | --- | --- |
| `draft` | no | String draft text; defaults empty. |
| `placeholder` | no | Public-safe input hint. |
| `send` | no | Runtime event name for submit. |
| `interrupt` | no | Runtime event name for stopping active work. |
| `disabled` | no | Boolean; defaults false. |

Send and interrupt events emit source identity only. No draft text, model id,
attachments, provider request, or command payload is included. The controller
reads draft state from its model after receiving the event:

```go
emitted := map[string]any{
	"event": "send-message",
	"source": map[string]string{
		"id":   "assistant-composer",
		"path": "/AIPanel[0]/AIComposer[0]",
	},
}
```

```gx
var composer = <AIComposer
  draft={draft}
  send="send-message"
  interrupt="interrupt-run">
</AIComposer>
```

The composer emits intent and source identity. Prompt validation, provider
policy, model availability, attachment policy, and run scheduling stay outside
the component.

## Consequence

Assistant draft input stays reusable because it does not own provider behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [AIComposer](./ai-composer)
- [Callback props](../v0.1.6/callback-props)
