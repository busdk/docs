---
title: BrowserOpen UI runtime block
description: Dedicated BusDK UI reference for BrowserOpen.
---

## Purpose

`BrowserOpen` is a CLI/tooling runtime block. Open local app URL. Use for local app launches that need a browser.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `url` | yes | URL | Target URL. |
| `os` | no | darwin, linux, windows | Inferred by runtime when omitted. |
| `opener` | no | command name/path | Override command invoked as `opener url`. Defaults to `open` on macOS, `xdg-open` on Linux, and `cmd /c start` on Windows. Missing or failing commands fall back to printing the URL to stdout. |
| `mode` | no | local, server, container | Default `local` when a GUI opener is available, otherwise `server`; `server` and `container` print URL to stdout instead of GUI open. |

## Boundary

Container mode never tries to open a GUI and prints the URL to stdout so shell
scripts can capture it without parsing diagnostics from stderr.

`BrowserOpen` accepts only loopback `http://127.0.0.1:...`,
`http://localhost:...`, or an `https:` URL whose origin exactly matches the
current host origin supplied by the local app launcher.
`javascript:alert(1)` and external `http:` URLs are rejected.

## Example

```gx
package localui

var browserOpen = (
  <BrowserOpen url="http://127.0.0.1:8080/" mode="local"></BrowserOpen>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
