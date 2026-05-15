---
title: Props reference
description: BusDK UI v0.1.1 deterministic props reference.
---

## Purpose

`Props` is the deterministic attribute map for [Element](./element) nodes.

## Inputs

| Entry | Required | Type | Behavior |
| --- | --- | --- | --- |
| `<name>` | no | scalar attribute value | Keys are sorted before rendering. Values may be string, number, boolean, or null. Strings and numbers are escaped as attribute text, regular `true` renders the string value `"true"`, `false` and `null` omit the attribute, and empty string renders an empty attribute value. Use `bool:<name>` for HTML boolean attributes that should render without a value. |
| `bool:<name>` | no | boolean attribute entry | Boolean attribute syntax for flags such as `bool:disabled: true`. True renders `<name>` without a value, false or omitted leaves it out. |

## Boundary

Attribute ordering is stable across renders. Attribute names must be valid HTML
attribute names or `data-*`/`aria-*` names. Direct `Props` validation rejects
event handler attributes such as `onclick`. URL-bearing attributes such as
`href` or `src` fail validation in `v0.1.1`.

## Go Shape

```go
import "github.com/busdk/bus-gx/pkg/gx"

props := gx.Props{
	"class":         "bus-button",
	"bool:disabled": false,
}
```

The rendered attribute string is:

```html
class="bus-button"
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./)
- [Node concept](./node)
