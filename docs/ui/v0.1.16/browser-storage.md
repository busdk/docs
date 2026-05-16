---
title: Browser storage adapter
description: BusDK UI v0.1.16 browser key-value storage adapter.
---

## Contract

Browser storage is exposed as a small key-value interface for non-secret
client preferences and session markers. Tokens and credentials must remain
owned by the application security layer.

```go
import "errors"
import gxwasm "github.com/busdk/bus-gx/pkg/gx/wasm"

store := gxwasm.SessionStorage()
if err := store.Set("sidebar", "collapsed"); err != nil {
	if errors.Is(err, gxwasm.ErrUnavailable) {
		reportBrowserUnavailable(err)
		return
	}
	report(err)
	return
}
```

Storage adapters are optional. Tests can provide in-memory fakes, and
server-side rendering must not require browser storage.

The shared interface is:

```go
type Storage interface {
	Get(key string) (value string, ok bool, err error)
	Set(key string, value string) error
	Delete(key string) error
	Clear() error
}
```

The constructors all return `gxwasm.Storage` directly:

```go
func MemoryStorage(initial map[string]string) Storage
func LocalStorage() Storage
func SessionStorage() Storage
```

`gxwasm.MemoryStorage(initial)` returns an in-memory implementation for tests.
`gxwasm.LocalStorage()` and `gxwasm.SessionStorage()` return browser-backed
adapters when the browser API exists. Host builds and unsupported browsers
return storage values whose `Get`, `Set`, `Delete`, and `Clear` methods return
errors matching `gxwasm.ErrUnavailable`.

## Requirements

- The storage interface supports get, set, delete, and clear operations.
- `SessionStorage` and local storage adapters are browser-only bindings.
- Memory storage is available as a deterministic test seam.
- Missing browser storage returns errors matching `gxwasm.ErrUnavailable`.
- Stored values are strings; structured data encoding belongs to caller code.

## Boundary

The storage adapter is not an auth/session policy layer. It must not encourage
rendering bearer tokens, raw credentials, CSRF secrets, or other authority
values into public browser state.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./files">File adapter</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Minimal browser adapters](./minimal-browser-adapters)
- [Browser API boundaries](../v0.1.9/browser-api-boundaries)
