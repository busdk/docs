---
title: Event UI concept
description: BusDK UI event and handler concept.
---

## Purpose

An event is a named signal emitted by a tag. It covers submit, click, approve,
archive, send, stop, and other UI interactions. The signal carries interaction
identity; typed Go controller handlers decide what state to read.

## Boundary

Templates attach controller event names to tags with trigger attributes such as
`submit="save-note"` or `click="save-note"`. A tag event is an interaction
record: event name, trigger, source component id or tree path, and optional
submitter id. It does not carry form values or request bodies.

Go controllers define an event map when the event routes to a named handler.
Go WebAssembly apps register handlers with the `bus-gx` `EventHandler[T]` /
`DispatchEvent` map when the event is handled inside the mounted client
runtime:

```go
handlers := map[string]gx.EventHandler[gx.Event]{
	"save-note": saveDraftNote,
}
```

In both paths the public event name is a stable string and tags reference only
the event name. The receiving controller decides what state to read and what
local update should happen.

Component controllers may handle lower-level events before the app controller
sees them. For example, a submit button click is first handled by the parent
`Form` controller. The form controller applies native submit rules and then
emits the configured form submit event with the form source and submitter
identity. The app controller handles that submit event and chooses what data, if
any, to send.

Repeated controls use the same rule. A row action, approval button, thread
entry, or menu item must have a stable source id derived from controller-owned
item identity. The event says which control was activated; the controller looks
up the row, approval, thread, or menu item from its current state.

Required event names that cannot be resolved fail validation. Component-only
examples assume those names are registered by Go code.

## Example

```go
controller := gx.Controller{
	Events: gx.Events{
		"save-note": saveNote,
	},
}
```

```html
<form id="note-editor" submit="save-note">
  <input name="title" value={draftTitle}></input>
  <button id="save-button" type="submit">Save note</button>
</form>
```

The `draftTitle` template binding reads `draft.title`, and the input controller
keeps that model field current before the form submit event is handled.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Binding concept](../v0.1.5/binding)
