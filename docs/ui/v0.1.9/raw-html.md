---
title: RawHTML UI component
description: Dedicated BusDK UI reference for RawHTML.
---

## Purpose

`RawHTML` status is unassigned and unavailable. No documented UI framework
version currently supports it. Do not implement or use this reference until a
future version page explicitly owns the sanitizer and trust-boundary contract.
Once that version exists, use it only for sanitized Markdown or framework-owned
static fragments.

## Boundary

Raw HTML bypasses the escaping boundary provided by the
[v0.1.1 renderer](../v0.1.1/interfaces). Until a later patch defines the
sanitizer, trust metadata, binding limits, and test contract, `RawHTML` has no
accepted inputs and no copyable usage example.

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [Source-tool integration](../v0.1.3/source-tool-integration)
