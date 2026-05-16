---
title: Component children
description: BusDK UI v0.1.5 component body children.
---

## Contract

Body content becomes default children when the component function's props
struct includes `Children []gx.Node`:

```gx
package notices

import "github.com/busdk/bus-gx/pkg/gx"

type NoticeProps struct {
	Children []gx.Node
}

func Notice(p NoticeProps) gx.Node {
  return (
    <section class="bus-notice">
      {p.Children}
    </section>
  )
}

var noticeWithChildren = (
  <Notice>
    <span>Saved</span>
  </Notice>
)
```

The compiler passes body nodes in source order. Body content fails lint when
the props type has no `Children []gx.Node` field. Rendering keeps child order,
deterministic attribute sorting, and text escaping.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component body markup](./component-body-markup)
- [v0.1.4 component functions](../v0.1.4/component-functions)
