# Append-only updates and soft deletion

For critical ledgers such as the journal, BuSDK enforces that new transactions are appended as new rows and that corrections are represented as new records such as reversing entries, not silent in-place edits. Where record removal semantics are required (for example, voiding an invoice), BuSDK prefers soft deletion via an “active” boolean or explicit status field rather than removing rows from history. Git history provides a backstop by exposing deletions as diffs, but user-facing tools are expected to discourage destructive edits.

