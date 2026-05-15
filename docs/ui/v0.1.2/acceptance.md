---
title: GX source tool acceptance
description: BusDK UI v0.1.2 public acceptance checks.
---

## Checks

This patch is complete when a `.gx` file can be formatted and linted without
requiring the later compiler or runtime patches.

Save this minimal file as `hello.gx`:

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

With BusDK commands on `PATH`, the expected public checks are:

```sh
bus gx fmt --check hello.gx

bus gx lint --format json hello.gx
```

`bus gx fmt --check` accepts canonical source. `bus gx fmt` rewrites
non-canonical whitespace without changing meaning. `bus gx lint --format json`
returns stable empty diagnostics for valid source and stable source locations
for invalid source.

Module-local tests may call `./bin/bus-gx gx fmt` and `./bin/bus-gx gx lint`
after `make build`, but user-facing commands go through the `bus` dispatcher.

Raw text content is invalid in this patch:

```gx
package notesui

var bad = <p>Hello Bus</p>
```

Formatting and linting must report a diagnostic for that file rather than
dropping the text.

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
