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
reorder items. Static lists without events may omit `id`; in that case the
renderer uses the item index as an internal path only, and handlers must not
depend on it as stable identity. The generic summary shape is optional `id`,
required `title`, optional `meta`, optional `detail`, optional `status`, and
optional `events`. Public-safe strings may name user-visible records,
statuses, and actions, but must not include secrets, bearer tokens, raw
provider payloads, stack traces, SQL, or private customer data. `meta` is an
ordered array of public-safe strings. `status` is a status pill value object
with `label` and semantic `status`; allowed values are `neutral`, `working`,
`success`, `warning`, `danger`, and `muted`. `events` uses the same item shape
as `EventBar`: public `label`, exactly one `onClick` event name, and optional
`variant`.

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
