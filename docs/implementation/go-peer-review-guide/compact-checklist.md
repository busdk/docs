---
title: Go peer review compact checklist
description: Compact final approval checklist for BusDK Go code reviews.
---

## Approval Check

Before approving Go code, confirm that the owner and layer are right, the
public contract is typed and small, errors are explicit and deterministic, side
effects are visible, resources have lifetimes, validation happens before
mutation, tests prove both package behavior and user-visible behavior, and
documentation matches the code.

If any of those are unclear, the review is not done. Use
[LLM finding patterns](./llm-finding-patterns) to name the issue and include a
concrete improvement rather than a vague request to clean up or refactor.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./llm-finding-patterns">LLM finding patterns</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../go-peer-review-guide">Guide index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../go-optimization-guide">Go optimization guide</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Go peer review guide](../go-peer-review-guide)
- [Testing strategy](../../testing/testing-strategy)
- [Go optimization guide](../go-optimization-guide)
