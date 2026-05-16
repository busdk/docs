---
title: Component call patch
description: BusDK UI v0.1.4 uppercase component call roadmap.
---

## Purpose

`v0.1.4` adds calls to reusable components from
[GX template entries](../v0.1.3/template-entries). [Uppercase tags](./component-tags)
resolve to typed [Go component functions](./component-functions), and
component props are validated from Go types.

Lowercase HTML tags keep resolving through the safe [Element](../v0.1.1/element)
path. Reusable behavior belongs in uppercase function components such as
`<Button>`.

## Scope

1. Resolve uppercase component tags deterministically.
2. Compile uppercase tags to ordinary Go callable component calls that return
   `gx.Node`.
3. Support typed component props.
4. Reject unknown components, missing required props, and invalid prop types
   before render.
5. Let template entries reuse existing Go component functions.
6. Keep GX component body markup, body children, callback props, resources,
   effects, lifecycle hooks, and browser hydration outside this version.

## Public Result

Authors can define reusable tags as Go functions, call them from a
[template entry](../v0.1.3/template-entries), and validate them with the same
source tools introduced in earlier patches. The `notice.gx` and
`noticeExample` names come from the valid fixture in
[component functions](./component-functions):

```sh
bus gx fmt --check notice.gx
bus gx lint --format json notice.gx
bus gx compile notice.gx --output notice.go
```

The command surface remains source-oriented. This patch does not add GX
component body markup, component body children, callback props, resources,
effects, lifecycle hooks, browser hydration, or a separate runtime template
document format.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Components](./component)
- [Component tags](./component-tags)
- [Component functions](./component-functions)
- [Custom component checks](./acceptance)
- [v0.1.3 template entries](../v0.1.3/template-entries)
