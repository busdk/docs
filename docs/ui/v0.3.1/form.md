---
title: Form UI component
description: Dedicated BusDK UI reference for Form.
---

## Purpose

`Form` is a navigation/event/form component. Native form wrapper. Use for
native submit behavior while routing the submit through a runtime event.

In templates, `<Form>` invokes this component. Lowercase `<form>` remains a
safe HTML-compatible element; reusable Bus UI behavior belongs in the uppercase
component.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended for events | string | Stable source id included in submit events. If omitted, the renderer uses the component tree path as the source. |
| `method` | yes | GET or POST | Native method. |
| `onSubmit` | yes | `func()` or `func(gx.SubmitEvent)` | Submit callback. The form controller calls it after a submitter click or enter-submit passes native form rules. `gx.SubmitEvent` carries form id, submitter id/name/value, dataset values, and explicit prevent-default state from [typed event payloads](../v0.1.15/typed-event-payloads). |
| `body` | yes | node list | Form body. |

## Boundary

Enter-submit works without local JavaScript. Same-origin paths, HTTP methods,
and external-origin allowlists belong to the receiving resource or navigation
entry, not the form component. Submit events identify the form source and
submitter; app controllers decide what model or form state to read.

## Example

```gx
package notesui

var noteForm = (
  <Form id="note-editor" method="POST" onSubmit={saveNote}>
    <Button id="save-button" type="submit" variant="primary">
      Save
    </Button>
  </Form>
)
```

## Runtime Terms

`onSubmit` has no return value. Validation failures, pending state, and
provider errors are ordinary Go state owned by the parent component. The typed
payload source includes the form `id` when present, otherwise the
renderer-generated tree path. Resource and navigation helpers called by the
callback must accept only same-origin paths or host-allowlisted `https:` URLs
and must reject `javascript:`, `data:`, path traversal, and credential-bearing
URLs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
