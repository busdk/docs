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
  activeWork:
    bind: ai.running
  unsavedWork:
    bind: draft.dirty
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [GX tooling](../v0.1.3/gx-tooling)
