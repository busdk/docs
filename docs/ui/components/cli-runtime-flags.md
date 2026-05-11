---
title: CLIRuntimeFlags UI runtime block
description: Dedicated BusDK UI reference for CLIRuntimeFlags.
---

## Purpose

`CLIRuntimeFlags` is a CLI/tooling runtime block. Standard CLI flag behavior. Use for `bus-ui` tools and related commands.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `args` | yes | string array | Subcommand and arguments after the executable name; do not include `bus-ui`. |
| `output` | no | path | Output file; with `quiet: true`, normal output and file writes are suppressed. |
| `format` | no | html, json, inventory, diagnostics | `render` accepts `html` or `json` and defaults to `html`; `inspect` accepts `inventory` or `diagnostics` and defaults to `inventory`. Other commands reject `format`. |
| `quiet` | no | boolean | Suppresses normal output; conflicts with non-zero `verbose`. |
| `verbose` | no | integer 0-3 or boolean | Default `0`; `true` equals `1`. Values above `3` fail validation. |
| `color` | no | auto, always, never | Default `auto`; applies only to diagnostics. |
| `chdir` | no | path | Working directory applied before resolving document and output paths. |

## Boundary

Results go to stdout/output; diagnostics go to stderr.

## Example

```yaml
kind: CLIRuntimeFlags
props:
  args: [render, sample.yml]
  output: sample.html
  format: html
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./css-bundle">CSSBundle</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./browser-open">BrowserOpen</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
