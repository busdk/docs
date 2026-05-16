---
title: Library form submission
description: BusDK UI library form submit event contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`Form`](./form) wraps native form behavior with shared classes.
Forms emit submit events through `submit="save-note"` in markup or through
structured props with `submit: save-note`. The structured form `submit` field
is required for active submits and must name a runtime event.

On submit, the form controller receives the submitter click, applies native
form submit rules, and emits the configured submit event with form source and
submitter identity. The app controller decides what model state is read and
what request payload is sent.

The emitted event shape is:

| Key | Type | Required | Behavior |
| --- | --- | --- | --- |
| `event` | string | yes | Runtime event name from the form `submit` prop. |
| `source.id` | string | yes when the form has `id` | Stable form id authored in the template. |
| `source.path` | string | yes | Renderer-generated component tree path such as `/Form[0]`; stable for the same rendered tree shape. |
| `submitter.id` | string | yes when the submitter has `id` | Stable id of the clicked submit control. |
| `submitter.path` | string | yes | Renderer-generated tree path for the submit control, such as `/Form[0]/SubmitState[0]`. |

The consumer uses identity to choose controller-owned state:

```yaml
events:
  save-note:
    resource: save-note
resources:
  save-note:
    method: POST
    base: module
    path: /notes
    payload:
      title:
        bind: draft.title
```

```html
<Form id="note-editor" submit="save-note">
  <Field label="Title" error={titleError}>
    <TextInput name="title" value={title}></TextInput>
  </Field>
  <SubmitState id="save-button" submit="save-note" working={submitting}>Save</SubmitState>
</Form>
```

```yaml
kind: Form
props:
  method: POST
  submit: save-note
```

## Consequence

Submit events identify the submitted form. Resource payloads read
controller-owned model state instead of receiving mutable form data as event
parameters.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Form](./form)
- [Callback props](../v0.1.6/callback-props)
