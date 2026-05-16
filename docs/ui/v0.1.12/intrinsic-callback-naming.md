---
title: Intrinsic callback naming
description: BusDK UI v0.1.12 HTML-like callback attribute names.
---

## Contract

`v0.1.12` renames interactive callback attributes to match HTML/DOM event
names as closely as Go syntax allows. GX uses `on`-prefixed camel-case names:

| Browser event | GX attribute | Go props field |
| --- | --- | --- |
| `click` | `onClick` | `OnClick` |
| `submit` | `onSubmit` | `OnSubmit` |
| `input` | `onInput` | `OnInput` |
| `change` | `onChange` | `OnChange` |

The old bare callback spellings are removed, not kept as aliases. GX is a new
framework, so public examples, lint diagnostics, compiler lowering, generated
Go, runtime wiring, and test fixtures should use only the `on*` names.

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

func NoteEditor(title string, setTitle func(string), save func()) gx.Node {
  return (
    <form onSubmit={save}>
      <label for="title"><Text value={"Title"}></Text></label>
      <input id="title" name="title" value={title} onInput={setTitle} />
      <button type="submit"><Text value={"Save"}></Text></button>
    </form>
  )
}
```

Lowercase intrinsic elements store callback functions in
[Props](../v0.1.1/props) with the same attribute name, such as `onClick` or
`onInput`. Uppercase component calls map the same attribute names to Go fields
such as `OnClick` or `OnInput`.

## Boundary

This patch changes names only. It does not add new event payload types, effect
hooks, state hooks, expanded intrinsic elements, or resource helpers.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](../v0.1.6/callback-props)
- [Intrinsic interactive elements](../v0.1.6/intrinsic-elements)
