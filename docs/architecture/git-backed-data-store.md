## Git-backed data repository (the data store)

The preferred default data store for BusDK is a Git repository that tracks the workspace datasets (tabular records plus schemas) and supporting evidence as repository data. Git is an implementation choice, not the definition of the goal: the invariant BusDK relies on is that the canonical dataset and its change history remain reviewable and append-only, regardless of whether revisions are recorded in Git or by some other mechanism.

When Git is used, modules treat the repository data as the canonical source of truth for both human and automated workflows. When reading data, a module operates on the current working tree contents of the repository. When writing data, it produces explicit updates to the relevant tables and schemas in the repository data. BusDK does not execute Git commands or create commits; revisions are recorded by the user or by external tooling or orchestration. Git provides a widely understood, content-addressed commit graph that supports inspection, replication, diff-based review, and tamper-evident history. The Git internals model — content-addressed objects and parent-linked commits — provides the concrete mechanism behind that history when anchor points are agreed and histories are shared. See [Git Internals: Git Objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects).

This Git-backed filesystem repository is the default implementation of the workspace store interface. Git remains external revision tooling and is not part of the storage backend contract; the storage interface focuses on deterministic table and schema persistence, while change history is maintained by external tooling. See [Storage backends and workspace store interface](../data/storage-backends).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./cli-as-primary-interface">CLI as the primary interface (controlled read/modify/write)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../architecture/index">BusDK Design Spec: System architecture</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./independent-modules">Independent modules (integration through shared datasets)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
