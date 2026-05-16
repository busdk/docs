---
title: Declarative UI templates
description: Map from declarative UI artifacts to the versioned Bus UI contracts that define them.
---

## Purpose

Declarative Bus UI is Go-first. Template source, generated Go, component
composition, callback code, runtime configuration, and fixture files remain
separate artifacts. The concrete syntax and validation rules live in the
version page where each artifact first appears.

## Design References

- [GX source tools](../v0.1.2/source-tools)
- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Versioned Contracts

| Artifact | First contract |
| --- | --- |
| Render tree library | [v0.1.1 Core foundation](../v0.1.1/) |
| GX source files, formatter, linter, and source diagnostics | [v0.1.2 GX source tools](../v0.1.2/) |
| Generated Go output | [v0.1.3 GX compiler](../v0.1.3/) |
| Go WebAssembly app acceptance | [v0.1.11 WASM app acceptance](../v0.1.11/) |
| Uppercase component calls and typed props | [v0.1.4 component calls](../v0.1.4/) |
| Component body markup and children | [v0.1.5 Component composition](../v0.1.5/) |
| Function callback props | [v0.1.6 callback props](../v0.1.6/) |
| Go WebAssembly frontend runtime | [v0.1.7 frontend runtime](../v0.1.7/) |
| Runtime diagnostics | [v0.1.8 runtime diagnostics](../v0.1.8/) |
| Browser API boundaries | [v0.1.9 browser API boundaries](../v0.1.9/) |
| Core test helpers | [v0.1.10 test helpers](../v0.1.10/) |
| Host resources and runtime config | [fc-003 runtime config](../fc-003-resources/) |

## Artifact Split

A production UI package may contain `.gx` source, generated `.go` files,
ordinary Go callback code, and tests. Fixture data and runtime documents are
portable test/import artifacts; they do not replace the Go-first application
path.

Single-file examples may exist as import/export sugar only after the versioned
contracts they rely on exist. The design contract remains separate template,
data, and callback/runtime inputs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Source-tool integration](../v0.1.3/source-tool-integration)
- [UI implementation roadmap](../)
