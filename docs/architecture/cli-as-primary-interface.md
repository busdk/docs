---
title: CLI as the primary interface (controlled read/modify/write)
description: The CLI is the primary interface.
---

## CLI as the primary interface (controlled read/modify/write)

The CLI is the primary interface. Commands are expected to perform a controlled read-modify-write cycle: load the necessary resources from the repository, validate requested changes against schema and business rules, apply the operation, and write the updated files. Git commits are made externally by the user or automation, and BusDK does not execute Git commands.

```bash
busdk journal add --date 2026-01-15 --debit Cash=500 --credit Sales=500 --desc "Invoice 1001 payment"
```

is expected to append new ledger rows to the journal file. The corresponding Git commit, when used, is created outside BusDK with a descriptive message such as “Add journal entry: 2026-01-15 Invoice 1001 payment.” This makes the CLI the gatekeeper of data integrity and reduces the risk of user error compared with manual CSV editing.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./architectural-overview">Architectural overview</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./git-backed-data-store">Git-backed data repository (the data store)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
