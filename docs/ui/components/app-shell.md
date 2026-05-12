---
title: AppShell UI component
description: Dedicated BusDK UI reference for AppShell.
---

## Purpose

`AppShell` is a shell/layout component. Standard local application frame. Use for local app-style servers and Go/WASM tools.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `title` | yes | string or binding | Sets page title. |
| `body` | yes | slot node | Main content. |
| `nav` | no | slot node or `{label,href,active}` array | Default empty navigation; item `label` and `href` are required, `active` is optional boolean defaulting false. `href` must be same-origin path or an `https:` URL whose origin appears in host runtime config `externalNavOrigins`, an array of exact origins such as `https://docs.example.com`. |
| `runtimeConfig` | no | public object | Default empty object. Values must be public and JSON-serializable. |
| `assetURLs` | no | `{css,wasm}` object | Both members are optional same-origin paths; omitted members use host defaults. |

## Boundary

The shell renders local chrome only. Provider policy means auth checks,
permission decisions, account eligibility, and API authorization; those remain
in provider/API modules and product view models.

## Example

```yaml
kind: AppShell
props:
  title: Local workspace
slots:
  body:
    kind: Panel
    props: { title: Workspace }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./template">Template</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./portal-shell">PortalShell</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
