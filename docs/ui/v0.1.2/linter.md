---
title: GX linter
description: BusDK UI v0.1.2 bus gx lint command contract.
---

## Contract

`bus gx lint` validates `.gx` source without writing files. It rejects malformed
GX, duplicate declarations visible to this patch, unsafe lowercase attributes,
inline JavaScript handlers, invalid tag casing, and unsupported syntax.

`bus gx lint --format json` emits machine-readable diagnostics for agent
workflows. Valid source returns an empty diagnostics array. Source diagnostics
that block use in CI make the command exit non-zero.

The linter does not render, compile generated Go, load data, evaluate bindings,
run controller code, or validate browser behavior.

## Example

```sh
bus gx lint --format json hello.gx
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
