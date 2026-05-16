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
| `onSubmit` | yes | callback | Runs when the toolbar form is submitted. The event identifies the toolbar source; the app controller decides what filter state to read. |
| `body` | yes | Field nodes | Contains `Field` nodes and form controls. Named child controls may update controller-owned filter state, but their values are not copied into the event. |
| `reset` | no | callback | Omitted hides reset. When present, the handler should clear filter state, and the UI may also clear local draft inputs after success. |

## Boundary

Toolbar wraps without changing field names.

## Example

```gx
package notesui

var noteFilters = (
  <FilterToolbar id="note-filters" onSubmit={searchNotes}>
    <Field label="Search">
      <TextInput name="query"></TextInput>
    </Field>
  </FilterToolbar>
)
```

## Runtime Terms

[Callback props](../v0.1.6/callback-props) documents function callback props.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- UI component reference
- [bus-ui module reference](../../modules/bus-ui)
