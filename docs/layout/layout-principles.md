## Data directory layout (principles)

BusDK organizes data so commands operate directly in the current working directory. Canonical module datasets live in the repository root as plain files, with their JSON Table Schemas stored beside them using the same base name.

When a module needs multiple files over time, the repository root still contains a single index table (for example `journals.csv`, `attachments.csv`, or `vat-reports.csv`) that records which files exist, which period each file covers, and where it lives in the repository. Most datasets keep their files directly in the repository root and use a `YYYY[MM[DD]]-name.suffix` prefix for disambiguation. Journal entries are the exception: period journal files live under a period directory such as `2026/journals/2026-journal.csv` while the index table `journals.csv` remains in the repository root.

For Finnish compliance, the layout MUST support audit-trail review and long-term readability, and it MUST be documented in the repository methods description. See [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./journal-area">Journal area (general ledger transactions)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../layout/index">BusDK Design Spec: Data directory layout</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./minimal-workspace-baseline">Minimal workspace baseline (after initialization)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
