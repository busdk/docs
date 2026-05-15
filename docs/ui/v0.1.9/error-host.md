---
title: ErrorHost UI component
description: Dedicated BusDK UI reference for ErrorHost.
---

## Purpose

`ErrorHost` is an event/resource/effect component. Runtime error host. Use for mounted-app runtime failures.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `error` | yes | string or `{message,code,details}` object binding | Empty or null renders nothing; objects render `message` plus optional sanitized `code` and `details`. Stack traces, tokens, secrets, and private runtime data must not be passed. |
| `dismiss` | no | event name | Optional dismiss event. Omitted keeps the error visible until the bound error value changes; `ErrorHost` does not perform local hide by itself. |

## Boundary

Dismiss is available only when `dismiss` is supplied. It asks the runtime
to clear the bound error state; without `dismiss`, the error stays visible
until the bound value changes.

## Example

```yaml
kind: ErrorHost
props:
  error:
    bind: runtime.error
  dismiss: dismiss-error
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [GX tooling](../v0.1.3/gx-tooling)
