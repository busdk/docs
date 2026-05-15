---
title: VNode reference
description: BusDK UI v0.1.1 virtual node reference.
---

## Purpose

`VNode` is the normalized [Node](./node) representation shared by deterministic
HTML rendering and unit inspection.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `kind` | yes | element, text, or fragment | Selects the `v0.1.1` node representation. |
| `tag` | for element | HTML tag | Required for element nodes. |
| `text` | for text | string | Escaped before rendering. |
| `attrs` | no | props map | Attribute handling follows [Props](./props). Event-handler attributes such as `onclick`, and URL-bearing attributes such as `href`, `src`, `formaction`, and `poster` fail validation. |
| `children` | no | [Node](./node) list | Rendered in order. |

## Boundary

Server HTML and tests consume the same tree. Prefer [Text](./text) nodes for
user/provider content. `v0.1.1` has no raw node kind.

Kind-specific validation is strict. [Element](./element) nodes require `tag`
and may use `attrs` and `children`; [Text](./text) nodes require `text` and
reject `tag`, `attrs`, and `children`; [Fragment](./fragment) nodes use
`children` but reject `tag`, `text`, and `attrs`. Fields outside the selected
kind fail validation instead of being ignored.

## Go Shape

```go
import "github.com/busdk/bus-gx/pkg/gx"

node := gx.VNode{
	Kind: "element",
	Tag:  "article",
	Children: []gx.VNode{
		{Kind: "text", Text: "Evidence note"},
	},
}
```

The rendered output is:

```html
<article>Evidence note</article>
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./)
- [Node concept](./node)
