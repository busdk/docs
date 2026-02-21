---
title: BusDK module CLI reference
description: End-user reference for all BusDK module CLIs — bus init, bus config, bus data, bus accounts, and the full command surface.
---

## BusDK module CLI reference

This section is the end user reference for the BusDK module CLIs. Each page is structured like a man page so you can quickly find the command surface, data files, and how to discover flags and subcommands. Command names follow [CLI command naming](../cli/command-naming). In synopsis lines, **[global flags]** denotes the [standard global flags](../cli/global-flags) accepted by most modules; run `bus <module> --help` for the full list for each module. For the design and implementation rationale behind each module, see the module SDDs in [Modules (SDD)](../sdd/modules).

If you need architectural background on why modules are independent and how they integrate, see [Independent modules](../architecture/independent-modules) and [Modularity](../design-goals/modularity).

### Data files and path ownership

Each module that owns workspace data defines where its data files live. Today these are conventional names at the workspace root (for example `accounts.csv`, `periods.csv`, `datapackage.json`). Only the owning module may write to those files or apply business logic to them; other tools that need read-only access to another module’s data obtain the path from that module (see the [Data path contract for read-only cross-module access](../sdd/modules#data-path-contract-for-read-only-cross-module-access) in the module SDDs). The design allows future configuration of paths (for example in a data package) so that end users can customize where data is stored without breaking how other tools discover it.

Core entrypoints are [`bus`](./bus), [`bus init`](./bus-init), [`bus config`](./bus-config), and [`bus data`](./bus-data). Use these to dispatch commands, initialize workspaces, maintain `datapackage.json`, and inspect low-level datasets and schemas.

Local interfaces are [`bus api`](./bus-api), [`bus sheets`](./bus-sheets), and [`bus books`](./bus-books). They expose workspace data through HTTP or browser-facing UIs.

Automation and developer tooling live in [`bus dev`](./bus-dev), [`bus agent`](./bus-agent), [`bus run`](./bus-run), [`bus secrets`](./bus-secrets), [`bus shell`](./bus-shell), and [`bus bfl`](./bus-bfl). `bus dev` focuses on module-repository workflows, `bus run` focuses on user-defined prompts/scripts/pipelines, and `bus shell` provides an interactive or one-shot command shell that dispatches through `bus`. These modules rely on `bus-agent` where agent runtime execution is required. `bus secrets` provides deterministic secret reference storage and resolution for step-level environment configuration. From BusDK v0.0.26 onward, Codex runtime support is available through that shared layer.

Accounting domain modules are [`bus accounts`](./bus-accounts), [`bus entities`](./bus-entities), [`bus period`](./bus-period), [`bus attachments`](./bus-attachments), [`bus invoices`](./bus-invoices), [`bus journal`](./bus-journal), [`bus bank`](./bus-bank), [`bus reconcile`](./bus-reconcile), [`bus assets`](./bus-assets), [`bus loans`](./bus-loans), [`bus inventory`](./bus-inventory), [`bus payroll`](./bus-payroll), and [`bus budget`](./bus-budget).

Reporting, quality, and filing modules are [`bus reports`](./bus-reports), [`bus replay`](./bus-replay), [`bus validate`](./bus-validate), [`bus vat`](./bus-vat), [`bus pdf`](./bus-pdf), [`bus filing`](./bus-filing), [`bus filing prh`](./bus-filing-prh), and [`bus filing vero`](./bus-filing-vero).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow/year-end-close">Year-end close (closing entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus">bus</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [CLI command naming](../cli/command-naming)
- [Standard global flags](../cli/global-flags)
- [Module SDD index](../sdd/index)
- [Modules (SDD)](../sdd/modules)
- [Independent modules](../architecture/independent-modules)
- [Modularity](../design-goals/modularity)
- [Finnish WebView bookkeeping UI requirements](../implementation/fi-webview-accounting-ui-requirements)
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [OpenAI Help Center: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
