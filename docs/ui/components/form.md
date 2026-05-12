---
title: Form UI component
description: Dedicated BusDK UI reference for Form.
---

## Purpose

`Form` is a navigation/action/form component. Native form wrapper. Use for native submit behavior and server routes.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `method` | yes | GET or POST | Native method. |
| `action` | yes | same-origin path or action token | Submit target. Tokens use the document `actions` map or Go handlers; unresolved tokens fail validation. Same-origin paths start with `/`; external `https:` submit targets are rejected unless host config `allowExternalFormActions` lists the exact origin, such as `https://payments.example.com`. |
| `children` | yes | node list | Form body. |

## Boundary

Enter-submit works without local JavaScript.

## Example

```yaml
kind: Form
props:
  method: POST
  action: /save
children:
  - kind: Button
    props: { label: Save, variant: primary }
```

## Runtime Terms

Form actions accept same-origin paths beginning with `/` or action tokens from
the document `actions` map/Go handler registry. External URLs, `javascript:`,
`data:`, path traversal, and unresolved action tokens fail validation unless
the host explicitly enables `allowExternalFormActions` for a specific origin.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./icon">Icon</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./field">Field</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
