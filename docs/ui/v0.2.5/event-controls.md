---
title: Library event controls
description: BusDK UI library buttons, event bars, and event trigger attributes.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Event controls emit interaction identity. [`Button`](./button) is
for visible text event controls. [`IconButton`](./icon-button) is
for compact tools and requires `ariaLabel` when no visible text is rendered. [`EventBar`](./event-bar)
groups a short ordered set of event controls.

Interactive controls emit through `on*` trigger attributes in markup or the
same trigger key in structured component data. Valid event names come from the
runtime `events` map or registered Go WebAssembly event handlers. The handler
receives interaction identity and returns a typed result or provider error.

| Field | Required | Behavior |
| --- | --- | --- |
| `<trigger>="event-name"` | required for active markup controls | The trigger is the component event hook, such as `onClick`, `onSubmit`, `onChange`, `onDrop`, `onSelect`, or `onDismiss`. |
| trigger prop | required for active structured controls | Structured-data equivalent of the trigger attribute. For example, `props.onClick: save-draft` matches `<Button onClick="save-draft">`. |
| `id` | recommended for handled controls | Stable component id included in the event. If omitted, the renderer uses the component tree path. |
| `confirm` | required for destructive events | Runtime event policy object with public-safe `title`, optional public-safe `summary`, and `variant: danger`. |

```html
<Button id="save-button" onClick="save-draft">Save</Button>

<IconButton id="archive-button" icon="archive" aria-label="Archive" onClick="archive"></IconButton>
```

```yaml
kind: Button
props:
  id: save-button
  onClick: save-draft
body: Save
```

```yaml
events:
  archive:
    handler: notes.archive
    confirm:
      title: Archive note?
      summary: This removes the note from the active review queue.
      variant: danger
```

## Consequence

Product modules should not attach inline JavaScript for ordinary events.
Destructive events use the danger variant and require confirmation policy in
the runtime event.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](../v0.1.6/callback-props)
- UI runtime contract
