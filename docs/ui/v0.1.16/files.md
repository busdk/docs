---
title: File adapter
description: BusDK UI v0.1.16 safe browser file adapter.
---

## Contract

File input access returns safe metadata and a Go reader handle for selected
files. Product code still owns size limits, MIME validation, authorization, and
upload policy.

```gx
import (
	"context"
	"errors"

	"github.com/busdk/bus-gx/pkg/gx"
	gxwasm "github.com/busdk/bus-gx/pkg/gx/wasm"
)

func AttachmentInput() gx.Node {
	return <input type="file" onChange={attach}></input>
}

func attach(event gx.ChangeEvent) {
	files, err := gxwasm.Files(event)
	if err != nil {
		if errors.Is(err, gxwasm.ErrUnavailable) {
			reportBrowserUnavailable(err)
			return
		}
		report(err)
		return
	}
	for _, file := range files {
		if err := validateAndAuthorize(file.Name, file.Type, file.Size); err != nil {
			report(err)
			return
		}
		reader, err := file.Open(context.Background())
		if err != nil {
			report(err)
			return
		}
		defer reader.Close()
		store(file.Name, file.Type, file.Size, reader)
	}
}
```

`validateAndAuthorize` represents the product-owned size, MIME, authorization,
and upload-policy checks. The adapter only supplies safe file metadata and a
reader after that policy has accepted the file.

The adapter must not expose raw JavaScript file objects outside the browser
package boundary.

`gxwasm.Files` accepts `gx.FileInputEvent`, `gx.ChangeEvent`, `gx.InputEvent`,
or `gx.DragEvent`. Its full signature is:

```go
func Files(event any) ([]gxwasm.File, error)
```

It returns an empty slice and nil error for an empty browser selection. It
returns an error for unsupported event types or when browser file access is
unavailable. Host-build unavailable errors match `gxwasm.ErrUnavailable`.

| Field | Type | Required | Missing Browser Value |
| --- | --- | --- | --- |
| `Name` | string | yes | Empty string. |
| `Size` | int64 | yes | Zero. |
| `Type` | string | no | Empty string. |

`File.Open(ctx)` returns an `io.ReadCloser`. The reader is valid for the
selected browser file while the callback-owned file handle remains reachable.
Callers must close it. If `ctx` is canceled before or during the browser read,
the read fails and the returned error reflects cancellation. If no browser file
reader is available, the error matches `gxwasm.ErrUnavailable`.

## Requirements

- File metadata uses exact `Name`, `Size`, and `Type` fields.
- File content is read through `File.Open(ctx) io.ReadCloser` handles.
- Browser-only handles remain hidden behind the adapter package.
- Empty selections return an empty file list, not an error.
- Host builds compile and return errors matching `gxwasm.ErrUnavailable`.

## Boundary

The file adapter does not upload data, infer trust, sanitize media, or decide
storage policy. Higher-level libraries can build upload helpers on top of this
adapter after product code supplies validation and authorization rules.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./form-values">Form value adapter</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./browser-storage">Browser storage adapter</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Minimal browser adapters](./minimal-browser-adapters)
- [Browser API boundaries](../v0.1.9/browser-api-boundaries)
