---
title: AIComposer UI component
description: Dedicated BusDK UI reference for AIComposer.
---

## Purpose

`AIComposer` is an assistant component. Assistant draft input. Use for prompt entry and turn controls.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | yes | string | Stable source id used as `AIComposeEvent.SourceID` and as the controller state key for this composer. |
| `value` | no | string | Draft text; omitted values render as an empty draft. |
| `onInput` | no | `func(string) gx.Result` | Receives the edited draft text. Omit for read-only draft display. |
| `onSend` | yes | `func(AIComposeEvent) gx.Result` | Identifies the composer source. The controller reads the current draft text. |
| `onInterrupt` | no | `func(AIComposeEvent) gx.Result` | Identifies the composer source for stopping the active turn; omitted hides the stop control. |
| `disabled` | no | boolean | Default `false`; disables input and send. |

## Boundary

Send and interrupt callbacks do not call a model directly or send draft text in
the event. The controller stores draft text under the component `id`; `onInput`
updates that state, and `onSend` reads it by `SourceID`. The controller owns
provider selection, persistence, and error handling.

## Example

```gx
var composer = <AIComposer
  id="assistant-composer"
  value={draft.Text}
  onInput={updateDraft}
  onSend={sendDraft}
  onInterrupt={interruptRun}>
</AIComposer>
```

```go
type AIComposeEvent struct {
	SourceID string
}

func updateDraft(value string) gx.Result {
	drafts.Set("assistant-composer", value)
	return gx.Noop()
}

func sendDraft(event AIComposeEvent) gx.Result {
	return ai.Send(drafts.Get(event.SourceID))
}
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

[Resource](../v0.4.1/resource) defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
