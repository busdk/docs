## AI and external service integration

AI integration is treated as an optional module layer. BusDK must remain fully functional without AI, and any AI-driven automation must operate through the same deterministic interfaces as human workflows.

An AI assistant can read structured workspace datasets, run the same CLI workflows as a human, and propose changes as reviewable updates to the repository data. When Git is used for the canonical change history, those proposals naturally take the form of commits or branches created via external Git tooling. The safety property BusDK relies on is that proposed changes remain schema-validated, auditable, and human-reviewable before acceptance, consistent with [AI-readiness (objective, not dependency)](../design-goals/ai-readiness) and [Git as the canonical, append-only source of truth](../design-goals/git-as-source-of-truth).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../extensibility/">BusDK Design Spec: Extensibility model</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../../index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./core-schema-governance">Governance of core schemas</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
