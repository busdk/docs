---
title: SurfaceCard UI component
description: Dedicated BusDK UI reference for SurfaceCard.
---

## Purpose

`SurfaceCard` is the public node-first card surface component for repeated
records or compact grouped facts. It is not a page, portal, or app shell.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `headerNodes` | no | node list | Optional header content. |
| `bodyNodes` | yes | node list | Card body. |
| `footerNodes` | no | node list | Optional footer content. |
| `headerHTML` | no | string | Compatibility escape hatch for trusted legacy header markup. |
| `bodyHTML` | no | string | Compatibility escape hatch for trusted legacy body markup. |
| `footerHTML` | no | string | Compatibility escape hatch for trusted legacy footer markup. |

## Boundary

`SurfaceCard` may contain compact content such as `SummaryItem`, `MetricCard`,
`StatusPill`, text, form fields, and small event rows. Do not nest page or app
shells inside it, including `AppShell`, `PortalShell`, `SidebarShell`,
`SplitLayout`, or another `SurfaceCard`; use those as surrounding layout
instead. The preferred path is typed `gx.Node` composition, while the HTML
fields remain compatibility adapters for trusted fragments. When a caller
needs HTML, render the node through the public `pkg/ui` boundary.

## Example

```go
package evidenceui

import (
	gx "github.com/busdk/bus-gx/pkg/gx"
	"github.com/busdk/bus-ui/pkg/ui"
)

func evidenceCard() (string, error) {
	node, err := ui.SurfaceCard(ui.SurfaceCardProps{
		BodyNodes: []gx.Node{
			gx.Element("p", nil, gx.Text("Evidence note")),
		},
	})
	if err != nil {
		return "", err
	}
	return ui.RenderHTML(node)
}
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
