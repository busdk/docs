---
title: AppShell UI component
description: Dedicated BusDK UI reference for AppShell.
---

## Purpose

`AppShell` is a shell/layout component. Standard local application frame. Use for local app-style servers and Go WebAssembly tools.

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
    props:
      title: Workspace
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

Resource defines safe URL resolution, external-origin allowlists, and rejected URL forms.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
