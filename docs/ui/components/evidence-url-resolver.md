---
title: EvidenceURLResolver UI component
description: Dedicated BusDK UI reference for EvidenceURLResolver.
---

## Purpose

`EvidenceURLResolver` is an evidence/media component. It returns a resolved
URL string for safe evidence links and previews; it does not fetch or render
the evidence by itself.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `endpoint` | yes | same-origin path | Evidence API endpoint beginning with `/` and without the artifact path; query strings are not allowed here. The resolver combines it with the raw `path` after escaping path segments. |
| `path` | yes | raw artifact path | Caller passes the raw provider artifact path; the resolver escapes each segment exactly once. |
| `apiResolver` | no | module, portal, or named resolver | Default `module`; external HTTPS evidence is allowed only through a named host resolver registered in host runtime config `externalEvidenceOrigins` as exact origins. |

## Boundary

Provider APIs authorize the resolved URL. Missing credentials or insufficient
scope produce an authorization error state; unknown artifacts produce a
not-found state. Callers render those through `ProviderError`, `ErrorBanner`,
or disabled evidence controls rather than exposing a raw path.

## Example

```yaml
kind: EvidenceURLResolver
props:
  endpoint: /api/evidence
  path: invoice.pdf
```

## Runtime Terms

Same-origin evidence endpoints begin with `/`. External evidence URLs are never
accepted directly; they must be resolved by a named `apiResolver` registered by
the host with an `externalEvidenceOrigins` allowlist. `javascript:`, `data:`,
path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./terminal-session-adapter">TerminalSessionAdapter</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./evidence-link">EvidenceLink</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
