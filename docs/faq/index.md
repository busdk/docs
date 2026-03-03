---
title: "FAQ: What are bus and BusDK?"
description: Practical FAQ that explains what bus is, what BusDK is, how they relate, what modules do, and how to choose the right starting point.
---

## FAQ: What are `bus` and BusDK?

Use this page for core identity questions. For deeper practical questions, continue to [FAQ: getting started and adoption](./getting-started-and-adoption), [FAQ: workspaces, datasets, and compliance boundaries](./workspaces-datasets-and-compliance), [FAQ: AI assistants, automation, and safety](./ai-automation-and-safety), [FAQ: modules, repositories, and contribution model](./modules-repositories-and-contribution-model), and [FAQ: purchasing and pricing](./purchasing-and-pricing).

### What is `bus`?

`bus` is the public command entrypoint for BusDK workflows. It is the command users run first, and it dispatches to focused module commands such as [`bus journal`](../modules/bus-journal), [`bus invoices`](../modules/bus-invoices), [`bus reports`](../modules/bus-reports), and [`bus vat`](../modules/bus-vat).

`bus` is designed for scriptable, non-interactive use. The same commands can be used directly in terminal sessions, CI jobs, and deterministic [`.bus` script files](../cli/bus-script-files).

### What is BusDK?

BusDK is the broader Business Development Kit around `bus`. It includes the command ecosystem, documentation, [schema-driven workspace data conventions](../data/table-schema-contract), and module-level implementations that cover accounting and business operations workflows.

In short, `bus` is the main executable entrypoint, and BusDK is the full system and module family behind it.

### How do `bus` and BusDK relate?

`bus` is part of BusDK. BusDK provides [architecture](../architecture/index), contracts, modules, and docs. The `bus` command gives users one stable way to invoke those capabilities.

When a workflow needs specialization, `bus` routes to the corresponding [module surface](../modules/index). This keeps the top-level command simple while still supporting deep domain functionality.

### Is BusDK one monolith or many modules?

BusDK is modular by design. The superproject pins multiple module repositories and exposes a consistent command surface through [`bus`](../modules/bus).

This modularity allows independent lifecycle management by domain area while preserving predictable user-facing behavior.

### Why not just one big CLI?

A single monolithic CLI becomes harder to evolve safely across multiple business domains. BusDK uses module boundaries so changes remain reviewable, testable, and easier to audit per capability area.

Users still get a coherent experience through the shared `bus` [command structure](../cli/command-structure) and [global flag conventions](../cli/global-flags).

### What problem does BusDK solve?

BusDK focuses on deterministic, replayable, and review-friendly business operations. In accounting-oriented flows this means schema-backed data, explicit [workflow steps](../workflow/index), traceability, and [CLI-first automation](../design-goals/cli-first) that can run the same way in local environments and CI.

### Is BusDK only for accounting?

No. Accounting is a major current use case, but the architecture is broader. BusDK also includes development and automation modules such as [`bus-dev`](../modules/bus-dev) and [`bus-run`](../modules/bus-run), API integration paths through [`bus-api`](../modules/bus-api), and UI modules such as [`bus-ledger`](../modules/bus-ledger) and [`bus-factory`](../modules/bus-factory) built on shared components.

The core model is reusable: explicit data contracts, deterministic command behavior, and modular capability boundaries.

### What is a BusDK workspace?

A workspace is a repository-shaped working area that contains [datasets](../data/index), schemas, and [`.bus` automation scripts](../cli/bus-script-files). Commands run against this workspace data and produce outputs deterministically from declared inputs.

This keeps operations reproducible and easier to review over time.

### What are `.bus` files?

[`.bus` files](../cli/bus-script-files) are deterministic command scripts for Bus workflows. They let teams encode repeatable sequences instead of relying on manual command history.

They are useful for standard operating procedures, periodic runs, and machine-verifiable replay of workflows.

### How do I decide whether to use `bus` or a module command directly?

Start with [`bus`](../modules/bus). Use module subcommands when the workflow needs specific domain controls. In practice this is usually `bus <module> ...`, which keeps commands discoverable and consistent through the [module CLI reference](../modules/index).

Direct module binaries exist in module repositories, but normal user workflows should prefer the `bus` command surface unless there is a module-specific reason not to.

### Is BusDK open source?

BusDK is partly open source, but mostly commercial subscription-based software. The superproject, [`bus`](../modules/bus), `docs`, and `busdk.com` are public, while many `bus-*` modules are private/commercial repositories.

For users, the command surface remains consistent. For maintainers, this separation keeps public orchestration and documentation clean while allowing private module implementation boundaries.

### Does BusDK include a web UI?

Yes. BusDK includes UI modules such as [`bus-ledger`](../modules/bus-ledger) and [`bus-factory`](../modules/bus-factory). These UIs use shared [`bus-ui`](../modules/bus-ui) components and still follow the same deterministic, workspace-local operating model as CLI workflows.

### Where should I start?

Start with the docs overview, then the workflow pages, then module reference pages for concrete commands. If you are implementing or integrating modules, continue from there to the private SDD workspace for detailed design contracts.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./getting-started-and-adoption">FAQ: getting started and adoption</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK Docs home](../index)
- [Overview](../overview/index)
- [CLI tooling and workflow](../cli/index)
- [`.bus` script files](../cli/bus-script-files)
- [Module CLI reference](../modules/index)
- [System architecture](../architecture/index)
- [Data format and storage](../data/index)
- [FAQ: getting started and adoption](./getting-started-and-adoption)
- [FAQ: workspaces, datasets, and compliance boundaries](./workspaces-datasets-and-compliance)
- [FAQ: AI assistants, automation, and safety](./ai-automation-and-safety)
- [FAQ: modules, repositories, and contribution model](./modules-repositories-and-contribution-model)
- [FAQ: purchasing and pricing](./purchasing-and-pricing)
