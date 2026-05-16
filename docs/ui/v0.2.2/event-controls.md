---
title: Library event controls
description: BusDK UI library buttons, event bars, and event trigger attributes.
---

## Design References

- [Expression children](../v0.1.5/expression-children)
- [Render tree contract](../v0.1.1/render-tree-contract)

## Contract

Event controls receive Go callback props. [`Button`](./button) is for visible
text controls. [`IconButton`](./icon-button) is for compact tools and requires
the component prop `ariaLabel` when no visible text is rendered; when the
component renders a native HTML button, that prop becomes the HTML
`aria-label` attribute. [`EventBar`](./event-bar) groups a short ordered set of
event controls.

| Field | Required | Behavior |
| --- | --- | --- |
| `onClick` | required for active controls | Go callback function invoked by the component. |
| `id` | recommended for handled controls | Stable component id for tests, labels, and event payload target data. |
| `confirm` | required for destructive controls | Public-safe confirmation policy with `title`, optional `summary`, and `variant: danger`. |

```gx
var actions = (
  <EventBar>
    <Button id="save-button" onClick={saveDraft}>Save</Button>
    <IconButton id="archive-button" icon="archive" ariaLabel="Archive" onClick={archive}></IconButton>
  </EventBar>
)
```

Destructive controls delete data, revoke access, submit irreversible state, or
start work that is hard to undo. If a destructive control omits `confirm`,
component validation fails before rendering.

## Consequence

Product modules should not attach inline JavaScript for ordinary events.
Destructive events use the danger variant and require confirmation policy in
the component props.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Callback props](../v0.1.6/callback-props)
- UI runtime contract
