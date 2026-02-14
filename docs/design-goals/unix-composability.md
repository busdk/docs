---
title: Unix-style composability (micro-tools)
description: "Unix-style composability is a design objective: BusDK should behave like a set of small, deterministic tools that can be combined into larger workflows."
---

## Unix-style composability (micro-tools)

Unix-style composability is a design objective: BusDK should behave like a set of small, deterministic tools that can be combined into larger workflows. Independent commands must cooperate through stable interfaces and predictable conventions, consistent with the classic Unix approach of making programs easy to script and chain together.

In BusDK, the primary interface between tools is the workspace datasets and their schemas. Modules interoperate through tables and a schema-driven data contract — not through private module-to-module APIs — so that workflows can be assembled from focused commands while keeping the canonical dataset coherent and reviewable. When a tool needs another module’s business logic, it should depend on that module through its command-line interface rather than re-implementing the logic or reaching into the other module’s data files. Direct data access is appropriate for read-only use, but the ownership of a dataset belongs to the module that defines it, so writes and changes should go through the owning module’s command interface, including any validation or domain rules it enforces. This framing is aligned with [Modularity as a first-class requirement](./modularity), [Schema-driven data contract (Frictionless Table Schema)](./schema-contract), and [Git as the canonical, append-only source of truth](./git-as-source-of-truth).

Pipes and stream processing are implementation choices, not the definition of the goal. The invariant is that a command’s behavior is defined in terms of explicit inputs and outputs, and that any change to the canonical dataset is expressed as a reviewable update to the repository data rather than as hidden application storage. When commands also support machine-readable output and convenient interoperability with general-purpose tooling, the result is a system that is both CLI-friendly and automation-friendly — including for long-lived scripts and for AI-assisted workflows described in [AI-readiness](./ai-readiness).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./schema-contract">Schema-driven data contract (Frictionless Table Schema)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Design goals and requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../architecture/index">BusDK Design Spec: System architecture</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
