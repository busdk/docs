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

## Template

```gx
package notesui

component NoteItem(title, status) = (
  <li>
    <Text value={title}></Text>
    <StatusPill label={status} status={status}></StatusPill>
  </li>
)

var notesList = (
  <ul>
    <Repeat each={notes} as="note">
      <NoteItem title={noteTitle} status={noteStatus}></NoteItem>
    </Repeat>
  </ul>
)
```

## Fixture Data

```yaml
notes:
  - title: Evidence note
    status: review
```

## Fixture Bindings

```yaml
bindings:
  notes: notes
  noteTitle: note.title
  noteStatus: note.status
```

This renders projected `notes` as repeated rows using a local GX component. A
tabular view can build upward from the same `Repeat` foundation before choosing
a higher-level `DataTable`; an ordered event view can build upward toward
`Timeline`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Shell concept](../v0.2.1/shell)
