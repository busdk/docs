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

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `html` | yes | trusted HTML string or binding | Inserted without escaping. |
| `reason` | yes | short string | Explains why raw HTML is allowed. |
| `trusted` | yes | boolean | Must be true. |
| `sanitizer` | no | string | Names the sanitizer or source policy. Required for sanitized or bound HTML; may be omitted only for framework-owned static fragments packaged with the component. |

## Boundary

`RawHTML` must not bind provider or user text directly. It receives only
sanitizer-produced HTML or framework-owned static trusted fragments. The
component records the trust reason and sanitizer/source policy so the bypassed
escaping boundary remains explicit.

## Example

```yaml
kind: RawHTML
props:
  trusted: true
  reason: sanitized-markdown
  sanitizer: bus-ui-markdown-safe-v1
  html:
    bind: message.safeHTML
```

## Runtime Terms

[Binding](../v0.1.5/binding) defines object-form data references, scope resolution, and missing-value behavior.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [GX tooling](../v0.1.3/gx-tooling)
