# Architectural overview

BusDK is a collection of loosely coupled modules centered around a canonical dataset with a reviewable, append-only change history. It intentionally avoids a monolithic application design and instead follows a “micro-tool” architecture: each feature area is implemented as an independent CLI tool (or service) that reads and writes shared workspace datasets (tables plus schemas) as repository data. Modules coordinate by sharing data and by relying on an append-only revision history, rather than by calling each other’s internal APIs.

This design mirrors the practical benefits of Unix composability in modern toolchains, where interoperability arises from stable, simple interfaces and predictable conventions. See [The Art of Unix Programming: Basics of the Unix Philosophy](https://www.catb.org/esr/writings/taoup/html/ch01s06.html). In BusDK, the stable interface is the workspace datasets and their schemas: tables governed by a schema-driven data contract and organized in a consistent directory structure. The preferred default is that the repository is a Git repository and tables are stored as CSV, but Git and CSV are implementation choices rather than the definition of the architectural goal.

---

<!-- busdk-docs-nav start -->
**Prev:** [Append-only discipline and security model](./append-only-and-security) · **Index:** [BusDK Design Spec: System architecture](../architecture/) · **Next:** [CLI as the primary interface (controlled read/modify/write)](./cli-as-primary-interface)
<!-- busdk-docs-nav end -->
