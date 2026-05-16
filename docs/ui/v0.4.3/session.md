---
title: Library session
description: BusDK UI library safe browser session display contract.
---

## Design References

- [Expression children](../v0.1.5/expression-children)

## Contract

[`Session`](./session-component) displays safe session state projected by the
host. Missing optional display fields collapse. Tokens, CSRF values, refresh
tokens, cookies, and provider secrets are never rendered.

Session handling stays in the host runtime. Components may receive public user
or account labels, scope summaries, and sign-in state, but they must not read
authorization headers directly.

## Consequence

The session component can render user context without becoming an auth layer.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-index"><a href="../">UI framework index</a></span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Session](./session-component)
- [Runtime contract](../v0.4.1/runtime-contract)
