---
title: Git commit conventions per operation (external Git)
description: BusDK can be used with or without Git, and it does not implement or run Git itself.
---

## Git commit conventions per operation (external Git)

BusDK can be used with or without Git, and it does not implement or run Git itself. The spec defines commit conventions per operation for teams that track workspace datasets in Git and expects users or external automation to apply them using their existing Git tooling. For example:

```bash
bus accounts add --code 3000 --name "Consulting Income" --type income
```

is expected to append a new account row to `accounts.csv`, and the corresponding Git commit (made externally) would use a message such as “Add account 3000 Consulting Income.”

The default model is “one commit per high-level operation” to maximize audit clarity and align with append-only discipline. External workflows may also batch operations into a single commit when needed (for example, after a scripted import).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./api-parity">Extensible CLI surface and API parity</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./command-structure">Command structure and discoverability</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
