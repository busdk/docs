---
title: CLIRuntimeFlags
description: Shared Bus UI host-tool flag behavior for GX commands.
---

## Purpose

`CLIRuntimeFlags` describes the shared host-tool flag behavior used by `bus gx`
commands. A tool can accept these props when it exposes formatting, linting,
inspection, or validation from a GX-backed local workflow.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `args` | yes | `[]string` | Subcommand and arguments after `bus gx`; do not include `bus` or `gx`. Supported UI-tool subcommands include `fmt`, `lint`, `validate`, and `inspect`. |
| `output` | no | path | Default omitted, which writes normal command output to stdout. When set, writes normal output to that file. With `quiet: true`, normal stdout and `--output` writes are suppressed; input file rewrites still follow the subcommand contract. |
| `format` | no | json, inventory, diagnostics | `inspect` accepts `inventory`, `diagnostics`, or `json` and defaults to `inventory`; `lint` and `validate` accept human diagnostics by default and machine-readable `json`; `fmt` rejects `format`. |
| `check` | no | boolean | Applies only to `fmt`. Default false rewrites files in place; true exits non-zero when any GX file is not canonical and does not write files. |
| `quiet` | no | boolean | Default false. When true, suppresses normal output; conflicts with non-zero `verbose`. |
| `verbose` | no | integer 0-3 or boolean | Default `0`; `true` equals `1`. Values above `3` fail validation. |
| `color` | no | auto, always, never | Default `auto`; applies only to diagnostics. |
| `chdir` | no | path | Default current directory. When set, this working directory is applied before resolving template, controller, data, and output paths. |

## Boundary

Results go to stdout or the requested output file. Diagnostics go to stderr.
`fmt` may rewrite GX files unless `check` is true. `lint`, `inspect`, and
`validate` report diagnostics or inventory and leave inputs unchanged.

## Example

```gx
package localui

var formatCheck = (
  <CLIRuntimeFlags
    args={[]string{"fmt", "views/summary.gx"}}
    check={true}>
  </CLIRuntimeFlags>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Source-tool integration](../v0.1.3/source-tool-integration)
