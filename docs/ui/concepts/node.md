---
title: Node UI concept
description: Dedicated BusDK UI framework concept page for Node.
---

## Purpose

A node is the smallest renderable unit in the framework. Escaped text renders
literal text. A safe element is an allowed HTML tag with validated attributes.
A fragment groups children without adding a wrapper. A virtual node is the
serialized node form shared by server and Go/WASM renderers. A template
instance is a registered static tree with dynamic slots. An audited raw fragment
is trusted HTML that records its sanitizer or source policy.

## Boundary

Use nodes to keep server-rendered HTML, Go/WASM mounting, and unit-test
inspection aligned. Prefer escaped text or safe elements by default. Raw
fragments require a `RawHTML`/`VNode raw` trust reason, sanitizer or source
policy, and sanitizer-produced or framework-owned input.

## Example

```yaml
kind: element
tag: p
children:
  - kind: text
    text: Hello <Bus>
```

The rendered output is equivalent to `<p>Hello &lt;Bus&gt;</p>`.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../component-reference">Component reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./component">Component</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [UI framework](../)
- [UI component reference](../reference/component-reference)
- [UI component catalog](../reference/component-catalog)
