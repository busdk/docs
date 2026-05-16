---
title: EvidenceLink UI component
description: Dedicated BusDK UI reference for EvidenceLink.
---

## Purpose

`EvidenceLink` is an evidence/media component. Evidence open/download link. Use for artifact open and download events.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `href` | yes | safe URL or Go expression | Authorized URL produced by the evidence API or resolver; missing authorization renders disabled text instead of a link. |
| `label` | yes | string | Visible link. |
| `target` | no | _self/_blank | Default _self. |
| `download` | no | bool | Omitted or `false` renders a normal link; `true` keeps the provider filename. |

## Boundary

External or `_blank` targets render with `rel="noopener noreferrer"`. Downloads
still require provider authorization; the browser hint does not grant access.

## Example

```gx
package evidenceui

import (
  "github.com/busdk/bus-gx/pkg/gx"
  . "github.com/busdk/bus-ui/pkg/uievidence"
)

func InvoiceDownload(invoiceDownloadURL string) gx.Node {
  return (
    <EvidenceLink
      label="Download invoice"
      href={invoiceDownloadURL}
      download={true}
    ></EvidenceLink>
  )
}
```

`invoiceDownloadURL` is a same-origin URL returned by `EvidenceURLResolver` or
the evidence API.

## Runtime Terms

[Expression children](../v0.1.5/expression-children) document ordinary Go expressions inside markup bodies.

Evidence links use same-origin evidence API URLs or URLs produced by
`EvidenceURLResolver`. External `https:` evidence links are rejected unless a
named evidence resolver explicitly authorizes and proxies them.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
