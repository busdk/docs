---
title: GX linter
description: BusDK UI v0.1.2 bus-gx lint command contract.
---

## Contract

`bus-gx lint` validates `.gx` source without writing files. It rejects
malformed GX, raw text content, duplicate declarations in the same file,
unsafe lowercase attributes, inline JavaScript handlers, invalid tag casing,
and unsupported syntax.

`bus-gx lint --format json` emits machine-readable diagnostics for agent
workflows. Valid source returns an empty diagnostics array. Source diagnostics
that block use in CI make the command exit non-zero.

Usage:

```sh
bus-gx lint [--format text|json] <file.gx>...
```

The command accepts one or more explicit `.gx` file paths. It does not read
stdin and does not expand directories. Shell globs are handled by the shell
before `bus-gx` starts; after expansion, every operand must be a readable file.

The linter does not render, compile generated Go, load data, evaluate bindings,
run controller code, or validate browser behavior.

The module binary also accepts `bus-gx gx lint` as a local alias for the future
`bus gx lint` dispatch shape.

## Example

```sh
bus-gx lint --format json hello.gx
```

The same source coordinate rules are used by human output and JSON output, so
agents can apply fixes without guessing at byte ranges.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source files](./source-files)
- [GX diagnostics](./diagnostics)
