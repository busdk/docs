---
title: CLIRuntimeFlags UI runtime block
description: Dedicated BusDK UI reference for CLIRuntimeFlags.
---

## Purpose

`CLIRuntimeFlags` is a CLI/tooling runtime block. Standard CLI flag behavior.
Use for `bus gx` tools and related commands.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `args` | yes | string array | Subcommand and arguments after `bus gx`; do not include `bus` or `gx`. Supported UI-tool subcommands include `fmt`, `lint`, `validate`, and `inspect`. |
| `output` | no | path | Default omitted, which writes normal command output to stdout. When set, writes normal output to that file. With `quiet: true`, normal stdout and `--output` writes are suppressed; input file rewrites still follow the subcommand contract. |
| `format` | no | json, inventory, diagnostics | `inspect` accepts `inventory`, `diagnostics`, or `json` and defaults to `inventory`; `lint` and `validate` accept human diagnostics by default and machine-readable `json`; `fmt` rejects `format`. |
| `check` | no | boolean | Applies only to `fmt`. Default false rewrites files in place; true exits non-zero when any GX file is not canonical and does not write files. |
| `quiet` | no | boolean | Default false. When true, suppresses normal output; conflicts with non-zero `verbose`. |
| `verbose` | no | integer 0-3 or boolean | Default `0`; `true` equals `1`. Values above `3` fail validation. |
| `color` | no | auto, always, never | Default `auto`; applies only to diagnostics. |
| `chdir` | no | path | Default current directory. When set, this working directory is applied before resolving template, controller, data, and output paths. |

## Boundary

Results go to stdout/output; diagnostics go to stderr.
`fmt` writes changed GX files unless `check` is true. `lint`, `inspect`, and
`validate` write diagnostics or inventory and do not modify inputs.

## Example

```gx
package localui

var fmtFlags = (
  <CLIRuntimeFlags args={[]string{"fmt", "notes.gx"}} check={true}></CLIRuntimeFlags>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [Source-tool integration](../v0.1.3/source-tool-integration)
