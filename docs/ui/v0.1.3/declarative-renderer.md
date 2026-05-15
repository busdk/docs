---
title: DeclarativeRenderer UI runtime block
description: Dedicated BusDK UI reference for DeclarativeRenderer.
---

## Purpose

`DeclarativeRenderer` is a CLI/tooling runtime block for static GX render
checks. In `v0.1.3` it compiles a `.gx` package and renders a named template
entry to deterministic HTML.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `template` | yes | path | Accepts a `*.gx` template path resolved from the current working directory. Missing files, invalid syntax, or an invalid compiled shape fail renderer input validation. |
| `entry` | yes | template name | Selects the template value to render. Unknown entries fail renderer input validation before output. |
| `format` | no | html | Default `html`; this version only defines static HTML output. |

## Boundary

Output settings are command or host config, not template fields. Data,
bindings, controllers, runtime fixtures, inventory output, binding validation,
and browser validation are not part of this version. Renderer input validation
only checks the template path, syntax, compiled shape, entry name, and output
format needed to run this static render check.

## Example

This static render example assumes the file lives in the current working
directory.

```yaml
template: notes.gx
entry: notesReview
format: html
```

This is the shape of a host renderer config file such as
`testdata/ui/render.yml`. The equivalent renderer command is:

```sh
bus gx render notes.gx --entry notesReview --format html
```

By default the command writes deterministic HTML to stdout and exits `0`.
Success is verified by comparing stdout to the expected escaped HTML and by
checking that stderr has no diagnostics.

Related source tooling is `bus gx fmt --check`, `bus gx lint`, and
`bus gx compile`; those commands are not renderer configuration.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX compiler](./compiler)
- [GX tooling](./gx-tooling)
