---
title: GX source tool acceptance
description: BusDK UI v0.1.2 public acceptance checks.
---

## Checks

This patch is complete when a `.gx` file can be formatted and linted without
requiring the later compiler or runtime patches.

Use this minimal file:

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

The expected public checks are:

```sh
bus gx fmt --check hello.gx

bus gx lint --format json hello.gx
```

`bus gx fmt --check` accepts canonical source. `bus gx fmt` rewrites
non-canonical whitespace without changing meaning. `bus gx lint --format json`
returns stable empty diagnostics for valid source and stable source locations
for invalid source.

Rendering this file is outside v0.1.2.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [GX source files](./source-files)
- [GX formatter](./formatter)
- [GX linter](./linter)
