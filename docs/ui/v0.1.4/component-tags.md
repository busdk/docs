---
title: Component tags
description: BusDK UI v0.1.4 uppercase and lowercase GX tag resolution.
---

## Contract

GX tag case decides the first resolver. Uppercase tags are
[component](./component) calls to [Go component functions](./component-functions).
Lowercase tags are safe [Element](../v0.1.1/element) names.

Unknown uppercase tags fail lint before render:

```gx
package notices

var badTag = <Notcie message={"Saved"}></Notcie>
```

`bus gx lint --format json bad_tag.gx` exits non-zero with
`code: unknown-component` at the `Notcie` tag.

## Resolution

A component name must be UpperCamelCase when it is used as a GX tag. The
compiler resolves it as a Go callable in the same package or through ordinary
Go imports available to the `.gx` source. Unknown component functions or
method values fail lint before render.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component call patch](./custom-components)
- [Component concept](./component)
- [Component functions](./component-functions)
