BusDK is a modular, CLI-first toolkit for running a business, built on open, long-lived formats and transparent, auditable workflows. The preferred default is that workspaces live in Git repositories and business data is stored as UTF-8 CSV datasets validated with Frictionless Data Table Schemas (JSON), but Git and CSV are implementation choices: the goal is that the workspace datasets and their change history remain reviewable and exportable. The system favors deterministic workflows that work for both humans and AI agents. See [busdk.com](https://busdk.com/) for a high-level overview.

Status: pre-release, under active development. Interfaces and schemas may still change.

BusDK’s accounting workflow and its end-to-end bookkeeping sequence are defined in the spec. Start with [Accounting workflow overview](workflow/accounting-workflow-overview) for the narrative flow, then use the section index below for thematic entries and the [Modules index](./modules/) for per-module reference details and CLI entry points.

### Spec index

- [Overview](overview/)
- [Design goals and requirements](design-goals/)
- [System architecture](architecture/)
- [Data formats and storage](data/)
- [Data directory layout](layout/)
- [CLI tooling and workflow](cli/)
- [Example end-to-end workflow](workflow/)
- [Modules](./modules/)
- [Integration and future interfaces](integration/)
- [Extensibility model](extensibility/)
- [Finnish bookkeeping and tax-audit compliance](compliance/fi-bookkeeping-and-tax-audit)
- [References and external foundations](references/)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">—</span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./overview/">BusDK Design Spec: Overview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
