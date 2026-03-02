---
title: "FAQ: Getting started and adoption"
description: Practical FAQ for first-time BusDK users covering setup flow, learning order, migration strategy, and team adoption.
---

## FAQ: Getting started and adoption

### What is the fastest way to start using BusDK?

Start with [workspace initialization](../workflow/initialize-repo), then run one end-to-end business scenario from the [workflow pages](../workflow/index). This gives you a concrete baseline repository layout, command behavior, and expected outputs before you customize anything.

### Which docs should I read first if I only have one hour?

Read the [overview page](../overview/index) first, then the [workflow index](../workflow/index), then the [module CLI reference index](../modules/index). This sequence gives you system purpose, operational flow, and exact command surfaces without forcing you into deep design material too early.

### Should I migrate all legacy processes at once?

No. A phased migration is safer. Start from one workflow boundary, keep source evidence intact, and verify deterministic replay with [`bus replay`](../modules/bus-replay) before moving to the next area. BusDK’s [modular design](../design-goals/modularity) supports incremental adoption without requiring a single big cutover.

### How do I train a team that currently uses spreadsheet-only processes?

Treat BusDK as a workflow standardization layer rather than a replacement narrative. Keep familiar business steps, but run them through deterministic commands and tracked [workspace datasets](../data/index) so review, replay, and audit evidence become consistent.

### Can I use BusDK in CI from day one?

Yes. The [CLI-first model](../design-goals/cli-first) is intended for non-interactive execution. Teams typically start local, then promote validated [`.bus` scripts](../cli/bus-script-files) into CI so the same commands run in both environments.

### How should we choose which module to adopt first?

Choose the module that closes the highest-risk manual gap in your current process. For many teams this is [journal](../modules/bus-journal), [invoice](../modules/bus-invoices), [bank](../modules/bus-bank), or [reconciliation](../modules/bus-reconcile) flow. The [module reference pages](../modules/index) and [feature table](../modules/features) help map use cases to module surfaces.

### How do we know an adoption step is complete?

Treat completion as evidence-based. A step is complete when command outputs are reproducible from declared inputs, review checkpoints are documented, and the workflow can be replayed without hidden manual decisions.

### How do we avoid over-customizing too early?

Use defaults first and postpone custom extensions until baseline flows are stable. BusDK supports extensibility, but early over-customization increases migration complexity and makes root-cause analysis harder.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">FAQ: what are bus and BusDK?</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">FAQ index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./workspaces-datasets-and-compliance">FAQ: workspaces, datasets, and compliance boundaries</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Overview](../overview/index)
- [Workflow index](../workflow/index)
- [Module CLI reference](../modules/index)
- [BusDK module feature table](../modules/features)
- [CLI tooling and workflow](../cli/index)
