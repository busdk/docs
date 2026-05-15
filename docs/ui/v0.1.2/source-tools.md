---
title: Bus UI v0.1.2 GX source tools
description: Patch roadmap for the first GX parser, formatter, linter, and diagnostic command surface.
---

## Purpose

`v0.1.2` adds the first `.gx` source toolchain on top of the `v0.1.1` node
foundation. It exists to deliver `bus gx fmt` and `bus gx lint`.

`bus-gx` owns the `bus gx` command surface and the low-level GX libraries that
parse and validate source.

## Source Shape

A `.gx` file is a normal Go package with GX markup literals in declarations,
functions, or methods. It does not use a required top-level `<Template>`
wrapper. The parser preserves tag case and source locations so formatter and
linter diagnostics can point to exact ranges.

The preferred human-authored UI format is `.gx`, not a YAML or JSON component
tree. YAML and JSON are still useful later for fixture data and fixture
bindings, but template structure is written as HTML-like markup inside Go
source so generated code, controller code, and editor tooling can share the Go
package boundary.

The first source tools only understand enough markup to validate safe static
structure against the [v0.1.1 node foundation](../v0.1.1/). Lowercase tags
resolve to safe HTML element names. Uppercase tags are recognized as component
syntax, but reusable component declarations and registry resolution are not
implemented in this version.

The source language is constrained to safe structural markup and Go values. It
does not run browser JavaScript, Go templates, shell commands, provider calls,
or a separate expression runtime.

## Deliverables

1. Parse `.gx` files as Go source with GX markup literals embedded in normal
   declarations, functions, and methods.
2. Provide `bus gx fmt`, `bus gx fmt --check`, `bus gx lint`, and `bus gx lint
   --format json`.
3. Emit deterministic file, line, column, code, severity, and message
   diagnostics for agent workflows.
4. Reject malformed GX, duplicate declarations, unsafe lowercase attributes,
   inline JavaScript handlers, invalid tag casing, and unsupported syntax.
5. Keep data, bindings, runtime config, and controller code outside the
   template source.

## Minimal Template

```gx
package notesui

var hello = <p><Text value={"Hello Bus"}></Text></p>
```

The first successful implementation formats and lints this file. Rendering is
outside this version.

## Commands

Run these commands from the BusDK superproject root. First populate the
`bus-gx` checkout:

```sh
git submodule update --init bus-gx
```

Install or build the `bus-gx` v0.1.2 implementation that provides `bus gx`:

```sh
make -C bus-gx install
```

Verify the command surface before running source checks. The installed binary
defaults to `$(HOME)/.local/bin/bus`, so add that directory to `PATH` before
running `bus gx version`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

```sh
bus gx version
```

Save the minimal template as `hello.gx`, then run:

```sh
bus gx fmt --check hello.gx

bus gx lint --format json hello.gx
```

The success check is narrow: `bus gx fmt --check` accepts canonical source,
`bus gx fmt` rewrites non-canonical whitespace without changing meaning, and
`bus gx lint --format json` returns stable empty diagnostics for valid source
and stable source locations for invalid source.

`bus gx fmt --check` exits `0` when the file is canonical and `1` when it
would change. `bus gx fmt` exits `0` after a successful rewrite and non-zero
when parsing fails before any file is rewritten. `bus gx lint` exits `0` when
there are no diagnostics at error severity and non-zero when source diagnostics
block use in CI.

## Diagnostic Shape

Diagnostics include `file`, `line`, `column`, `endLine`, `endColumn`, `code`,
`severity`, `message`, and optional `fix` fields. A fix contains a replacement
range and replacement text. Fixes must be small, deterministic, and safe to
apply independently; formatting-only fixes belong to `bus gx fmt`.

Diagnostic positions are 1-based UTF-8 source coordinates. `line` and `column`
point at the first byte of the diagnostic range. `endLine` and `endColumn` are
exclusive: they point immediately after the last byte in the range. A single
character diagnostic on line 3, column 5 therefore ends at line 3, column 6.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Node concept](../v0.1.1/node)
- [Shared interfaces](../v0.1.1/interfaces)
