---
title: CloseGuard UI runtime block
description: Dedicated BusDK UI reference for CloseGuard.
---

## Purpose

`CloseGuard` protects browser navigation, route changes, panel close, or
component disposal when closing would lose active or unsaved work.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `activeWork` | yes | boolean | Running work flag. |
| `unsavedWork` | yes | boolean | Dirty draft flag. |
| `message` | no | string | Custom in-app prompt; default is "Unsaved or active work may be lost." Browser navigation prompts may ignore custom text. |

## Boundary

When either `activeWork` or `unsavedWork` is true, the guard prompts and blocks
the close until the user confirms. No prompt appears when both flags are false.

## Example

```yaml
kind: CloseGuard
props:
  activeWork: { bind: ai.running }
  unsavedWork: { bind: draft.dirty }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./error-host">ErrorHost</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./disposer">Disposer</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
