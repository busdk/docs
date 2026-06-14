---
title: Panel UI component
description: Dedicated BusDK UI reference for Panel.
---

## Purpose

`Panel` is the public node-first shell/layout component. Use it for bounded
titled work surfaces such as forms, settings, and detail views.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or Go value | Escaped title. |
| `bodyNodes` | yes | node list | Preferred panel body composition path. |
| `actionNodes` | no | node list | Optional action row. |
| `footerNodes` | no | node list | Optional footer content. |
| `bodyHTML` | no | string | Compatibility escape hatch for trusted legacy body markup. |
| `actionsHTML` | no | string | Compatibility escape hatch for trusted legacy action markup. |
| `footerHTML` | no | string | Compatibility escape hatch for trusted legacy footer markup. |
| `attrs` | no | safe attribute map | Allows `id`, `class`, `data-*`, and `aria-*`; event handlers, inline style, and unsafe URL attributes are rejected. User attrs merge after framework attrs except protected classes are preserved. |

## Boundary

The preferred path is typed `gx.Node` composition through `BodyNodes`,
`ActionNodes`, and `FooterNodes`. The compatibility HTML fields remain only for
trusted fragments that are already rendered elsewhere. When you need HTML,
render the node through the public `pkg/ui` boundary.

## Example

```go
package reviewui

import (
	gx "github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/ui"
)

func draftPanel() (string, error) {
	node, err := ui.Panel(ui.PanelProps{
		Title: "Draft",
		BodyNodes: []gx.Node{
			gx.Element("p", nil, gx.Text("Ready to review")),
		},
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
}
```

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
