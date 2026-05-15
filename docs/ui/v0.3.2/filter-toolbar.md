---
title: FilterToolbar UI component
description: Dedicated BusDK UI reference for FilterToolbar.
---

## Purpose

`FilterToolbar` is a navigation/event/form component. Compact filter surface. Use above tables and lists.

## Inputs

| Field | Required | Type | Behavior |
| --- | --- | --- | --- |
| `id` | recommended for events | string | Stable source id included in submit and reset events. If omitted, the renderer uses the component tree path as the source. |
| `submit` | yes | event name | Runs when the toolbar form is submitted. The event identifies the toolbar source; the app controller decides what filter state to read. |
| `body` | yes | Field nodes | Contains `Field` nodes and form controls. Named child controls may update controller-owned filter state, but their values are not copied into the event. |
| `reset` | no | event name | Omitted hides reset. When present, emits the reset event; the handler should clear filter state, and the UI may also clear local draft inputs after success. |

## Boundary

Toolbar wraps without changing field names.

## Example

This component-only example assumes `search` is already declared in the
runtime `events` map or registered by Go code.

```yaml
kind: FilterToolbar
props:
  submit: search
body:
  - kind: Field
    props:
      name: query
      label: Search
```

## Runtime Terms

[Event](../v0.1.6/event) defines event names, handler registration, validation, and confirmation policy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
