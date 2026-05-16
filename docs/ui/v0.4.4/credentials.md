---
title: Library credentials
description: BusDK UI library credential entry contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`CredentialLoginCard`](./credential-login-card) renders generic
credential entry fields and a submit event. Submit emits interaction identity;
the controller decides which credential state to send and how provider errors
map to public-safe validation text.

Credential submit uses the same identity shape as form submission:

| Key | Type | Required |
| --- | --- | --- |
| `event` | string | yes |
| `source.id` | string | yes when the card has `id` |
| `source.path` | string | yes |
| `submitter.id` | string | yes when the submitter has `id` |
| `submitter.path` | string | yes |

The controller reads credential field state from its model and sends the
provider request. The event must not carry secret values.

Credential components must not log, echo, or expose secrets in runtime config,
client logs, HTML attributes, or diagnostics.

## Consequence

Credential entry stays reusable while authority, scopes, and provider policy
remain outside the component.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [CredentialLoginCard](./credential-login-card)
- [Form submission](../v0.3.1/form-submission)
