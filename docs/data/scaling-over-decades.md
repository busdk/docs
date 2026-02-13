---
title: Scaling over decades
description: CSV is viable long-term if proactively managed.
---

## Scaling over decades

CSV is viable long-term if proactively managed. To keep repositories performant and diffs focused, BusDK supports splitting data into multiple files by time period or category. A typical strategy is to segment journal entries by period using root-level files with a date prefix, such as `journal-2025.csv` and `journal-2026.csv`, instead of allowing a single file to grow indefinitely. The repository root tracks these files through `journals.csv`, which records which periods exist and where each file lives. This reduces the size and complexity of day-to-day diffs, keeps Git operations snappy, and aligns with the practical expectation that even large datasets can remain manageable when partitioned. Older data can be archived by tagging year-end commits, and where desired, by removing old-period files from active branches while retaining them in history for retrieval.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./data-package-organization">Data Package organization</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../data/index">BusDK Design Spec: Data format and storage</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./schema-evolution-and-migration">Schema evolution and migration</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
