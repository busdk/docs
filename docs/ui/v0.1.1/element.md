---
title: Element node
description: BusDK UI v0.1.1 safe element node reference.
---

## Purpose

`Element` is a safe generic HTML [Node](./node). Use it for static structural
HTML in the first Core renderer.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `tag` | yes | HTML tag name | Complete allowlist: `div`, `span`, `section`, `article`, `header`, `footer`, `main`, `nav`, `p`, `ul`, `ol`, `li`, `table`, `thead`, `tbody`, `tr`, `th`, and `td`; unsupported tags fail validation. |
| `children` | yes | [Node](./node) list | Rendered in order. |
| `attrs` | no | [Props](./props) map | String, boolean, and number values only. Allowed keys are `id`, `class`, `title`, `role`, `data-*`, and `aria-*`; event-handler attributes, URL-bearing attributes, and raw style strings are rejected. |

## Boundary

Output uses the requested safe tag and stable attributes.

## Go Shape

```go
import "github.com/busdk/bus-gx/pkg/gx"

node := gx.Element("section",
	gx.Props{"class": "bus-panel"},
	gx.Text("Generic content"),
)
```

The rendered output is:

```html
<section class="bus-panel">Generic content</section>
```

## Link Boundary

Generic `Element` does not create links because `a` is outside its tag
allowlist.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core foundation](./)
- [Node concept](./node)
