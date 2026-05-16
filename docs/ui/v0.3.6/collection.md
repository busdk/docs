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

var notesList = (
  <ul>
    <Repeat each={notes} as="note">
      <NoteItem title={note.Title} status={note.Status}></NoteItem>
    </Repeat>
  </ul>
)
```

The repeated item is an ordinary Go function component:

```go
package notesui

import "github.com/busdk/bus-gx/pkg/gx"

type NoteItemProps struct {
	Title  string
	Status string
}

func NoteItem(p NoteItemProps) gx.Node {
	return gx.Element("li", nil,
		gx.Text(p.Title),
		StatusPill(StatusPillProps{
			Label:  p.Status,
			Status: p.Status,
		}),
	)
}
```

## View Data

```go
package notesui

type NoteView struct {
	Title  string
	Status string
}

var notes = []NoteView{
	{Title: "Evidence note", Status: "review"},
}
```

This renders projected `notes` as repeated rows using a function component. A
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
- [Shell concept](../v0.2.6/shell)
