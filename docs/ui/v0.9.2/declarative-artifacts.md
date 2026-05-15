---
title: Declarative UI templates
description: Map from declarative UI artifacts to the versioned Bus UI contracts that define them.
---

## Purpose

Declarative Bus UI is Go-first. Template source, generated Go, model data,
bindings, controller code, runtime configuration, and fixture files remain
separate artifacts. The concrete syntax and validation rules live in the
version page where each artifact first appears.

## Design References

- [GX source tools](../v0.1.2/source-tools)
- [Binding](../v0.1.5/binding)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Versioned Contracts

| Artifact | First contract |
| --- | --- |
| Render tree library | [v0.1.1 Core foundation](../v0.1.1/) |
| GX source files, formatter, linter, and source diagnostics | [v0.1.2 GX source tools](../v0.1.2/) |
| Generated Go output and static render checks | [v0.1.3 GX compiler](../v0.1.3/) |
| Custom tags, component props, children, slots, and element adapters | [v0.1.4 custom components](../v0.1.4/) |
| Go bindings and portable binding fixtures | [v0.1.5 Go bindings](../v0.1.5/) |
| Go controllers and event identity | [v0.1.6 Go controllers and events](../v0.1.6/) |
| Lifecycle hooks and effects | [v0.1.7 lifecycle](../v0.1.7/) |
| Diagnostics beyond source linting | [v0.1.8 diagnostics](../v0.1.8/) |
| Browser safety blocks | [v0.1.9 browser safety blocks](../v0.1.9/) |
| Core test helpers | [v0.1.10 test helpers](../v0.1.10/) |
| Host resources and runtime config | [v0.4.1 runtime config](../v0.4.1/) |

## Artifact Split

A production UI package may contain `.gx` source, generated `.go` files,
ordinary Go controller code, and tests. Fixture data, binding, and runtime
documents are portable test/import artifacts; they do not replace the Go-first
controller path.

Single-file examples may exist as import/export sugar only after the versioned
contracts they rely on exist. The design contract remains separate template,
data, binding, and controller/runtime inputs.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Source-tool integration](../v0.1.3/source-tool-integration)
- [UI implementation roadmap](../)
