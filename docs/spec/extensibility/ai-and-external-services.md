# AI and external service integration

AI integration is treated as an optional module layer. BusDK must remain fully functional without AI, and any AI-driven automation must operate through the same deterministic interfaces as human workflows.

An AI assistant can read structured workspace datasets, run the same CLI workflows as a human, and propose changes as reviewable updates to the repository data. When Git is used for the canonical change history, those proposals naturally take the form of commits or branches created via external Git tooling. The safety property BusDK relies on is that proposed changes remain schema-validated, auditable, and human-reviewable before acceptance, consistent with [AI-readiness (objective, not dependency)](../design-goals/ai-readiness) and [Git as the canonical, append-only source of truth](../design-goals/git-as-source-of-truth).

---

<!-- busdk-docs-nav start -->
**Prev:** [BusDK Design Spec: Extensibility model](../06-extensibility-model) · **Index:** [BusDK Design Document](../../index) · **Next:** [Governance of core schemas](./core-schema-governance)
<!-- busdk-docs-nav end -->
