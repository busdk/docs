---
title: SubmitState UI component
description: Dedicated BusDK UI reference for SubmitState.
---

## Purpose

`SubmitState` is a navigation/action/form component. Busy submit feedback. Use to prevent duplicate submit and show progress.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `action` | yes | action token | Target action. |
| `working` | yes | boolean or action-pending binding | Busy flag. The caller owns this state: bind it to product state that is set true when the action starts and false on completion/failure, or bind to the host action runtime's pending-state signal. When true, submission is disabled and progress state is shown. |
| `label` | yes | string | Normal label. |
| `workingLabel` | no | string | Busy label. Defaults to `label` when omitted so the control keeps a stable accessible name. |

## Boundary

Busy state disables duplicate submission.

## Example

```yaml
data:
  actionPending:
    save: false
actions:
  save:
    method: POST
    target:
      base: module
      path: /save
    pending: actionPending.save
body:
  kind: SubmitState
  props:
    action: save
    working: { bind: actionPending.save }
    label: Save
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./filter-toolbar">FilterToolbar</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./text-table">TextTable</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
