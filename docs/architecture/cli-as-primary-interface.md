## CLI as the primary interface (controlled read/modify/write)

The CLI is the primary interface. Commands are expected to perform a controlled read-modify-write cycle: load the necessary resources from the repository, validate requested changes against schema and business rules, apply the operation, write the updated files, then commit the change with a descriptive message. For example, a journal command such as:

```bash
busdk journal add --date 2026-01-15 --debit Cash --credit Sales --amount 500 --desc "Invoice 1001 payment"
```

is expected to append new ledger rows to the journal file and commit with a message that narrates what happened, such as “Add journal entry: 2026-01-15 Invoice 1001 payment.” This makes the CLI the gatekeeper of data integrity and reduces the risk of user error compared with manual CSV editing.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./architectural-overview">Architectural overview</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./git-backed-data-store">Git-backed data repository (the data store)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
