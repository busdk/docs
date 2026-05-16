---
title: Shell UI concept
description: Dedicated BusDK UI framework concept page for Shell.
---

## Purpose

A shell owns durable page slots such as navigation, body, and footer. It frames
content but does not decide product policy.

## Design References

- [UI design system](../v0.2.0/design-system)
- [GX source tools](../v0.1.2/source-tools)

## Boundary

Use shells for app chrome. Choose the shell outside the lower-level content
template: local Go WebAssembly apps choose it in their app host setup, and
tests can mount content into a shell fixture. The template should describe
content and Go value references, not deployment shell selection.

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

The app host or test harness mounts this template into the shell body slot.

## Fixture Values

```go
title := "Notes"
summary := "Review queue"
```

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [Component concept](../v0.1.4/component)
