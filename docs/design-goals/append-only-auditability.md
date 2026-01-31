## Auditability through append-only changes

Auditability is a core constraint for BusDK: the workspace datasets must remain reviewable in a way that makes it straightforward to answer what changed, when it changed, who changed it, and why. The practical consequence is an append-only discipline for business and accounting records. When something is wrong, it is corrected by adding new records that explicitly describe the correction (for example, reversal and adjustment postings) rather than rewriting or erasing prior records.

Git is a preferred default mechanism for the canonical change history, not the definition of the goal. When the workspace data is stored in a Git repository, the commit graph provides a widely understood, content-addressed, tamper-evident revision history, and diffs make both automated changes and manual edits visible during review. The invariant BusDK relies on is that the change history is append-only and inspectable, regardless of whether the underlying system is Git or some other versioning or storage mechanism. See [Git as the canonical, append-only source of truth](./git-as-source-of-truth).

Append-only discipline must apply at the level where audits and reviews are performed: the tables and schemas that constitute the canonical dataset. A schema-driven data contract makes revisions interpretable over time and supports validation and meaningful diffs as both tables and schemas evolve. See [Schema-driven data contract (Frictionless Table Schema)](./schema-contract).

Auditability is also a durability requirement. The canonical dataset should remain readable with general-purpose tooling over long retention periods, and corrections should remain legible even if BusDK itself is not available. BusDK’s default preference for plain-text CSV paired with explicit schemas supports this, but the longevity requirement is the goal, not the file format. See [Plain-text CSV for longevity](./plaintext-csv-longevity).

In accounting terms, append-only auditability means that the ledger remains reproducible and traceable: a reported figure must be explainable by a chain of records from originating evidence into postings and onward into reports, and corrections must preserve history rather than hiding it. This expectation aligns with the ledger invariants described in [Double-entry ledger accounting](./double-entry-ledger), while the storage-level mechanics for soft deletion and append-only updates are defined in [Append-only updates and soft deletion](../data/append-only-and-soft-deletion).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-readiness">AI-readiness (objective, not dependency)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./cli-first">CLI-first and human-friendly interfaces</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
