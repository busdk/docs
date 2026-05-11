---
title: ErrorHost UI component
description: Dedicated BusDK UI reference for ErrorHost.
---

## Purpose

`ErrorHost` is an action/resource/effect component. Runtime error host. Use for mounted-app runtime failures.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `error` | yes | string or `{message,code,details}` object binding | Empty or null renders nothing; objects render `message` plus optional sanitized `code` and `details`. Stack traces, tokens, secrets, and private runtime data must not be passed. |
| `clearAction` | no | action token | Optional dismiss action. Omitted keeps the error visible until the bound error value changes; `ErrorHost` does not perform local hide by itself. |

## Boundary

Dismiss is available only when `clearAction` is supplied. It asks the runtime
to clear the bound error state; without `clearAction`, the error stays visible
until the bound value changes.

## Example

```yaml
kind: ErrorHost
props:
  error: { bind: runtime.error }
  clearAction: dismiss-error
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./client-log">ClientLog</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./close-guard">CloseGuard</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
