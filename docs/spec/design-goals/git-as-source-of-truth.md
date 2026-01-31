# Git as the canonical, append-only source of truth

BusDK treats the working corpus of data and schemas as a versioned, append-only source of truth with a tamper-evident history. Today, the preferred default is a Git repository that tracks the tabular datasets and their schemas, because Git provides a widely understood, content-addressed commit graph that is easy to inspect, replicate, and audit. Every change—adding transactions, adding an account, recording an invoice, correcting an error — should produce a new revision that preserves prior states and makes corrections explicit rather than silently destructive.

Git is an implementation choice, not the definition of the design goal. BusDK must be able to operate when the canonical history is maintained by other storage or versioning systems, as long as they preserve an append-only, reviewable trail of changes. Storage may also be split by concern over time — for qexample, schemas may remain versioned as files in Git while transactional data is stored in a SQL database — qwithout changing the meaning of “canonical” in BusDK: the source of truth is the authoritative history and current state, regardless of the underlying mechanism.

BusDK does not execute Git commands or create commits; it relies on external tooling or orchestration to record revisions and enforce repository policy. When Git is used, its object model (content-addressed objects and parent-linked commits) provides the concrete mechanism for the tamper-evident audit log. See [Git Internals: Git Objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects).

---

<!-- busdk-docs-nav start -->
**Prev:** [Initial feature scope (modules)](./feature-scope) · **Index:** [BusDK Design Document](../../index) · **Next:** [Modularity as a first-class requirement](./modularity)
<!-- busdk-docs-nav end -->
