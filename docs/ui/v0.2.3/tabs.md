---
title: Tabs UI component
description: Dedicated BusDK UI reference for Tabs.
---

## Purpose

`Tabs` is a navigation/event/form component. Sibling view switcher. Use for sibling views at the same hierarchy level.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `items` | yes | item slice | Each item has stable string `ID`, non-empty `Label`, and exactly one of `Href` or `OnClick`. `Href` accepts relative module routes or same-origin absolute paths. `OnClick` is a Go callback. Duplicate ids, missing labels, unsafe URLs, and mixed `Href`+`OnClick` entries fail validation. |
| `active` | yes | string | Current item id. Must match one `items[].id`; unknown active ids fail validation. |

## Boundary

Active tab is visible. Product modules own route meaning, permissions, and
state changes after callback-driven tab activation.

## Example

```gx
func FileTabs(active string) gx.Node {
	return <Tabs active={active} items={[]ui.TabItem{
		{ID: "overview", Label: "Overview", Href: "./"},
		{ID: "files", Label: "Files", Href: "./files"},
	}}></Tabs>
}
```

## Runtime Terms

Tab links accept relative module routes such as `./files` or same-origin
absolute paths beginning with `/`. Relative routes are resolved against the
current module route and must not escape it with `..`. External route
resolvers and host navigation allowlists are introduced by later host-context
patches, not by `v0.2.3`. `javascript:`, `data:`, path traversal, and
unresolved authorization failures are rejected.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
