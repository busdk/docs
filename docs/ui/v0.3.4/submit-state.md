---
title: SubmitState UI component
description: Dedicated BusDK UI reference for SubmitState.
---

## Purpose

`SubmitState` is a form control that renders submit feedback from ordinary Go
state. Use it to prevent duplicate submits and show progress while the parent
component is saving.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended | string | Stable submitter id for tests and event target data. |
| `working` | yes | boolean | Busy flag owned by the caller. When true, submission is disabled and progress state is shown. |
| body | yes | text or nodes | Normal button body. |
| `workingBody` | no | string | Busy button body. Defaults to `body` when omitted so the control keeps a stable accessible name. |

## Boundary

Busy state disables duplicate submission.

## Example

```gx
type NoteEditorProps struct {
  Draft      NoteDraft
  Saving     bool
  SaveDraft  func(NoteDraft) error
  SetSaving  func(bool)
  SetError   func(error)
}

func NoteEditor(p NoteEditorProps) gx.Node {
  submit := func(event gx.SubmitEvent) {
    if p.Saving {
      return
    }
    p.SetSaving(true)
    if err := p.SaveDraft(p.Draft); err != nil {
      p.SetError(err)
    }
    p.SetSaving(false)
  }

  return (
    <Form id="note-editor" onSubmit={submit}>
      <SubmitState id="save-button" working={p.Saving} workingBody="Saving">
        Save
      </SubmitState>
    </Form>
  )
}
```

`SubmitState` does not own the submit callback or decide what data to save. The
parent [`Form`](../v0.3.1/form-submission) owns `onSubmit`; the parent
component reads its current Go state, starts the save operation, and toggles
`working` for the next render.

## Runtime Terms

[Typed event payloads](../v0.1.15/typed-event-payloads) document submit event
payloads.

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Library submit state](./submit-state-patch)
- [bus-ui module reference](../../modules/bus-ui)
