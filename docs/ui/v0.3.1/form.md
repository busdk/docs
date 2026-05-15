---
title: Form UI component
description: Dedicated BusDK UI reference for Form.
---

## Purpose

`Form` is a navigation/event/form component. Native form wrapper. Use for
native submit behavior while routing the submit through a runtime event.

In templates, `<Form>` invokes this component. A scoped lowercase `form`
element adapter may map native `<form>` markup to the same event-routing
behavior when the product wants to extend the standard HTML name.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended for events | string | Stable source id included in submit events. If omitted, the renderer uses the component tree path as the source. |
| `method` | yes | GET or POST | Native method. |
| `submit` | yes | event name | Submit event. The form controller emits it after a submitter click or enter-submit passes native form rules. The runtime event chooses a handler, resource, navigation target, or effect. Unresolved event names fail validation. |
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
  submit: save-note
body:
  - kind: Button
    props:
      id: save-button
      type: submit
      variant: primary
    body: Save
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names and handler registration.
Resource defines URL allowlist and rejection rules.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
