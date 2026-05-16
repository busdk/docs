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
| `onSubmit` | yes | event name | Submit event. The form controller emits it after a submitter click or enter-submit passes native form rules. The runtime event chooses a handler, resource, navigation target, or effect. Unresolved event names fail validation. |
| `body` | yes | node list | Form body. |

## Boundary

Enter-submit works without local JavaScript. Same-origin paths, HTTP methods,
and external-origin allowlists belong to the receiving resource or navigation
entry, not the form component. Submit events identify the form source and
submitter; app controllers decide what model or form state to read.

## Example

```yaml
kind: Form
props:
  id: note-editor
  method: POST
  onSubmit: save-note
body:
  - kind: Button
    props:
      id: save-button
      type: submit
      variant: primary
    body: Save
```

## Runtime Terms

`onSubmit` names a runtime event handler for this form component. The event
source includes the form `id` when present, otherwise the renderer-generated
tree path. Resource and navigation handlers must accept only same-origin paths
or host-allowlisted `https:` URLs and must reject `javascript:`, `data:`, path
traversal, and credential-bearing URLs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
