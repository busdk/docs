---
title: ActionBar UI component
description: Dedicated BusDK UI reference for ActionBar.
---

## Purpose

`ActionBar` is a navigation/action/form component. Ordered command group. Use for related commands on rows, details, or results.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `actions` | yes | array | Ordered items. Each item requires `label` and exactly one of `action` or `href`. |
| `actions[].label` | yes | string | Visible command text; must be non-empty. |
| `actions[].action` | for commands | action token | Must match a key in document `actions`; emits `{action, label}`. |
| `actions[].href` | for links | safe URL/path | Same-origin paths, host-resolved resource URLs, or `https:` links allowed by the host external-link allowlist; invalid URLs fail validation. Mutually exclusive with `action`. |
| `actions[].variant` | no | primary, secondary, danger, ghost | Default secondary; destructive uses danger. |
| `actions[].disabled` | no | boolean | Default false; disabled items render but do not emit commands. |
| `alignment` | no | start, end, between | Default `start`; `start` aligns the flat action list to inline start, `end` aligns it to inline end, and `between` spaces the flat list evenly across the row. |
| `density` | no | compact, normal | Default `normal`; `compact` reduces button gap and vertical padding for table rows or dense toolbars. |

## Boundary

Destructive actions use the danger variant and must be backed by product-owned
permission state. If confirmation is required, the referenced action carries
that confirmation policy; if the user lacks permission, set
`actions[].disabled: true` or omit it instead of sending a command that will
fail late.

## Example

This component-only example assumes `approve` and `review` are already declared
in the document `actions` map or registered by Go code.

```yaml
kind: ActionBar
props:
  actions:
    - { label: Approve, action: approve, variant: primary }
    - { label: Request review, action: review }
```

## Runtime Terms

An action token is a string key in the document top-level `actions` map, or the equivalent registered Go handler when the component is built directly in Go. Required action tokens that cannot be resolved fail validation; optional action tokens usually hide the related control when omitted. Component-only examples assume those tokens are already declared in `actions` or registered by Go code.

A safe URL is either a same-origin absolute path beginning with `/`, a host-resolved resource URL, or an `https:` URL when the component explicitly allows external links. `javascript:`, `data:`, path traversal, and unresolved authorization failures are rejected.

## Related

Use the [component reference](../reference/component-reference) for the full index and the
[component catalog](../reference/component-catalog) for the compact contract table.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./link-button">LinkButton</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../reference/component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./menu">Menu</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
- [bus-ui module reference](../../modules/bus-ui)
