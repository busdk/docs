---
title: Portal shell
description: BusDK UI shell component shape for portal-mounted Go-first GX product pages.
---

## Purpose

`PortalShell` is the product-page frame for modules mounted by `bus-portal`. It
is a Bus UI composition target, not a replacement for the portal host. The host
serves the outer application, assets, security headers, module launcher, and
runtime context; `PortalShell` renders the page-level title, local navigation,
and module body inside the mounted feature route.

## Props

The shell uses typed Go props. It should not read global browser state or infer
deployment paths from literals. GX attributes use the lower-camel form of the
exported Go prop name, so `Title` is written as `title` and `HostContext` is
written as `hostContext` in markup.

```go
type PortalShellProps struct {
    Title       string
    HostContext HostContext
    Nav         []NavItem
    Body        gx.Node
}

type NavItem struct {
    Label string
    Path  string
}
```

| Go prop | GX attribute | Required | Behavior |
| --- | --- | --- | --- |
| `Title string` | `title` | yes | Public page title rendered inside the module frame. Empty titles fail validation. |
| `HostContext HostContext` | `hostContext` | yes | Portal host context used for same-origin links and shared asset references. Missing module ID or base path fails validation. |
| `Nav []NavItem` | `nav` | no | Ordered module-local navigation entries with public labels and host-resolved paths. Invalid entries fail validation. |
| `Body gx.Node` | child markup | yes | Child node or component body supplied by the product page. Nil bodies fail validation. |

Navigation paths are module-relative before rendering and become host-resolved
URLs through `HostContext.ModuleURL`. A valid path starts with `/`, does not
start with `//`, and does not contain backslashes, `..`, tabs, or newlines.
External URLs, path traversal, empty labels, and deployment-specific token
prefixes make `ValidatePortalShellProps` return an error instead of rendering a
partially active nav entry.

## GX Example

GX authors use `PortalShell` as a normal typed component. Child markup fills the
body slot, and callback props remain Go function values.

{% raw %}
```gx
package reportsui

import (
    "github.com/busdk/bus-gx/pkg/gx"
    . "github.com/busdk/bus-ui/pkg/uiportal"
)

type ReportsPageProps struct {
    Host HostContext
    Rows []ReportRow
    Save func(ReportDraft)
}

func ReportsPage(props ReportsPageProps) gx.Node {
    return (
        <PortalShell
            title="Reports"
            hostContext={props.Host}
            nav={[]NavItem{{Label: "Reports", Path: "/"}}}
        >
            <ReportForm rows={props.Rows} onSubmit={props.Save}></ReportForm>
        </PortalShell>
    )
}
```
{% endraw %}

The same page can be exposed through `portal.UIFramework` by wrapping the GX
function in a deterministic Go renderer. The renderer receives host context
from `portal.UIRenderContext`, so tests and live module dispatch use the same
base paths.

```go
func renderReportsPage(ctx portal.UIRenderContext) gx.Node {
    return ReportsPage(ReportsPageProps{
        Host: HostContextFromPortal(ctx.HostContext),
        Rows: reportRows(ctx),
        Save: saveReportDraft,
    })
}
```

## Boundary

`PortalShell` may compose shared lower-level Bus UI pieces such as panels,
buttons, nav items, forms, and status tags. It should not perform provider API
calls, session validation, CSRF checks, logging transport, CSP construction, or
asset delivery. Those responsibilities belong to provider APIs, product module
handlers, or the portal host.

Browser actions originating inside the shell should be declared by the product
page as framework hooks. The module then projects observed Go/WASM events with
`ProjectFrameworkEvent` and only forwards the declared public fields.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Portal modules](./portal-modules)
- [Portal host contract](./portal-host-contract)
- [Expression children](../v0.1.5/expression-children)
- [bus-ui module reference](../../modules/bus-ui)
