---
title: RuntimeConfig UI runtime block
description: Dedicated BusDK UI reference for RuntimeConfig.
---

## Purpose

`RuntimeConfig` is an action/resource/effect runtime block. Safe public runtime config. Use to pass non-secret browser configuration.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `config` | yes | object | Public runtime keys. `moduleBase` is the same-origin module route prefix such as `/modules/notes/`; `apiBase` is the same-origin API prefix such as `/modules/notes/api`; `assetBase` is a same-origin or host-resolved asset prefix; `locale` is a BCP 47 language tag such as `en`, `fi`, or `fi-FI`, defaulting to the host locale when omitted. Unknown keys are allowed only when their names do not look sensitive. |
| `featureFlags` | no | object | Public booleans or strings. Missing flags default to false/disabled in consumers. Flag values must not carry secrets or user-private data. |

## Boundary

Validation rejects sensitive-looking keys such as `token`, `secret`,
`password`, `credential`, `apiKey`, `privateKey`, and `authorization`, including
case variations and common separators. Rejected keys fail validation instead of
being silently omitted.

## Example

```yaml
kind: RuntimeConfig
props:
  config:
    moduleBase: /modules/notes/
    apiBase: /modules/notes/api
  featureFlags:
    reviewMode: true
```

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./error-banner">ErrorBanner</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./apiurl-resolver">APIURLResolver</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
