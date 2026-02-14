---
title: Journal area (general ledger transactions)
description: The journal area contains general ledger transactions.
---

## Journal area (general ledger transactions)

The journal area contains general ledger transactions. Every file in this area includes “journal” or “journals” in the filename. The current working directory contains an index table `journals.csv` that records which journal files exist, which period each file covers, and where it lives in the repository. Journal entry rows are stored in root-level files with a date prefix, for example `journal-2026.csv` and `journal-2025.csv` (and their beside-the-table schemas), not in subdirectories. The period identifier is usually the calendar year, but it can also be a financial period identifier (or the start year of a financial period) as long as `journals.csv` describes the mapping deterministically.

The preferred representation is “one line per entry” rather than “one line per transaction,” because multi-line transactions require flexible entry counts. A representative schema includes fields such as transaction ID, date, account reference, debit, credit, currency, amount representation strategy (separate debit/credit fields versus a signed amount), and description. Schema validation enforces field correctness; balanced transaction invariants are enforced by module logic.

For Finnish compliance, journal entries MUST include stable identifiers and explicit voucher references so the audit trail is demonstrable. Minimum fields for traceability include: `entry_id`, `transaction_id`, `posting_date`, `account_id`, `amount`, `currency`, `voucher_id`, and a deterministic `entry_sequence` for chronological ordering. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./invoices-area">Invoices area (headers and lines)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./layout-principles">Data directory layout (principles)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
