---
title: ClientLog UI runtime block
description: Dedicated BusDK UI reference for ClientLog.
---

## Purpose

`ClientLog` is an action/resource/effect runtime block. Browser diagnostic channel. Use for operator diagnostics.

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

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./provider-error">ProviderError</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./error-host">ErrorHost</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
