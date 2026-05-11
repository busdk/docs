---
title: Collection UI concept
description: Dedicated BusDK UI framework concept page for Collection.
---

## Purpose

A collection renders repeated items as a table, list, timeline, gallery, or summary group.

## Boundary

Use collections after provider data has been projected into rows or items.
Provider data means the raw response from an API, database, file, or service.
Projected data means the product view model already filtered, authorized,
sorted, named, and shaped for display. The collection owns layout and repeated
structure, not data authorization.

## Example

```yaml
data:
  notes:
    - title: Evidence note
      status: review
body:
  kind: RecordList
  props:
    items: { bind: notes }
    itemComponent: SummaryItem
```

This renders the projected `notes` items as repeated `SummaryItem` rows. A
tabular view would use `DataTable`; an ordered event view would use `Timeline`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./shell">Shell</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./state">State</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
