# Git-backed data repository (the data store)

The data store is a Git repository containing all business records in CSV form plus their schemas. Git is not used merely for source control; it is treated as the database. Modules treat the Git-managed files as the single source of truth. When reading data, a module operates on the current working state of the repository. When writing data, it modifies the relevant CSV files; commits describing the operation are expected to be made by the user or external automation. BusDK does not execute any Git commands or commit changes. Git provides an immutable log of changes, revert capability, and branching for experimentation or review. The Git internals model—content-addressed objects and parent-linked commits—provides a cryptographically chained record that supports tamper-evidence when histories are shared and anchor points are agreed. ([Git](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects?utm_source=chatgpt.com))

---

<!-- busdk-docs-nav start -->
**Prev:** [CLI as the primary interface (controlled read/modify/write)](./cli-as-primary-interface) · **Index:** [BusDK Design Document](../../index) · **Next:** [Independent modules (integration through shared datasets)](./independent-modules)
<!-- busdk-docs-nav end -->
