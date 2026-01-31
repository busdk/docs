BusDK is a modular, CLI-first toolkit for running a business, built on open, long-lived formats and transparent, auditable workflows. The preferred default is that workspaces live in Git repositories and business data is stored as UTF-8 CSV datasets validated with Frictionless Data Table Schemas (JSON), but Git and CSV are implementation choices: the goal is that the workspace datasets and their change history remain reviewable and exportable. The system favors deterministic workflows that work for both humans and AI agents. See [busdk.com](https://busdk.com/) for a high-level overview.

Status: pre-release, under active development. Interfaces and schemas may still change.

BusDK’s accounting workflow and its end-to-end bookkeeping sequence are defined in the spec. Start with [Accounting workflow overview](spec/workflow/accounting-workflow-overview) for the narrative flow, then use the [Modules index](./modules/) for per-module reference details and CLI entry points.

### Spec index

- [Overview](spec/overview/)
- [Design goals and requirements](spec/design-goals/)
- [System architecture](spec/architecture/)
- [Data formats and storage](spec/data/)
- [Data directory layout](spec/layout/)
- [CLI tooling and workflow](spec/cli/)
- [Example end-to-end workflow](spec/workflow/)
- [Modules](./modules/)
- [Integration and future interfaces](spec/integration/)
- [Extensibility model](spec/extensibility/)
- [Finnish bookkeeping and tax-audit compliance](spec/compliance/fi-bookkeeping-and-tax-audit)
- [References and external foundations](spec/references/)

---

<!-- busdk-docs-nav start -->
**Prev:** — · **Index:** [BusDK Design Document](./index) · **Next:** [BusDK Design Spec: Overview](./spec/overview/)
<!-- busdk-docs-nav end -->
