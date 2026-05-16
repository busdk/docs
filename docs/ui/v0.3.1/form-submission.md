---
title: Library form submission
description: BusDK UI library form submit event contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`Form`](./form) wraps native form behavior with shared classes.
Forms receive submit callbacks through `onSubmit={saveNote}` in GX markup. The
callback is ordinary Go code owned by the parent component.

On submit, the form applies native form submit rules, prevents browser
navigation, and calls the configured callback with a typed submit payload. The
parent component decides what Go state is read and what request payload is
sent. Calling `event.PreventDefault()` inside the callback is optional and
idempotent; it is useful only when parent code wants to document that native
submit navigation must stay suppressed.

The emitted event shape is:

| Key | Type | Required | Behavior |
| --- | --- | --- | --- |
| `source.id` | string | yes when the form has `id` | Stable form id authored in the template. |
| `source.path` | string | yes | Renderer-generated component tree path such as `/Form[0]`; stable for the same rendered tree shape. |
| `submitter.id` | string | yes when the submitter has `id` | Stable id of the clicked submit control. |
| `submitter.path` | string | yes | Renderer-generated tree path for the submit control, such as `/Form[0]/SubmitState[0]`. |

The consumer uses the submit identity only as context. The data comes from
controller-owned Go state:

```gx
func NoteEditor(p NoteEditorProps) gx.Node {
  submit := func(event gx.SubmitEvent) {
    if p.Saving {
      return
    }
    p.Save(p.Draft)
  }

  return (
    <Form id="note-editor" onSubmit={submit}>
      <Field label="Title" error={p.TitleError}>
        <TextInput name="title" value={p.Draft.Title} onInput={p.SetTitle}></TextInput>
      </Field>
      <SubmitState id="save-button" working={p.Saving}>Save</SubmitState>
    </Form>
  )
}
```

## Consequence

Submit callbacks identify the submitted form. Request payloads read
controller-owned Go state instead of receiving mutable form data as event
parameters.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Form](./form)
- [Typed event payloads](../v0.1.15/typed-event-payloads)
