## Unix-style composability (micro-tools)

Unix-style composability is a design objective: BusDK should behave like a set of small, deterministic tools that can be combined into larger workflows. Independent commands must cooperate through stable interfaces and predictable conventions, consistent with the classic Unix approach of making programs easy to script and chain together.

In BusDK, the primary interface between tools is the workspace datasets and their schemas. Modules interoperate through tables and a schema-driven data contract — not through private module-to-module APIs — so that workflows can be assembled from focused commands while keeping the canonical dataset coherent and reviewable. This framing is aligned with [Modularity as a first-class requirement](./modularity), [Schema-driven data contract (Frictionless Table Schema)](./schema-contract), and [Git as the canonical, append-only source of truth](./git-as-source-of-truth).

Pipes and stream processing are implementation choices, not the definition of the goal. The invariant is that a command’s behavior is defined in terms of explicit inputs and outputs, and that any change to the canonical dataset is expressed as a reviewable update to the repository data rather than as hidden application storage. When commands also support machine-readable output and convenient interoperability with general-purpose tooling, the result is a system that is both CLI-friendly and automation-friendly — including for long-lived scripts and for AI-assisted workflows described in [AI-readiness](./ai-readiness).

---

<!-- busdk-docs-nav start -->
**Prev:** [Schema-driven data contract (Frictionless Table Schema)](./schema-contract) · **Index:** [BusDK Design Spec: Design goals and requirements](./) · **Next:** [BusDK Design Spec: System architecture](../architecture/)
<!-- busdk-docs-nav end -->
