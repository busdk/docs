# Scenario introduction

Consider Alice, a freelance consultant using BusDK to run bookkeeping in a dedicated Git repository. She uses the `bus` dispatcher and a small set of focused modules (accounts, entities, journal, invoices, bank, reconcile, VAT, reports) to keep her CSV-based records validated, auditable, and reproducible, while handling Git operations outside BusDK.

The full, module-level flow is summarized in `workflow/accounting-workflow-overview.md`, and the rest of this section walks through concrete examples of how the pieces fit together.

