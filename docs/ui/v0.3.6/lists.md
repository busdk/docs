---
title: Library lists
description: BusDK UI library non-tabular record list contract.
---

## Design References

- [UI design system](../v0.2.0/design-system)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

[`RecordList`](./record-list) renders repeated records that are not
naturally tabular. Each item comes from the view model and may use a supplied
item renderer or generic summary fields.

Each item requires stable `id` when it has events or when mounted updates may
reorder items. The generic summary shape is `id`, `title`, optional `meta`,
optional `detail`, optional `status`, and optional `events`. `title` and
`detail` are public-safe strings. `meta` is an ordered array of public-safe
strings. `status` is a `StatusPill` value object with `label` and semantic
`status`. `events` uses the same item shape as `EventBar`: public `label`,
exactly one trigger such as `click`, and optional `variant`.

Empty arrays render the configured empty state. When no empty state is
provided, the renderer emits a neutral empty-state surface with the list label.
Item events emit the list id or path plus the item id and event name; they do
not carry the item payload. The controller reads any required model state.

## Consequence

Lists are for repeated content where scanning individual records matters more
than column comparison.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [RecordList](./record-list)
- [Collection UI concept](./collection)
