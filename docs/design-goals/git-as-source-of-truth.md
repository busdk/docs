---
title: Git as the canonical, append-only source of truth
description: BusDK treats the workspace datasets and schemas as a versioned, append-only source of truth with a tamper-evident change history.
---

## Git as the canonical, append-only source of truth

BusDK treats the workspace datasets and schemas as a versioned, append-only source of truth with a tamper-evident change history. Today, the preferred default is a Git repository that tracks the tabular datasets and their schemas, because Git provides a widely understood, content-addressed commit graph that is easy to inspect, replicate, and audit. Every change — adding transactions, adding an account, recording an invoice, correcting an error — produces a new revision that preserves prior revisions and makes corrections explicit rather than silently destructive, consistent with [Auditability through append-only changes](./append-only-auditability).

Git is an implementation choice, not the definition of the design goal. BusDK can operate when the canonical change history is maintained by other storage or versioning systems, as long as they preserve an append-only, reviewable trail of changes. Storage may also be split by concern over time — for example, schemas may remain versioned as files in Git while transactional tables are stored in a SQL database — without changing the meaning of “canonical” in BusDK: the source of truth is the authoritative revision history and the authoritative current dataset contents, regardless of the underlying mechanism.

BusDK does not execute Git commands or create commits; it relies on external tooling or orchestration to record revisions and enforce repository policy. When Git is used, its object model (content-addressed objects and parent-linked commits) provides the concrete mechanism for the tamper-evident audit log. See [Git Internals: Git Objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./feature-scope">Initial feature scope (modules)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./modularity">Modularity as a first-class requirement</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Design goals index](./index)
- [Architectural overview](../architecture/architectural-overview)
- [Purpose and scope](../overview/purpose-and-scope)
