---
title: Template UI component
description: Dedicated BusDK UI reference for Template.
---

## Purpose

`Template` is a Core registry entry produced by compiling `.gx` files. Use it
for hot paths where structure is stable and only values change.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `name` | yes | template identifier | Selects a compiled `.gx` template registered by the host renderer or `bus-gx` template bundle. Valid names come from the renderer template registry described in [templates](./templates); unknown names fail validation before rendering. |
| `slots` | yes | map of slot names to values | Supplies only the slot names declared by the selected template registry entry. Values are escaped text, booleans, numbers, safe attribute values, or node children. Missing required slots and unknown extra slots fail validation. Attribute slots use the same rules as [Props](../v0.1.1/props): stable names, escaped scalar values, no event attributes, and no URL-bearing attributes in this patch. |
| `children` | no | node list | Allowed only when the selected template declares a `children` slot. Supplying children to a template without that slot fails validation. |

## Boundary

GX source files do not require a top-level `<Template>` wrapper. The `.gx`
compiler publishes named template entries, the host renderer exposes the
available registry, and product modules choose from that list. Slot values are
bounded and escaped before they are inserted, so templates keep stable
structure while dynamic data stays data.

## Example

```gx
package terminalui

var terminalLineSlots = gx.Slots{
	"stream": gx.Value("stdout"),
	"text":   gx.Value("build complete"),
}

var line = <Template name="terminal-output-line" slots={terminalLineSlots}></Template>
```

## Runtime Terms

Template slots in this patch accept literal safe values or nodes. Data binding
is not part of v0.1.4.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component reference](./component-reference)
- [GX tooling](../v0.1.3/gx-tooling)
