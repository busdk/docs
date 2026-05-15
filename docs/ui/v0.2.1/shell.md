---
title: Shell UI concept
description: Dedicated BusDK UI framework concept page for Shell.
---

## Purpose

A shell owns durable page slots such as navigation, body, assistant, and footer. It frames content but does not decide product policy.

## Design References

- [UI design system](../v0.2.0/design-system)
- [GX source tools](../v0.1.2/source-tools)

## Boundary

Use shells for app or portal chrome. Choose the host shell outside the UI
template: portal modules receive it from the portal mount configuration, local
Go WebAssembly apps choose it in their app host setup, and static/sample rendering
chooses it with the renderer command or test harness options described in
[Rendering](../v0.1.10/rendering-model). The template should describe content
and binding references, not deployment shell selection.

## Template

```gx
package notesui

var notesContent = (
  <main slot="body">
    <Panel title={title}>
      <Text value={summary}></Text>
    </Panel>
  </main>
)
```

The portal or app host mounts this template into the shell body slot.

## Fixture Data

```yaml
page:
  title: Notes
  summary: Review queue
```

## Fixture Bindings

```yaml
bindings:
  title: page.title
  summary: page.summary
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Component concept](../v0.1.4/component)
