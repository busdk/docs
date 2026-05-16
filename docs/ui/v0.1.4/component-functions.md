---
title: Component functions
description: BusDK UI v0.1.4 Go function and method component contract.
---

## Contract

A component is an ordinary Go callable whose name starts with an uppercase
letter. The callable accepts one typed props struct and returns `gx.Node`. GX
markup calls that function or method value with HTML-like syntax. There is no
component registry; the callable is available through normal Go package scope
and imports.

```gx
package notices

import "github.com/busdk/bus-gx/pkg/gx"

type NoticeProps struct {
	Message string
}

func Notice(p NoticeProps) gx.Node {
	return gx.Element("section", gx.Props{
		"class": "bus-notice",
	}, gx.Element("span", nil, gx.Text(p.Message)))
}

var noticeExample = <Notice message={"Saved"}></Notice>
```

Save this file as `notice.gx`. Run the command from that package with
`bus gx` available and `github.com/busdk/bus-gx` resolvable by the module.
`bus gx lint --format json notice.gx` exits `0` and prints an empty
diagnostics array.

## Props

GX attribute names map to exported props fields. `message` maps to `Message`.
Each exported scalar props field is required. Optional props and default values
are unsupported in v0.1.4, so missing exported scalar fields fail lint before
render. Unknown attributes also fail before render:

```gx
package notices

var missingProp = <Notice></Notice>
```

Save this invalid example as `missing_prop.gx`. `bus gx lint --format json
missing_prop.gx` exits non-zero with `code: missing-prop` at the `Notice` tag.

## Methods

Methods can be used when ordinary Go code exposes them as callable values in
scope. GX does not add a separate method lookup or registration layer:

```go
package notices

import "github.com/busdk/bus-gx/pkg/gx"

type AccountView struct{}

func (AccountView) Notice(p NoticeProps) gx.Node {
	return Notice(p)
}

var accountView AccountView
var AccountNotice = accountView.Notice
```

```gx
package notices

var accountNotice = <AccountNotice message={"Saved"}></AccountNotice>
```

Save the callable-value setup in `account_notice.go` and the GX entry in
`account_notice.gx` in the same package. `bus gx lint --format json
account_notice.gx` exits `0` and prints an empty diagnostics array.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Component tags](./component-tags)
- [v0.1.3 template entries](../v0.1.3/template-entries)
