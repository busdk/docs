---
title: Library runtime config
description: BusDK UI library public runtime configuration contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)

## Contract

[`RuntimeConfig`](./runtime-config-component) renders public host/runtime
settings only. Secrets, bearer tokens, raw credentials, CSRF values, cookies,
and private provider payloads fail validation.

Runtime config can contain public module mount paths, asset URLs, feature
flags, public environment labels, and named host resolver ids. It should not
duplicate product view-model data.

| Field | Required | Type | Validation |
| --- | --- | --- | --- |
| `config.moduleBase` | yes | path string | Same-origin absolute path ending in `/`. |
| `config.apiBase` | yes | path string | Same-origin absolute path without query or fragment. |
| `config.assetBase` | no | path or resolver URL string | Defaults to `moduleBase`; must be same-origin or use a named host resolver. |
| `config.environment` | no | string | Public label such as `local`, `staging`, or `production`; defaults to `production`. |
| `config.locale` | no | BCP 47 string | Defaults to the host locale. |
| `config.externalAPIOrigins` | no | string array | Allowed `https:` origins for `APIURLResolver` absolute URLs; defaults empty. |
| `config.imageOrigins` | no | string array | Allowed `https:` origins for external images; defaults empty. |
| `featureFlags.*` | no | boolean or string | Missing flags read as disabled. Values must be public. |

The host validates runtime config before mounting the template and `bus gx
validate` validates checked-in examples. Invalid config fails before render with a
diagnostic that names the rejected key path.

```yaml
kind: RuntimeConfig
props:
  config:
    moduleBase: /modules/notes/
    apiBase: /modules/notes/api
    assetBase: /modules/notes/assets/
    environment: local
    externalAPIOrigins:
      - https://api.example.com
    imageOrigins:
      - https://images.example.com
  featureFlags:
    reviewMode: true
```

This is invalid because authority-bearing data is not public runtime config:

```yaml
kind: RuntimeConfig
props:
  config:
    moduleBase: /modules/notes/
    apiBase: /modules/notes/api
    accessToken: eyJ...
```

## Consequence

Runtime config makes host context available without exposing authority or
private state to templates.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [RuntimeConfig](./runtime-config-component)
- [Runtime contract](../v0.4.1/runtime-contract)
