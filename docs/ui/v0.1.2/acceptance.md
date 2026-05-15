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

From the `bus-gx` module root, the expected public checks are:

```sh
make build

bus-gx fmt --check hello.gx

bus-gx lint --format json hello.gx
```

Run those commands with `bus-gx` on `PATH`, or replace `bus-gx` with
`./bin/bus-gx` after `make build`.

`bus-gx fmt --check` accepts canonical source. `bus-gx fmt` rewrites
non-canonical whitespace without changing meaning. `bus-gx lint --format json`
returns stable empty diagnostics for valid source and stable source locations
for invalid source.

The module binary also accepts the local aliases `bus-gx gx fmt` and
`bus-gx gx lint` so e2e tests can exercise the future `bus gx` dispatch shape.

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
