---
title: Library submit state
description: BusDK UI library submit busy, disabled, and feedback state contract.
---

## Design References

- [Binding](../v0.1.5/binding)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`SubmitState`](./submit-state) renders busy, disabled, and submit
feedback state from the view model. It may render a submit button body, busy
indicator, disabled reason, or result message.

The expected view-model fields are:

| Field | Required | Type And Default |
| --- | --- | --- |
| `submitting` | no | Boolean; defaults false. |
| `disabledReason` | no | Public-safe message; omitted when submit is allowed. |
| `formError` | no | Object with required string `title` and optional string `message`, `code`, and `requestID`; omitted when no form-level error is visible. |
| `result` | no | String public-safe success or completion message; omitted or cleared when no result is visible. |

Public-safe text may name the operation, field, status code, or request id. It
must not include tokens, secrets, raw provider payloads, stack traces, SQL,
private customer data, or credential headers.

State priority is deterministic: `submitting` wins first, then `formError`,
then `disabledReason`, then `result`. A view model may include lower-priority
fields for the next render, but the component renders only the highest-priority
state. `submitting: true` with `disabledReason` is valid and renders busy;
`formError` with `result` is valid and renders the error until the controller
clears it.

## Consequence

Submit feedback is visible state. The controller owns transitions into and out
of busy, disabled, success, and error states.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [SubmitState](./submit-state)
- State UI concept
