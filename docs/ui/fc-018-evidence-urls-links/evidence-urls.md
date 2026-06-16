---
title: Library evidence URLs
description: BusDK UI library evidence URL resolution contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`EvidenceURLResolver`](./evidence-url-resolver) resolves evidence
artifact paths for `open`, `download`, or `preview` operations. Resolver output
is a safe same-origin or host-resolved URL plus optional expiry and content-type
metadata. Evidence IDs, provider path lookup, authorization, and filesystem
access belong to the product module or host adapter that calls the helper.

Input fields:

| Field | Required | Behavior |
| --- | --- | --- |
| `Endpoint` | yes for built-in resolvers | Safe same-origin evidence endpoint. |
| `Path` | yes | Raw relative artifact path; segments are escaped by the helper. |
| `Operation` | no | `open`, `download`, or `preview`; defaults to `open`. |
| `ContentType` | no | MIME hint carried as metadata. |
| `ExpiresAt` | no | Optional RFC 3339 expiry metadata. |
| `APIResolver` | no | `module`, `portal`, `same-origin`, or a host-named resolver. |

Output fields:

| Field | Required | Behavior |
| --- | --- | --- |
| `URL` | yes on success | Same-origin path or host-resolved HTTPS URL. |
| `ExpiresAt` | no | RFC 3339 expiry timestamp. |
| `ContentType` | no | Normalized MIME type returned by the resolver. |
| `Reason` | yes on denial | Public denial reason such as `unauthorized`, `expired`, `missing`, `not_found`, `unsafe_path`, `unsupported`, or `unregistered_resolver`. |

Denial returns no `URL` and one `Reason`. Named resolvers are the boundary for
external evidence origins and provider-specific authorization decisions. The
shared helper validates endpoint shape, artifact path shape, operation tokens,
metadata, and returned href safety.

```go
resolved, err := ui.ResolveEvidenceURL(ui.EvidenceURLResolverProps{
	Endpoint:  "/api/evidence",
	Path:      "receipts/2026-04-18.pdf",
	Operation: ui.EvidenceOperationOpen,
})
if err != nil {
	return ui.EvidenceURLResult{}, err
}
if resolved.Reason != "" || resolved.URL == "" {
	return resolved, nil
}
```

## Consequence

Evidence URL resolution is deterministic in `bus-ui` while provider authority
stays with the host or product module.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [EvidenceURLResolver](./evidence-url-resolver)
- [Resource UI concept](../v0.4.1/resource)
