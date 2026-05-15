---
title: Library evidence URLs
description: BusDK UI library evidence URL resolution contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`EvidenceURLResolver`](./evidence-url-resolver) resolves evidence
ids for `open`, `download`, or `preview` operations. Resolver output is an
authorized same-origin or host-resolved URL plus optional expiry and
content-type hint.

Input fields:

| Field | Required | Behavior |
| --- | --- | --- |
| `evidenceID` | yes | Stable evidence id owned by the provider/controller. |
| `operation` | yes | `open`, `download`, or `preview`. |
| `contentType` | no | MIME hint used for `preview` eligibility. |

Output fields:

| Field | Required | Behavior |
| --- | --- | --- |
| `url` | yes on success | Same-origin path or URL produced by a named host resolver from [runtime config](../v0.4.2/runtime-config). |
| `expiresAt` | no | RFC 3339 expiry timestamp. |
| `contentType` | no | MIME type returned by the resolver. |
| `reason` | yes on denial | `unauthorized`, `expired`, `missing`, or `unsupported`. |

Denial returns no `url` and one `reason`: `unauthorized` when the user lacks
access, `expired` when a previously issued URL can no longer be used, `missing`
when the evidence id is unknown, and `unsupported` when the requested operation
or content type cannot be rendered. Product modules own document authorization
and provider path semantics.

## Consequence

Evidence URL resolution is deterministic and controller-owned.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [EvidenceURLResolver](./evidence-url-resolver)
- [Resource UI concept](../v0.4.1/resource)
