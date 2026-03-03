---
title: "FAQ: Modules, repositories, and contribution model"
description: FAQ on BusDK module boundaries, superproject layout, public and private repositories, and practical contribution paths.
---

## FAQ: Modules, repositories, and contribution model

### Why does BusDK use a superproject with module repositories?

The superproject provides orchestration and pinned module revisions while each module can evolve in its own repository boundary. This keeps release coordination explicit and reduces accidental cross-module coupling, as described in [independent modules](../architecture/independent-modules).

### Are all BusDK modules public?

No. The superproject, [`bus`](../modules/bus), documentation site, and `busdk.com` are public. Many `bus-*` modules are private/commercial repositories. This split keeps public interfaces discoverable while allowing private implementation boundaries.

### If modules are separate, how do users get one coherent experience?

The [`bus` command surface](../modules/bus) and shared conventions from [CLI command naming](../cli/command-naming) and [global flags](../cli/global-flags) provide that coherence. Users operate through stable command patterns, while maintainers keep implementation concerns modular behind those patterns.

### Where should generic UI or runtime behavior live?

Shared behavior should live in shared modules such as [`bus-ui`](../modules/bus-ui), then be reused by UI applications such as [`bus-ledger`](../modules/bus-ledger) and [`bus-factory`](../modules/bus-factory). Re-implementing common behavior in each module increases divergence and maintenance risk.

### How should contributors decide where a change belongs?

Put the change in the smallest owning boundary that can safely host it. Module-specific business behavior belongs to that module. Cross-module primitives belong in shared libraries with downstream compatibility checks, aligned with [modularity](../design-goals/modularity).

### Do module changes require docs updates?

Yes. User-visible behavior changes should update [module docs](../modules/index) and [design references](../modules/index) in the same change set so documentation remains a reliable operational reference.

### Can teams maintain private extensions without forking everything?

Yes. BusDK’s modular structure allows private capability layers to evolve without rewriting public orchestration and documentation layers, as long as command and data contracts from [module CLI reference](../modules/index) and [data contracts](../data/table-schema-contract) remain compatible.

### Where can I discover module capability coverage quickly?

Use the [module feature table](../modules/features) for cross-module capability scanning, then open the relevant module page for command details and the [module reference](../modules/index) page for design-level contracts.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./ai-automation-and-safety">FAQ: AI assistants, automation, and safety</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">FAQ index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../modules/index">Module CLI reference</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference index](../modules/index)
- [BusDK module feature table](../modules/features)
- [Architecture: independent modules](../architecture/independent-modules)
- [Design goals: modularity](../design-goals/modularity)
- [bus-ui module reference](../modules/bus-ui)
