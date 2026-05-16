---
title: Go review order
description: Review order for BusDK Go code, from product boundary through contracts, implementation, tests, and documentation.
---

## Review Flow

Start with the intended product boundary before reading individual functions.
Identify the module, package, command, service endpoint, or runtime layer that
owns the behavior. Then review the public contract, package design,
implementation details, tests, and documentation. Code that is locally tidy can
still be wrong when it puts behavior in the wrong module, duplicates a data
contract, or hides domain logic inside a presentation layer.

Prefer concrete findings over taste. A good review comment says what behavior
becomes harder to prove, maintain, or extend. Avoid asking for abstraction only
because a function is long, or for inlining only because a helper is small. The
question is whether the current shape makes the next correct change obvious.

Use the focused pages in this guide as the review map. Start with
[ownership and architecture](./ownership-and-architecture), then move through
[API and type design](./api-and-type-design), implementation concerns such as
[control flow and mutation](./control-flow-and-mutation), failure behavior in
[errors and CLI diagnostics](./errors-and-cli-diagnostics), and the evidence in
[tests and evidence](./tests-and-evidence). When the finding is meant for an
automated reviewer, use the compact names in
[LLM finding patterns](./llm-finding-patterns).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../go-peer-review-guide">Go peer review guide</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./ownership-and-architecture">Ownership and architecture</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go peer review guide](../go-peer-review-guide)
- [Independent modules](../../architecture/independent-modules)
- [Shared validation layer](../../architecture/shared-validation-layer)
