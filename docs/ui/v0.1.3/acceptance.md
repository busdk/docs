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

bus gx compile hello.gx --output hello.go

go test ./...
```

Each command must exit `0`. `lint --format json` must print an empty
diagnostics array. `compile` must write `hello.go`. `go test ./...` must
pass with that generated file present. After the acceptance check, remove
`hello.gx` and `hello.go` unless they are committed test fixtures.

Compiler tests compare generated Go against stable golden files, run Go tests
against generated output, and verify compile failures leave no output file.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Compile command](./compile-command)
- [Generated Go](./generated-go)
