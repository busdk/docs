---
title: GX and Go UI artifacts
description: Map from GX and Go UI artifacts to the versioned Bus UI contracts that define them.
---

## Purpose

Bus UI authoring is Go-first. GX template source, generated Go, component
composition, callback code, runtime configuration, and fixture files remain
separate artifacts. The concrete syntax and validation rules live in the
version or feature-candidate page that owns each artifact.

## Design References

- [GX source tools](../v0.1.2/source-tools)
- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract Owners

| Artifact | Owning page |
| --- | --- |
| Render tree library | [Render tree contract](../v0.1.1/render-tree-contract) |
| GX source files | [GX source files](../v0.1.2/source-files) |
| Formatter and linter commands | [GX source tools](../v0.1.2/source-tools) |
| Source diagnostics | [GX diagnostics](../v0.1.2/diagnostics) |
| Generated Go output | [Generated Go output](../v0.1.3/generated-go) |
| Go WebAssembly app acceptance | [WASM app acceptance](../v0.1.11/wasm-app) |
| Uppercase component calls and typed props | [Component functions](../v0.1.4/component-functions) |
| Component body markup | [Component body markup](../v0.1.5/component-body-markup) |
| Component children | [Component children](../v0.1.5/component-children) |
| Function callback props | [Callback props](../v0.1.6/callback-props) |
| Go WebAssembly frontend runtime | [Mounting and updates](../v0.1.7/mounting-updates) |
| Runtime diagnostics | [Runtime errors](../v0.1.8/runtime-errors) |
| Browser API boundaries | [Browser API boundaries](../v0.1.9/browser-api-boundaries) |
| Core test helpers | [Core test helpers](../v0.1.10/test-helpers) |
| Fixture data for UI tests | [Testing UI apps](../fc-026-examples-testing-release-review/testing-guide) |
| Runtime configuration | [Runtime config](../fc-004-runtime-config-api-urls/runtime-config) |
| Resource declarations | [Resource UI runtime block](../v0.4.1/resource-component) |
| Runtime fixture documents | [v0.4.1 runtime contract](../v0.4.1/runtime-contract) |

## Artifact Split

A production UI package may contain `.gx` source, generated `.go` files,
ordinary Go callback code, and tests. Fixture data and runtime documents are
portable test/import artifacts; they do not replace the Go-first application
path.

Single-file examples may exist as import/export sugar only after the versioned
contracts they rely on exist. The design contract remains separate GX source,
typed Go data, and callback/runtime inputs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Source-tool integration](../v0.1.3/source-tool-integration)
- [UI implementation roadmap](../)
