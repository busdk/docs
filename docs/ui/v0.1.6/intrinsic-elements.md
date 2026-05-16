---
title: Intrinsic interactive elements
description: BusDK UI v0.1.6 native element prop table.
---

## Purpose

`v0.1.6` adds the first intrinsic lowercase elements needed for a usable
browser app. These tags still compile to ordinary `gx.Element` nodes, but their
properties are checked against a typed table like TSX intrinsic elements.

## Element Table

| Tag | Scalar properties | Callback properties |
| --- | --- | --- |
| `button` | `class string`, `id string`, `title string`, `type string`, `disabled bool` | `onClick func()` |
| `form` | `class string`, `id string`, `title string` | `onSubmit func()` |
| `input` | `class string`, `id string`, `title string`, `name string`, `type string`, `value string`, `placeholder string`, `disabled bool`, `required bool` | `onInput func(string)`, `onChange func(string)` |
| `label` | `class string`, `id string`, `title string`, `for string` | none |

Scalar properties render as escaped HTML attributes, except false boolean
properties are omitted. Callback properties are runtime-only function values:
they are present in the normalized node for tests and the browser runtime, and
they are omitted by static HTML rendering.

## Example

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

func NoteEditor(title string, setTitle func(string), save func()) gx.Node {
  return (
    <form onSubmit={save}>
      <label for="title">Title</label>
      <input id="title" name="title" value={title} onInput={setTitle} />
      <button type="submit">Save</button>
    </form>
  )
}
```

The compiler preserves callback expressions as Go values. The browser runtime
from [v0.1.7](../v0.1.7/) decides when to call them. A form should use one
submission path: either `form onSubmit={save}` with a submit button, or
`button onClick={save}` on a non-submit button.

## Boundary

This patch does not add every HTML element or every browser event. New
intrinsic tags and properties must be added deliberately to this table or a
later table. Unknown lowercase tags and unknown properties fail lint.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](./callback-props)
- [v0.1.1 Props reference](../v0.1.1/props)
