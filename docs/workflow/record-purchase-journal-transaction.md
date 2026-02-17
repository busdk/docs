---
title: Record a purchase as a journal transaction
description: When Alice buys a new laptop for work, she records the transaction as a balanced, append-only journal entry.
---

## Record a purchase as a journal transaction

When Alice buys a new laptop for work, she records the transaction as a balanced, append-only journal entry. The journal is authoritative for the ledger, so the workflow is designed to make partial or unbalanced postings difficult to introduce by mistake.

1. Alice confirms the account references she will post against:

```bash
bus accounts list
```

For a laptop purchase she typically needs a cash or bank asset account and an equipment-related expense or asset account, depending on how she treats capitalization and depreciation in her workflow.

2. Alice records the purchase as a balanced journal transaction:

```bash
bus journal add --help
bus journal add --date 2026-01-10 \
--desc "Bought new laptop" \
--debit "Office Equipment"=2500 \
--credit "Cash"=2500
```

The command generates the corresponding ledger rows in the period journal file at the workspace root, for example `journal-2026.csv`, linking them with a shared transaction identifier. It rejects unknown account names and refuses to write an unbalanced entry. If the repository did not yet have a 2026 journal file, the tool also updates `journals.csv` so the new file is discoverable and unambiguous.

If she is unsure about the available flags in her pinned version, she uses `bus journal add --help`.

3. Alice verifies the resulting ledger effect:

```bash
bus journal balance --help
bus journal balance ...
```

4. Alice records the change as a new revision using her version control tooling.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./invoice-ledger-impact">Invoice ledger impact (integration through journal entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./scenario-introduction">Scenario introduction</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
