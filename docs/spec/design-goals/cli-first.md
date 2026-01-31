# CLI-first and human-friendly interfaces

BusDK is CLI-first. The primary user interface is a set of command-line tools that support day-to-day bookkeeping work directly in a repository workspace, including over SSH and in automation. The CLI should be discoverable and consistent, with a command structure that a human can learn and that scripts can rely on over time.

CLI-first is also the foundation for safe automation. BusDK exposes the same workflows to humans and to automation — including AI agents — through stable commands, explicit inputs and outputs, and predictable failure modes. When it is meaningful to do so, commands should support machine-readable output (CSV or JSON) alongside human-readable output so that downstream tooling can consume results without scraping terminal text, consistent with [AI-readiness](./ai-readiness) and [Unix-style composability (micro-tools)](./unix-composability).

The CLI’s domain language is the workspace datasets. Commands read and write tables in the repository data and validate them against their schemas, so that changes are defined in terms of the canonical dataset contents rather than hidden application state. This makes command behavior reviewable and interoperable across modules, consistent with [Schema-driven data contract (Frictionless Table Schema)](./schema-contract) and [Modularity as a first-class requirement](./modularity), and it keeps the repository intelligible with general-purpose tools, consistent with [Plain-text CSV for longevity](./plaintext-csv-longevity).

Git integration is an implementation choice, not the definition of the goal. The invariant is that each command’s effect on the canonical dataset is representable as reviewable updates to the repository data, with corrections expressed explicitly rather than silently destructive edits. When Git is used, BusDK relies on external tooling or orchestration to record revisions, consistent with [Git as the canonical, append-only source of truth](./git-as-source-of-truth).

CLI-first also shapes extensibility. Modules should be able to add focused commands that follow the same conventions for arguments, output formats, and schema validation, so that the system can grow without a monolithic interface surface or private-only APIs, consistent with [Extensibility as a first-class goal](./extensibility) and the [initial feature scope](./feature-scope).

BusDK may also be offered as a commercial web application and API product. That is an interface and packaging choice, not the definition of the goal: the open-source CLI remains free to use and remains the reference surface for workflows, validation, and dataset transformations. Any web UI or API must stay aligned with the same deterministic behavior and the same schema-driven data contract, so that a repository workspace can be operated directly via the CLI without loss of capability or integrity.

---

<!-- busdk-docs-nav start -->
**Prev:** [Auditability through append-only changes](./append-only-auditability) · **Index:** [BusDK Design Spec: Design goals and requirements](../01-design-goals) · **Next:** [Double-entry ledger accounting](./double-entry-ledger)
<!-- busdk-docs-nav end -->
