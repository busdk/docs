---
title: Portal modules
description: How BusDK product UI modules expose deterministic Go-first GX pages through the portal framework contract.
---

## Overview

A portal module is a product UI surface mounted by `bus-portal`. The host owns
module launch, shared assets, security headers, token-aware routing, and
metadata. The product module owns DTO projection, view models, page renderers,
event hooks, copy, permission display, provider clients, and product routes.

The integration point is Go. Existing modules implement `portal.Module`; modules
that render through shared Bus UI primitives can also implement
`portal.FrameworkModule`. The framework contract lets a product module declare
server-rendered pages and matching browser hooks without moving product policy
into the host or into a separate descriptor language.

## Framework Pages

`portal.UIFramework` is the compact Go declaration for GX-ready pages. Each
`UIPage` has a stable name, module-relative path, mount ID, deterministic Go
renderer, and optional typed browser hooks. The declaration is metadata about
Go renderers and Go/WASM event projection; it is not a YAML or JSON UI tree.

```go
func (ReportsModule) UIFramework() portal.UIFramework {
    return portal.UIFramework{
        DefaultRenderPageName: "main",
        PublicRuntimeConfig: map[string]string{
            "api_base": "/api/v1/reports",
        },
        ProviderAPIOrigins: []string{"https://api.example"},
        Pages: []portal.UIPage{
            {
                Name:    "main",
                Path:    "/",
                MountID: "reports-root",
                Render:  renderReportsPage,
                Hooks: []portal.BrowserEffect{
                    {
                        Name:     "save",
                        Kind:     "form",
                        Event:    "submit",
                        Action:   "save-report",
                        TargetID: "reports-form",
                        Fields:   []string{"title", "amount"},
                    },
                },
            },
        },
    }
}
```

The renderer receives `portal.UIRenderContext`, including
[`HostContext`](./portal-host-contract), the selected page, and a Bus UI render
runtime. Its output must be deterministic for the same inputs so module tests
can compare server HTML directly.

```go
func renderReportsPage(ctx portal.UIRenderContext) gx.Node {
    props := ReportsPageProps{
        Host: uiportal.HostContextFromPortal(ctx.HostContext),
        Rows: reportRows(ctx),
        Save: saveReportDraft,
    }
    return ReportsPage(props)
}
```

When a module needs an HTML boundary, render the returned node with
`uiportal.RenderHTML`, `assistantui.RenderHTML`, `terminalui.RenderHTML`, or
`ui.RenderHTML` at the page edge. New framework pages should use typed Go
components and `.gx` source over `BodyNodes` assembly.

GX source can wrap the same shape with typed props when a module page is written
as `.gx`. Data still arrives as ordinary Go values.

```gx
func ReportsPage(props ReportsPageProps) gx.Node {
    return (
        <PortalShell title="Reports" hostContext={props.Host}>
            <ReportForm rows={props.Rows} onSubmit={props.Save}></ReportForm>
        </PortalShell>
    )
}
```

## Event Projection

Browser behavior is declared as typed Go hooks and projected through fixture-tested
helpers. `portal.ProjectFrameworkEvent` selects a declared page and hook,
checks that the observed browser event and action match the declaration, and
returns only the fields named by the hook.

```go
projected, err := portal.ProjectFrameworkEvent(module, portal.BrowserEvent{
    Page:   "main",
    Hook:   "save",
    Event:  "submit",
    Action: "save-report",
    Values: map[string]string{
        "title":      "Q2",
        "amount":     "42",
        "csrf_token": "not-projected",
    },
})
if err != nil {
    return err
}
```

The projected payload contains `title` and `amount`; undeclared fields are not
part of the public event payload. This keeps broad browser e2e focused on host
startup and mounted module navigation while module unit fixtures prove render
output and event projection.

## Local And Hosted Apps

Local app-style UIs and portal-mounted modules should share the same Bus UI
building blocks where the behavior is reusable. A local app may own its shell
and browser startup, while a portal module receives host context and route
mounting from `bus-portal`. Forms, tables, assistant panels, terminal panes,
evidence links, event routing, and runtime helpers should stay in shared Bus UI
or product module packages according to ownership.

The host does not become a provider facade. Auth, billing, LLM access,
container lifecycle, terminal sessions, uploads, accounting workspace reads,
report generation, and artifact access stay behind provider APIs and their
product modules.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Product module shape](./product-module-shape)
- [Portal host contract](./portal-host-contract)
- [Portal shell](./portal-shell)
- [bus-portal module reference](../../modules/bus-portal)
- [bus-ui module reference](../../modules/bus-ui)
