---
title: Action UI concept
description: Dedicated BusDK UI framework concept page for Action.
---

## Purpose

An action is a stable token mapped to a typed handler. It covers submit, click, approve, archive, upload, send, stop, and provider job starts.

## Boundary

Declarative documents define an `actions` map at document root when the action routes to a named server endpoint or resource operation. Go/WASM apps register handlers with the `bus-ui` `ActionHandler[T]` / `DispatchAction` map when the action is handled inside the mounted client runtime:

```go
handlers := map[string]uikit.ActionHandler[DraftNote]{
	"save-note": saveDraftNote,
}
```

In both paths the public token is a stable string, the payload shape is declared beside the handler, and buttons or forms reference only the token.

## Example

```yaml
actions:
  save-note:
    method: POST
    target:
      base: module
      path: /notes
    payload:
      title: { bind: draft.title }
body:
  kind: Button
  props:
    label: Save note
    action: save-note
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./state">State</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./resource">Resource</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
