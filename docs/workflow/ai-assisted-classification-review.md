## AI-assisted classification (review before recording a revision)

When AI assistance is present, it is treated as a suggestion engine over repository data, not as an authority that rewrites records. The user stays in control by reviewing proposed changes before recording them as an authoritative revision, while still benefiting from automation for matching, categorization, and voucher preparation.

1. The user runs a normal import workflow that produces a deterministic baseline dataset:

```bash
bus bank import --file 202602-bank-statement.csv
```

2. The user requests and reviews classification suggestions before accepting any changes as authoritative repository data:

```bash
bus bank list --month 2026-2
```

Suggestions might include matching a €1240 incoming payment to an open invoice, or mapping a €10 bank fee to a bank-fees expense account. The review boundary is the working tree: the user inspects the proposed edits and additions as changes to CSV datasets and schemas, just like any other change to repository data.

3. The user applies the accepted outcome as explicit records rather than implicit adjustments:

```bash
bus journal add --help
bus journal add ...
```

For example, a payment match becomes an append-only journal entry that clears Accounts Receivable, and a bank fee becomes its own balanced journal entry. If the workflow also needs subledger updates, the user uses the relevant module commands (for example `bus invoices add` for corrections) so each module remains the owner of its datasets.

4. The user validates the result and records a new revision:

```bash
bus validate
```

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./accounting-workflow-overview">Accounting workflow overview (current planned modules)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./budgeting-and-budget-vs-actual">Budgeting and budget-vs-actual reporting</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
