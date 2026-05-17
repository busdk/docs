---
title: GX and Go UI artifact metadata
description: Go-first Bus UI artifact metadata for GX source, generated Go, components, runtime inputs, and tests.
---

## Purpose

Bus UI authoring is Go-first. [GX source files](../v0.1.2/source-files),
generated Go, component composition, callback code, runtime configuration, and
fixture files remain separate artifacts. The concrete syntax and validation
rules live in the version or feature-candidate page that owns each artifact.

FC-024 gives `bus-ui` compact typed metadata for those existing contracts. The
metadata helps a module, documentation page, or test fixture name the artifacts
that make up a UI package without introducing another template language,
renderer, descriptor file, or YAML/JSON UI format.

## Design References

- [GX source tools](../v0.1.2/source-tools)
- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)
- [UI component map](../fc-023-component-catalog/component-map)

## Owner Boundary

`bus-gx` owns the source language and low-level runtime: `.gx` parsing,
formatting, linting, compilation to ordinary Go, render tree nodes, safe
intrinsic elements, component calls, callback props, lifecycle, diagnostics,
and core test helpers. `bus-ui` consumes those contracts through ordinary Go
packages.

The smallest FC-024 `bus-ui` code patch is local typed artifact metadata plus
validation. It builds on [FC-023 component catalog](../fc-023-component-catalog/)
metadata by referencing known component names or catalog entries instead of
redeclaring component props, groups, or rendering behavior. The `bus-ui`
metadata may record artifact kind, module owner, source path, generated path,
component references, validation command, and fixture path.

The metadata can be produced by Go package tests, examples, or a local
inspection helper. The small validation API is
`uiartifact.ValidateArtifacts`, where `uicatalog.Catalog` is the FC-023
component catalog metadata for the package or module:

```go
package uiartifact

import "github.com/busdk/bus-ui/pkg/uicatalog"

func ValidateArtifacts(artifacts []Artifact, catalog uicatalog.Catalog) error
```

The function returns `nil` when every artifact is internally consistent and
returns diagnostic errors when paths use the wrong artifact kind, generated Go
lacks a matching GX source, component references do not resolve through the
FC-023 catalog, or declared validation commands do not match the artifact
owner.

The FC-024 patch does not parse GX, lower markup, render HTML, add a
`bus ui render` command, define a YAML or JSON schema for UI trees, or load a
descriptor before an app can run. Data still reaches GX through ordinary Go
values, function arguments, and typed component props.

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

## Go Metadata Shape

A production UI package may contain `.gx` source, generated `.go` files,
ordinary Go callback code, typed view-model fixtures, and tests. The metadata
describes those files so humans and tools can see which versioned contract owns
each artifact.

| Artifact label | `uiartifact.Kind` |
| --- | --- |
| GX source files | `GXSource` |
| Generated Go output | `GeneratedGo` |
| Go callback or view-model code | `GoSource` |
| Runtime configuration | `RuntimeConfig` |
| Resource declarations | `ResourceDeclaration` |
| Typed runtime metadata | `RuntimeFixture` |
| Renderer test helpers | `RenderFixture` |

| Field | Required | Constraint |
| --- | --- | --- |
| `Kind` | yes | One of the `uiartifact.Kind` constants implemented by FC-024. |
| `Owner` | yes | Bus module or Go package owner for the artifact. |
| `Source` | yes | Repository-local path with an extension that matches `Kind`, such as `.gx`, `.go`, or a typed metadata fixture extension owned by the linked contract. |
| `Generated` | kind-specific | Required for `GXSource` that compiles to Go and for `RenderFixture` with golden output; omitted for `GeneratedGo`, `GoSource`, `RuntimeConfig`, and `ResourceDeclaration`. |
| `Components` | no | Uppercase component names that resolve through the FC-023 component catalog metadata available to validation. |
| `ValidationCommand` | no | Copyable repository-local command for this artifact, such as `bus gx lint internal/ui/notes_page.gx`; validation rejects commands outside the artifact owner or commands that use another module's path. |
| `Contracts` | yes | UI version or feature-candidate contract paths that define the artifact syntax and validation expectations. |

```go
package notesui

import "github.com/busdk/bus-ui/pkg/uiartifact"

var Artifacts = []uiartifact.Artifact{
    {
        Kind:      uiartifact.GXSource,
        Owner:     "bus-notes",
        Source:    "internal/ui/notes_page.gx",
        Generated: "internal/ui/notes_page.go",
        Components: []string{
            "NoteTable",
            "NoteForm",
        },
        ValidationCommand: "bus gx lint internal/ui/notes_page.gx",
        Contracts: []string{
            "ui/v0.1.2/source-files",
            "ui/v0.1.3/generated-go",
            "ui/v0.1.4/component-functions",
            "ui/fc-023-component-catalog/component-map",
        },
    },
    {
        Kind:      uiartifact.RenderFixture,
        Owner:     "bus-notes",
        Source:    "internal/ui/testdata/notes-review_data_test.go",
        Generated: "internal/ui/testdata/notes-review.golden.html",
        ValidationCommand: "go test ./internal/ui",
        Contracts: []string{
            "ui/v0.1.20/uikittest-renderer",
        },
    },
}
```

A product module can keep the metadata near its UI package and assert it in
tests without changing how the module renders. The record is metadata about
GX/Go artifacts that already exist; it is not the source of the UI tree.

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

When a later contract needs portable artifact metadata outside a Go package, it
should still describe existing typed artifacts rather than becoming an
alternate template surface. The owner of that later contract must define the
file format, allowed fields, validation command, and runtime behavior next to
the feature that consumes it.

## Result

FC-024 is the small `bus-ui` surface that records and validates local typed
artifact metadata for existing GX/Go packages. Public examples should use GX or
Go unless the page is specifically documenting data or configuration in another
format. More capable import/export formats can be added only when a later
contract names the data format, owner, validation rules, and runtime behavior.

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
