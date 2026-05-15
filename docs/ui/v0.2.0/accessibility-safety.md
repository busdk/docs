---
title: UI accessibility and safety
description: BusDK UI design rule for accessible controls and safe rendering.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)

## Rule

All interactive controls need accessible names. Status changes must be
represented in text. Form fields need labels. Tables need header cells where
the data is tabular.

Links that open external resources must use `target="_blank"` with
`rel="noopener noreferrer"`. Portal hosts must send
`Referrer-Policy: no-referrer` on pages that mount Bus UI surfaces, and local
app hosts must set the equivalent response header when they serve browser UI.

Unsafe HTML must be explicit and rare. User or provider text is escaped by
default. Markdown and other rich content must pass through an audited sanitizer
before any HTML reaches the tree. The version that introduces a raw-content
escape hatch owns the exact trust-boundary API.

Document previews default to fallback text unless the provider returns one of
the approved inline content types from
`EvidencePreview`: `image/png`, `image/jpeg`,
`image/webp`, `application/pdf`, or `text/plain`. Artifact links default to
disabled text unless the provider returns an authorized same-origin or
resolver-backed URL.

Product owners approve exceptions by adding a named resolver or sanitizer in
controller code or fixture runtime config, a host allowlist entry for any
external origin, and tests that reject `javascript:`, `data:`, SVG/script payloads, path
traversal, unauthorized evidence URLs, and unallowlisted origins.

## Consequence

Accessibility and safety are part of the component contract, not optional
browser polish.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Render tree contract](../v0.1.1/render-tree-contract)
- [v0.1.1 Core foundation](../v0.1.1/)
