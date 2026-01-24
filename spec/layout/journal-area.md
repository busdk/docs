# Journal area (general ledger transactions)

The journal area contains general ledger transactions. A `journal.csv` (or segmented files like `journal_2025.csv`, `journal_2026.csv`) records ledger entries. The preferred representation is “one line per entry” rather than “one line per transaction,” because multi-line transactions require flexible entry counts. A representative schema includes fields such as transaction ID, date, account reference, debit, credit, currency, amount representation strategy (separate debit/credit fields versus a signed amount), and description. Schema validation enforces field correctness; balanced transaction invariants are enforced by module logic.

