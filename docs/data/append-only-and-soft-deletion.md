---
title: Append-only updates and soft deletion
description: For critical ledgers such as the journal, BusDK enforces that new transactions are appended as new rows and that corrections are represented as new records…
---

## Append-only updates and soft deletion

For critical ledgers such as the journal, BusDK enforces that new transactions are appended as new rows and that corrections are represented as new records such as reversing entries, not silent in-place edits. Where record removal semantics are required (for example, voiding an invoice), BusDK prefers soft deletion via an “active” boolean or explicit status field rather than removing rows from history. Git history provides a backstop by exposing deletions as diffs, but user-facing tools are expected to discourage destructive edits.

After a period is closed or statutory reporting is produced, BusDK MUST prevent edits that would change previously reported content and must require correction entries instead. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./account-types">Account types in double-entry bookkeeping</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./csv-conventions">CSV conventions</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
