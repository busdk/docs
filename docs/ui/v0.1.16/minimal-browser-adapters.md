---
title: Minimal browser adapters
description: BusDK UI v0.1.16 narrow Go WebAssembly adapters for browser APIs.
---

## Contract

`v0.1.16` adds narrow Go APIs for browser features that cannot be represented
as plain GX nodes. The adapters live behind the Go WebAssembly browser
boundary from [v0.1.9](../v0.1.9/browser-api-boundaries), and higher-level UI
libraries call them from ordinary Go.

The minimal adapter set is:

- form value extraction
- file input access
- browser key-value storage

## Form Values

Form values are read from a submitted form or a mounted form element through a
Go API. The adapter returns ordinary Go data and does not require string event
names.

```go
func save(event gx.SubmitEvent) {
	values, err := gxwasm.FormValues(event)
	if err != nil {
		report(err)
		return
	}
	title := values.Get("title")
	_ = title
}
```

The form adapter should preserve repeated field names. It should expose
string values first; multipart file content belongs to the file adapter.

## Files

File input access returns safe metadata and a Go reader handle for selected
files. Product code still owns size limits, MIME validation, authorization, and
upload policy.

```go
func attach(event gx.ChangeEvent) {
	files, err := gxwasm.Files(event)
	if err != nil {
		report(err)
		return
	}
	_ = files
}
```

The adapter must not expose raw JavaScript file objects outside the browser
package boundary.

## Storage

Browser storage is exposed as a small key-value interface for non-secret
client preferences and session markers. Tokens and credentials must remain
owned by the application security layer.

```go
store := gxwasm.SessionStorage()
_ = store.Set("sidebar", "collapsed")
```

Storage adapters must be optional. Tests can provide in-memory fakes, and
server-side rendering must not require browser storage.

## Requirements

- Adapters are Go APIs, not DOM attributes.
- Browser-only implementations stay behind build tags.
- Host builds remain importable with clear unavailable errors.
- Form values preserve repeated fields.
- File adapters expose metadata and readers, not raw JavaScript objects.
- Storage adapters are explicit and testable with fakes.

## Boundary

This patch does not add resource clients, session policy, bearer headers,
redirect helpers, fetch streaming, abort controllers, terminal protocols,
window listeners, hash routing, or effect hooks. Those libraries can build on
these adapters without expanding the GX core node model.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Browser API boundaries](../v0.1.9/browser-api-boundaries)
- [Typed event payloads](../v0.1.15/typed-event-payloads)
