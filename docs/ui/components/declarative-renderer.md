---
title: DeclarativeRenderer UI runtime block
description: Dedicated BusDK UI reference for DeclarativeRenderer.
---

## Purpose

`DeclarativeRenderer` is a CLI/tooling runtime block. JSON/YAML UI renderer. Use for samples, fixtures, validation, and docs examples.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `document` | yes | path or parsed data | Accepts a `bus-ui/v1` YAML/JSON path resolved from the current working directory, or an already parsed document object. Missing files, invalid syntax, or invalid shape fail validation. |
| `format` | no | html, json, inventory, diagnostics | Default `html`; `json` emits normalized tree, `inventory` emits component usage, and `diagnostics` emits validation findings. |
| `validate` | no | boolean | Default `false`. When true, rendering is skipped; valid input exits successfully with diagnostics output empty, invalid input reports diagnostics and fails. |

## Boundary

Output settings are command or host config, not document fields.

## Example

```yaml
document: sample.yml
format: html
```

This is the shape of a host renderer config file such as
`testdata/ui/render.yml`. The equivalent command invocation is:

```sh
bus-ui render sample.yml --format html
```

Both forms are command or host configuration for the renderer, not UI document
nodes.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./browser-open">BrowserOpen</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../component-reference">Component reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
