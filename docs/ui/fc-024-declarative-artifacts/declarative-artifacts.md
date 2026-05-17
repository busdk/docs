---
title: GX and Go UI artifact inventory
description: Go-first Bus UI artifact inventory for GX source, generated Go, components, runtime inputs, and tests.
---

## Purpose

Bus UI authoring is Go-first. GX template source, generated Go, component
composition, callback code, runtime configuration, and fixture files remain
separate artifacts. The concrete syntax and validation rules live in the
version or feature-candidate page that owns each artifact.

FC-024 gives `bus-ui` a compact artifact inventory for those existing
contracts. The inventory helps a module, documentation page, or test fixture
name the artifacts that make up a UI package without introducing another
template language.

## Design References

- [GX source tools](../v0.1.2/source-tools)
- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Owner Boundary

`bus-gx` owns the source language and low-level runtime: `.gx` parsing,
formatting, linting, compilation to ordinary Go, render tree nodes, safe
intrinsic elements, component calls, callback props, lifecycle, diagnostics,
and core test helpers. `bus-ui` consumes those contracts through ordinary Go
packages.

The smallest FC-024 `bus-ui` code patch is an artifact inventory, not a
renderer. It can expose typed Go records for artifact kind, module owner,
source path, generated path, component references, validation command, and
fixture path. The records may be produced by Go package tests, examples, or a
local inspection helper, and they should be stable enough for docs and fixture
checks to compare.

The FC-024 patch does not parse GX, lower markup, render HTML, add a
`bus ui render` command, define a YAML or JSON schema for UI trees, or read a
descriptor file before an app can run. Data still reaches GX through ordinary
Go values, function arguments, and typed component props.

## Artifact Kinds

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
| Renderer test helpers | [UI testkit renderer](../v0.1.20/uikittest-renderer) |
| Runtime configuration | [Runtime config](../fc-004-runtime-config-api-urls/runtime-config) |
| Resource declarations | [Resource UI runtime block](../v0.4.1/resource-component) |
| Runtime fixture documents | [v0.4.1 runtime contract](../v0.4.1/runtime-contract) |

## Go Inventory Shape

A production UI package may contain `.gx` source, generated `.go` files,
ordinary Go callback code, typed view-model fixtures, and tests. The inventory
describes those files so humans and tools can see which versioned contract owns
each artifact.

```go
package notesui

import "github.com/busdk/bus-ui/pkg/uiartifact"

var Artifacts = []uiartifact.Artifact{
    {
        Kind:      uiartifact.GXSource,
        Owner:     "bus-notes",
        Source:    "internal/ui/notes_page.gx",
        Generated: "internal/ui/notes_page.go",
        Contracts: []string{
            "ui/v0.1.2/source-files",
            "ui/v0.1.3/generated-go",
            "ui/v0.1.4/component-functions",
        },
    },
    {
        Kind:      uiartifact.RenderFixture,
        Owner:     "bus-notes",
        Source:    "internal/ui/testdata/notes-review_data_test.go",
        Generated: "internal/ui/testdata/notes-review.golden.html",
        Contracts: []string{
            "ui/v0.1.20/uikittest-renderer",
        },
    },
}
```

A product module can keep the inventory near its UI package and assert it in
tests without changing how the module renders.

## Example Package

GX source remains the human-authored view:

```gx
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

type NotesPageProps struct {
    Rows []NoteRow
    Save func(NoteDraft)
}

func NotesPage(props NotesPageProps) gx.Node {
    return (
        <section>
            <NoteTable rows={props.Rows}></NoteTable>
            <NoteForm onSubmit={props.Save}></NoteForm>
        </section>
    )
}
```

Generated Go remains a normal `.go` artifact produced from that source.
Fixture data remains typed Go beside tests:

```go
package notesui

var notesReviewFixture = NotesPageProps{
    Rows: []NoteRow{
        {ID: "note-2026-05-17-001", Title: "May review"},
    },
    Save: saveFixtureDraft,
}
```

Runtime configuration may be JSON-serializable when the runtime contract
requires browser delivery, and fixture documents may use data formats owned by
their specific contract. Those files carry data or configuration only; they are
not a YAML-first or JSON-first UI renderer.

## Result

FC-024 is the small `bus-ui` surface that records and validates artifact
inventory for existing GX/Go packages. More capable import/export formats can
be added only when a later contract names the data format, owner, validation
rules, and runtime behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Source-tool integration](../v0.1.3/source-tool-integration)
- [Generated Go](../v0.1.3/generated-go)
- [UI testkit renderer](../v0.1.20/uikittest-renderer)
- [UI implementation roadmap](../)
