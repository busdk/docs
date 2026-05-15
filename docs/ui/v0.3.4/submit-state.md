---
title: SubmitState UI component
description: Dedicated BusDK UI reference for SubmitState.
---

## Purpose

`SubmitState` is a navigation/event/form component. Busy submit feedback. Use to prevent duplicate submit and show progress.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended for events | string | Stable submitter id included in the parent form submit event. If omitted, the renderer uses the component tree path as the submitter. |
| `submit` | yes | event name | Target submit event. |
| `working` | yes | boolean or event-pending binding | Busy flag. The caller owns this state: bind it to product state that is set true when the event starts and false on completion/failure, or bind to the host event runtime's pending-state signal. When true, submission is disabled and progress state is shown. |
| `body` | yes | string | Normal button body. |
| `workingBody` | no | string | Busy button body. Defaults to `body` when omitted so the control keeps a stable accessible name. |

## Boundary

Busy state disables duplicate submission.

## Example

```yaml
data:
  eventPending:
    save: false
events:
  save:
    resource: save
resources:
  save:
    base: module
    method: POST
    path: /save
body:
  kind: SubmitState
  props:
    id: save-button
    submit: save
    working:
      bind: eventPending.save
  body: Save
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

Resource defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
