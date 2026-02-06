## BusDK design spec

BusDK is a modular, CLI-first toolkit for running a business, built on open, long-lived formats and transparent, auditable workflows. The preferred default is that workspace datasets live in the Git repository and are stored as UTF-8 CSV tables validated with Frictionless Data Table Schemas (JSON), but Git and CSV are implementation choices: the goal is that the workspace datasets and their change history remain reviewable and exportable. The system favors deterministic workflows that work for both humans and AI agents. See [busdk.com](https://busdk.com/) for a high-level overview.

### Document control

Title: BusDK design spec  
Project: BusDK  
Document ID: `BUSDK-DESIGN-SPEC`  
Version: 2026-02-06  
Status: Draft  
Last updated: 2026-02-06  
Owner: BusDK development team  
Change log: 2026-02-06 — Refinements for determinism, terminology, and sources formatting.

### Review notes

This revision makes the design spec easier to verify and cite by adding explicit document-control metadata and by aligning external references with the “Sources” convention. It does not change the intended architecture, data contracts, or workflows described in the section pages.

Project status: pre-release, under active development. Interfaces and schemas may still change.

The multi-page spec is the canonical reference. If you need a single-page SDD view for review or implementation planning, see [BusDK Software Design Document (SDD)](./sdd).

BusDK’s accounting workflow and its end-to-end bookkeeping sequence are defined in the spec. Start with [Accounting workflow overview](workflow/accounting-workflow-overview) for the narrative flow, then use the section index below for thematic entries and the [Modules index](./modules/index) for per-module reference details and CLI entry points.

### Spec index

- [Overview](overview/index)
- [Design goals and requirements](design-goals/index)
- [System architecture](architecture/index)
- [Data formats and storage](data/index)
- [Data directory layout](layout/index)
- [CLI tooling and workflow](cli/index)
- [Example end-to-end workflow](workflow/index)
- [Modules](modules/index)
- [Integration and future interfaces](integration/index)
- [Extensibility model](extensibility/index)
- [Finnish bookkeeping and tax-audit compliance](compliance/fi-bookkeeping-and-tax-audit)
- [References and external foundations](references/index)

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">—</span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Document</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./overview/index">BusDK Design Spec: Overview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
