---
title: ClientLog UI runtime block
description: Dedicated BusDK UI reference for ClientLog.
---

## Purpose

`ClientLog` is an event/resource/effect runtime block. Browser diagnostic channel. Use for operator diagnostics.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `app` | yes | string | Application name. |
| `level` | yes | trace, debug, info, warn, error | Log level. |
| `message` | yes | string | Caller-provided safe message; do not include secrets, tokens, private keys, credentials, or private customer data. |
| `endpoint` | no | same-origin path | Resolution order is explicit prop, then host `clientLogEndpoint`, then `/bus-ui/client-log`. Sends `POST` JSON `{app,level,message,time}` with `Content-Type: application/json`; runtime generates `time` as RFC3339 UTC and callers cannot override it. Any `2xx` response is success, failures are dropped without retry. External collectors are not allowed. |

## Boundary

Callers should pass already-redacted messages. The runtime may apply a final
defensive redaction pass for obvious token-like values, but that is not a
license to log secrets.

## Example

```yaml
kind: ClientLog
props:
  app: notes
  level: warn
  message: refresh failed
```

## Runtime Terms

Client log endpoints must be same-origin paths beginning with `/`. External
`https:` collectors are intentionally not part of this component contract.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [GX tooling](../v0.1.3/gx-tooling)
