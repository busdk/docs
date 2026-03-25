---
title: BusDK module CLI reference
description: End-user guide to BusDK module CLIs, with a practical reading order for starting a workspace, importing data, posting entries, and producing reports.
---

## BusDK module CLI reference

This section explains what each BusDK module is for, when you usually use it, and which command to try first. Command names follow [CLI command naming](../cli/command-naming). Most pages show a short synopsis and a few practical examples first; for the full flag list, run `bus <module> --help`.

The adjacent [aiz](./aiz) toolchain is documented here too. It is not
dispatched through `bus`, but it follows the same deterministic CLI style for
single-file `.aiz` compression and offline restore with `unaiz`.

## If you are starting a new workspace

Most users read these module pages in roughly this order:

1. [bus](./bus), [bus-init](./bus-init), and [bus-config](./bus-config) to create a workspace and set company-wide defaults.
2. [bus-accounts](./bus-accounts) and [bus-period](./bus-period) to define your chart of accounts and accounting periods.
3. [bus-attachments](./bus-attachments), [bus-bank](./bus-bank), and [bus-invoices](./bus-invoices) to bring in evidence and source data.
4. [bus-reconcile](./bus-reconcile) and [bus-journal](./bus-journal) to connect source rows to accounting entries and maintain the ledger.
5. [bus-reports](./bus-reports), [bus-status](./bus-status), and [bus-validate](./bus-validate) to review readiness, produce reports, and catch problems before close or filing.

If you need architectural background on why modules are independent and how they integrate, see [Independent modules](../architecture/independent-modules) and [Modularity](../design-goals/modularity).

For cross-module capability scanning, use the [BusDK module feature table](./features). It aggregates feature rows from each module repository `FEATURES.md` and shows user-visible capability, interface type, evidence, coverage, and maturity in one table.

### Data files and path ownership

Each module that owns workspace data defines where its data files live. Today these are conventional names at the workspace root (for example `accounts.csv`, `periods.csv`, `datapackage.json`). Only the owning module may write to those files or apply business logic to them; other tools that need read-only access should use the owning module’s documented command and file contract. The design allows future configuration of paths (for example in a data package) so that end users can customize where data is stored without breaking how other tools discover it.

Core entrypoints are [`bus`](./bus), [`bus init`](./bus-init), [`bus config`](./bus-config), and [`bus data`](./bus-data). Use these when you need to dispatch commands, initialize a workspace, maintain `datapackage.json`, or inspect low-level datasets and schemas.

Local interfaces are [`bus api`](./bus-api), [`bus sheets`](./bus-sheets), and [`bus books`](./bus-books). They expose workspace data through HTTP or browser-facing UIs.

Automation and developer tooling live in [`bus dev`](./bus-dev), [`bus agent`](./bus-agent), [`bus run`](./bus-run), [`bus update`](./bus-update), [`bus secrets`](./bus-secrets), [`bus shell`](./bus-shell), and [`bus bfl`](./bus-bfl). `bus dev` focuses on module-repository workflows, `bus run` focuses on user-defined prompts/scripts/pipelines, and `bus shell` provides an interactive or one-shot command shell that dispatches through `bus`. These modules rely on `bus-agent` where agent runtime execution is required. `bus secrets` provides deterministic secret reference storage and resolution for step-level environment configuration. From BusDK v0.0.26 onward, Codex runtime support is available through that shared layer.

Accounting domain modules are [`bus accounts`](./bus-accounts), [`bus entities`](./bus-entities), [`bus period`](./bus-period), [`bus attachments`](./bus-attachments), [`bus invoices`](./bus-invoices), [`bus journal`](./bus-journal), [`bus bank`](./bus-bank), [`bus reconcile`](./bus-reconcile), [`bus assets`](./bus-assets), [`bus loans`](./bus-loans), [`bus inventory`](./bus-inventory), [`bus payroll`](./bus-payroll), and [`bus budget`](./bus-budget).

Reporting, quality, and filing modules are [`bus reports`](./bus-reports), [`bus replay`](./bus-replay), [`bus validate`](./bus-validate), [`bus vat`](./bus-vat), [`bus pdf`](./bus-pdf), [`bus filing`](./bus-filing), [`bus filing prh`](./bus-filing-prh), and [`bus filing vero`](./bus-filing-vero).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../workflow/year-end-close">Year-end close (closing entries)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./aiz">aiz</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [CLI command naming](../cli/command-naming)
- [Standard global flags](../cli/global-flags)
- [Module reference index](../modules/index)
- [BusDK module feature table](./features)
- [Independent modules](../architecture/independent-modules)
- [Modularity](../design-goals/modularity)
- [bus-books module](./bus-books)
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [OpenAI Help Center: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
