# Git as the canonical, append-only source of truth

Git is the canonical, append-only source of truth. The Git repository containing the CSV resources and schemas is treated as the system’s database of record. Every change to any CSV—adding transactions, adding an account, recording an invoice, correcting an error—should be captured as a commit that contributes to an immutable history of modifications, using external Git tooling. BusDK does not execute any Git commands or commit changes. The underlying Git model stores objects addressed by cryptographic hashes, with commit objects referencing their parent commits, forming a hash-linked history. ([Git](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects?utm_source=chatgpt.com)) BusDK leverages this structure to maintain a tamper-evident audit log of bookkeeping activity, consistent with the accounting requirement that historical records are preserved and corrections are explicit rather than silently destructive.

---

<!-- busdk-docs-nav start -->
**Prev:** [Initial feature scope (modules)](./feature-scope) · **Next:** [Modularity as a first-class requirement](./modularity)
<!-- busdk-docs-nav end -->
