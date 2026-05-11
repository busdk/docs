---
title: RawHTML UI component
description: Dedicated BusDK UI reference for RawHTML.
---

## Purpose

`RawHTML` is a foundation component. Audited trusted HTML fragment. Use only for sanitized Markdown, framework-owned static fragments, or compatibility boundaries.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `html` | yes | trusted HTML string or binding | Inserted without escaping. |
| `reason` | yes | short string | Explains why raw HTML is allowed. |
| `trusted` | yes | boolean | Must be true. |
| `sanitizer` | no | string | Names the sanitizer or source policy. Required for sanitized or bound HTML; may be omitted only for framework-owned static fragments whose source is reviewed with the component. |

## Boundary

`RawHTML` must not bind provider or user text directly. It receives only
sanitizer-produced HTML or framework-owned static trusted fragments. The
component records the trust reason and sanitizer/source policy so reviewers can
audit why escaping is intentionally bypassed.

## Example

```yaml
kind: RawHTML
props:
  trusted: true
  reason: sanitized-markdown
  sanitizer: bus-ui-markdown-safe-v1
  html: { bind: message.safeHTML }
```

## Runtime Terms

A binding uses the object form `{ bind: path.to.value }`. Missing bindings render the component default when the prop is optional and fail validation when the prop is required.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./text">Text</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./element">Element</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
