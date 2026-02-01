## Initialize a new repository

Alice begins by creating a dedicated repository for the bookkeeping year. The baseline revision establishes the workspace layout and the initial module-owned datasets and schemas, so every later change to the workspace datasets and supporting evidence is reviewable as a normal change to repository data.

1. Alice creates the repository directory and initializes it with her version control tooling:

```bash
mkdir 2026-bookkeeping
cd 2026-bookkeeping
```

BusDK does not execute any version control commands, so repository setup and revision recording remain explicit and under her control.

2. Alice scaffolds the workspace layout and module-owned baseline datasets:

```bash
bus init --help
bus init
```

`bus init` orchestrates a deterministic sequence of module-owned init operations (for example `bus accounts init`, `bus journal init`, and `bus invoices init`) so that each module remains the sole owner of its datasets and schemas. The exact arguments depend on the chosen workspace layout and the pinned module versions, so she relies on `--help` to see the available options.

3. Alice validates that the baseline datasets and schemas are internally consistent:

```bash
bus validate --help
bus validate
```

If module-specific validation is preferred, she can run `bus accounts validate` and other module-level validators instead, but the intent is the same — the repository starts from a known-good, schema-validated baseline.

4. Alice records the initial baseline revision using her version control tooling.

From this point on, the repository is the canonical source of truth for the year’s workspace data, and the revision history provides the reviewable audit trail for all subsequent updates.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./import-bank-transactions-and-apply-payment">Import bank transactions and apply payments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./invoice-ledger-impact">Invoice ledger impact (integration through journal entries)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
