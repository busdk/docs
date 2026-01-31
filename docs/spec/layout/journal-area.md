## Journal area (general ledger transactions)

The journal area contains general ledger transactions. A `journal.csv` (or segmented files like `journal_2025.csv`, `journal_2026.csv`) records ledger entries. The preferred representation is “one line per entry” rather than “one line per transaction,” because multi-line transactions require flexible entry counts. A representative schema includes fields such as transaction ID, date, account reference, debit, credit, currency, amount representation strategy (separate debit/credit fields versus a signed amount), and description. Schema validation enforces field correctness; balanced transaction invariants are enforced by module logic.

For Finnish compliance, journal entries MUST include stable identifiers and explicit voucher references so the audit trail is demonstrable. Minimum fields for traceability include: `entry_id`, `transaction_id`, `posting_date`, `account_id`, `amount`, `currency`, `voucher_id`, and a deterministic `entry_sequence` for chronological ordering. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./invoices-area">Invoices area (headers and lines)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./layout-principles">Data directory layout (principles)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
