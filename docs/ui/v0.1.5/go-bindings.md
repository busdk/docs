---
title: Bus UI v0.1.5 Go bindings
description: Patch roadmap for typed Go binding helpers that adapt arbitrary data to templates.
---

## Purpose

`v0.1.5` adds Go-first bindings. Bindings adapt any controller-provided data
shape into template props, text, loops, and component inputs without requiring
the template to know provider data structures. The primary runtime API is Go;
YAML and JSON binding files are portable fixture and import formats.

## Deliverables

1. Generate or expose typed Go binding functions from compiled GX entries.
2. Support field access, method access, literal values, defaults, scoped loop
   variables, and formatter functions in Go.
3. Keep the model value separate from the template source.
4. Support YAML and JSON binding files only as fixture/import formats that
   lower into the same Go binding model.
5. Validate missing required bindings and default behavior before render.

From the BusDK superproject root, initialize the required module checkouts:

```sh
git submodule update --init bus-gx bus-ui
```

Then install the `bus-gx` v0.1.5 implementation:

```sh
make -C bus-gx install
```

By default the install target writes `bus` under `$(HOME)/.local/bin`. Add it
to `PATH` before using `bus gx`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

The Go module that owns the UI package must also resolve
`github.com/busdk/bus-gx`. In the BusDK superproject workspace, use the local
`bus-gx` checkout through the workspace or a module-local `replace` during
development; do not fetch an unrelated remote version.

Use the workspace form from the BusDK superproject root when the UI module is
part of the same checkout. In a fresh checkout, initialize the workspace:

```sh
go work init ./bus-gx ./bus-ui
```

If `go.work` already exists, add the modules instead:

```sh
go work use ./bus-gx ./bus-ui
```

Use a module-local replace when working inside a single UI module checkout:

```sh
go mod edit -replace github.com/busdk/bus-gx=../bus-gx
```

From the Go module that owns the UI package, create `notes.gx` from this
minimal template or use the package's existing `.gx` file:

```gx
package notesui

var draftTitleTemplate = <Text value={draftTitle}></Text>
```

Create `bindings.go` beside `notes.gx`:

```go
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

type Draft struct {
	Title string
}

func BindDraft(d Draft) gx.Bindings {
	return gx.Bindings{
		"draftTitle": gx.Value(d.Title),
	}
}
```

Create `bindings_test.go` beside the binding helper:

```go
package notesui

import (
	"strings"
	"testing"

	"github.com/busdk/bus-gx/pkg/gx"
)

func TestDraftTitleBindings(t *testing.T) {
	html, err := RenderDraftTitleTemplate(BindDraft(Draft{Title: "April close"}))
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(html, "April close") {
		t.Fatalf("rendered html missing title: %s", html)
	}
}

func TestDraftTitleMissingBinding(t *testing.T) {
	_, err := RenderDraftTitleTemplate(gx.Bindings{})
	if err == nil {
		t.Fatal("expected missing draftTitle binding")
	}
}
```

Substitute the actual `.gx` path in the command. The path compiles the `.gx`
package, then runs ordinary Go tests against the generated entry and binding
helper:

```sh
bus gx compile notes.gx --output notes_gx.go

go test ./...
```

Missing required bindings fail `go test` through generated validation errors.
Fixture binding validation reports the same diagnostic shape as `bus gx lint`:
file, line, column, code, severity, and message.

Success means `bus gx compile` exits `0` and writes `notes_gx.go`, and
`go test ./...` exits `0` with a package test that calls the generated template
entry using `BindDraft(Draft{Title: "April close"})` and a second test that
asserts a missing required binding returns a generated validation error.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Binding concept](./binding)
- [Component concept](../v0.1.4/component)
