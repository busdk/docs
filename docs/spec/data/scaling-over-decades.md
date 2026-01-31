# Scaling over decades

CSV is viable long-term if proactively managed. To keep repositories performant and diffs focused, BusDK supports splitting data into multiple files by time period or category. A typical strategy is to segment journal data by year, such as `journal_2025.csv` and `journal_2026.csv`, instead of allowing a single file to grow indefinitely. This reduces the size and complexity of day-to-day diffs, keeps Git operations snappy, and aligns with the practical expectation that even large datasets can remain manageable when partitioned. Older data can be archived by tagging year-end commits, and where desired, by removing old-year files from active branches while retaining them in history for retrieval.

---

<!-- busdk-docs-nav start -->
**Prev:** [Data Package organization](./data-package-organization) · **Index:** [BusDK Design Document](../../index) · **Next:** [Schema evolution and migration](./schema-evolution-and-migration)
<!-- busdk-docs-nav end -->
