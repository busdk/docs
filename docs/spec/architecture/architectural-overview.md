# Architectural overview

BusDK is a collection of loosely coupled modules centered around a single Git-backed data repository. It intentionally avoids a monolithic application design and instead follows a “micro-tool” architecture: each feature area is implemented as an independent CLI tool (or service) that reads and writes a shared dataset. Modules coordinate by sharing data and by relying on the Git history as a durable audit trail, rather than by calling each other’s internal APIs.

This design mirrors the practical benefits of Unix composability in modern toolchains, where interoperability arises from stable, simple interfaces and predictable conventions. ([catb.org](https://www.catb.org/esr/writings/taoup/html/ch01s06.html?utm_source=chatgpt.com)) In BusDK, the stable interface is the repository: a set of CSV resources governed by Frictionless schemas and organized in a consistent directory structure.

---

<!-- busdk-docs-nav start -->
**Prev:** [Append-only discipline and security model](./append-only-and-security) · **Next:** [CLI as the primary interface (controlled read/modify/write)](./cli-as-primary-interface)
<!-- busdk-docs-nav end -->
