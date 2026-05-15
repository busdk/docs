---
title: Compiler acceptance
description: BusDK UI v0.1.3 public acceptance checks.
---

## Checks

Run these checks from a `bus-gx` checkout with Go available and `v0.1.2`
source tools already implemented. The working directory is the `bus-gx` module
root.

Save this file as `hello.gx` in the `bus-gx` module root:

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

With BusDK commands on `PATH`, run:

```sh
bus gx fmt --check hello.gx

bus gx lint --format json hello.gx

bus gx compile hello.gx --output hello_gx.go

go test ./...

bus gx render hello.gx --entry hello --format html
```

Each command must exit `0`. `lint --format json` must print an empty
diagnostics array. `compile` must write `hello_gx.go`. `go test ./...` must
pass with that generated file present. After the acceptance check, remove
`hello.gx` and `hello_gx.go` unless they are committed test fixtures.

The render output is deterministic HTML:

```html
<p>Hello Bus</p>
```

Compiler tests compare generated Go against stable golden files, run Go tests
against generated output, and compare exact render output with stable attribute
order.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Compile command](./compile-command)
- [Static render](./static-render)
