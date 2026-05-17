---
title: BrowserOpen
description: Local browser launch boundary for Bus UI development servers.
---

## Purpose

`BrowserOpen` opens a local Bus UI application URL during development. It keeps
the browser handoff separate from the Go component tree, so local tools can
choose a GUI launch, print a URL for remote shells, or stay container-safe.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `url` | yes | URL | Local app URL to open or print. |
| `os` | no | darwin, linux, windows | Inferred by runtime when omitted. |
| `opener` | no | command name/path | Override command invoked as `opener url`. Defaults to `open` on macOS, `xdg-open` on Linux, and `cmd /c start` on Windows. Missing or failing commands fall back to printing the URL to stdout. |
| `mode` | no | local, server, container | Default `local` when a GUI opener is available, otherwise `server`; `server` and `container` print URL to stdout instead of GUI open. |

## Boundary

Container mode never tries to open a GUI and prints the URL to stdout so shell
scripts can capture it without parsing diagnostics from stderr.

`BrowserOpen` accepts only loopback `http://127.0.0.1:...`,
`http://localhost:...`, or an `https:` URL whose origin exactly matches the
current host origin supplied by the local app launcher. JavaScript URLs and
external `http:` URLs fail validation.

## Example

```gx
package localui

var browserOpen = (
  <BrowserOpen url="http://127.0.0.1:8080/app" mode="local"></BrowserOpen>
)
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-ui module reference](../../modules/bus-ui)
