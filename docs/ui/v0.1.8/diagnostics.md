---
title: Core diagnostics
description: BusDK UI core client logging and runtime error reporting contract.
---

## Design References

- [Render tree contract](../v0.1.1/render-tree-contract)
- [Binding](../v0.1.5/binding)

## Contract

Diagnostics turns framework failures into safe visible state or safe client
logs. [`ClientLog`](./client-log) receives lifecycle, resource,
event, parser, and browser-bridge diagnostics. It must not carry tokens,
cookies, raw provider payloads, stack traces with customer data, SQL, or
credential headers.

Runtime-visible failures must have public-safe diagnostic messages. Mount
failures, missing required event handlers, invalid resources, unsafe links,
failed parsing, and browser bridge failures use redacted messages when they
affect the visible app.

`CloseGuard` reports active-work close protection
state. The owner supplies public copy and clears the guard by rendering updated
state; diagnostics never decide whether product work is safe to abandon.

## Consequence

Core reports framework and runtime problems consistently. Product modules still
own provider error meaning and public product copy.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Core lifecycle](../v0.1.7/)
