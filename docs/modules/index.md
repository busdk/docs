---
title: BusDK module CLI reference
description: End-user guide to BusDK module CLIs for AI product hosting, runtime providers, automation, portals, billing, and auditable business workflows.
---

## How to read the module pages

This section explains what each BusDK module is for, when you usually use it, and which command to try first. Command names follow [CLI command naming](../cli/command-naming). Most pages show a short synopsis and a few practical examples first; for the full flag list, run `bus <module> --help`.

The adjacent [aiz](./aiz) toolchain is documented here too. It is not
dispatched through `bus`, but it follows the same deterministic CLI style for
single-file `.aiz` compression and offline restore with `unaiz`.

## If you are building or operating an AI product

BusDK's AI product surface is a set of cooperating modules rather than one monolithic server. Start with [bus-api](./bus-api) for the API host, [bus-auth](./bus-auth) and [bus-api-provider-auth](./bus-api-provider-auth) for login and scoped tokens, [bus-api-provider-llm](./bus-api-provider-llm) for OpenAI-compatible model proxying, [bus-api-provider-vm](./bus-api-provider-vm) and [bus-api-provider-containers](./bus-api-provider-containers) for runtime status and container runs, and [bus-events](./bus-events) with [bus-api-provider-events](./bus-api-provider-events) for request/reply and replayed event streams.

Operational product controls are split into focused modules. [bus-billing](./bus-billing), [bus-api-provider-billing](./bus-api-provider-billing), [bus-integration-billing](./bus-integration-billing), [bus-integration-stripe](./bus-integration-stripe), [bus-integration-usage](./bus-integration-usage), and the `bus operator` family cover entitlement, checkout, usage export, internal catalog work, and service-token operations. Runtime-specific work belongs to [bus-integration-upcloud](./bus-integration-upcloud), [bus-integration-ssh-runner](./bus-integration-ssh-runner), [bus-vm](./bus-vm), and [bus-containers](./bus-containers).

Developer and agent workflows usually start with [bus-agent](./bus-agent), [bus-dev](./bus-dev), [bus-run](./bus-run), [bus-work](./bus-work), [bus-secrets](./bus-secrets), and [bus-shell](./bus-shell). Browser-facing product surfaces are covered by [bus-portal](./bus-portal), [bus-portal-auth](./bus-portal-auth), [bus-portal-ai](./bus-portal-ai), [bus-portal-accounting](./bus-portal-accounting), [bus-ui](./bus-ui), [bus-chat](./bus-chat), [bus-books](./bus-books), and [bus-api-provider-terminal](./bus-api-provider-terminal).

## If you are starting a new workspace

Most users read these module pages in roughly this order:

1. [bus](./bus), [bus-init](./bus-init), and [bus-config](./bus-config) to create a workspace and set company-wide defaults.
2. [bus-accounts](./bus-accounts) and [bus-period](./bus-period) to define your chart of accounts and accounting periods.
3. [bus-files](./bus-files), [bus-attachments](./bus-attachments), [bus-bank](./bus-bank), and [bus-invoices](./bus-invoices) to inspect incoming evidence files and bring source data into the workspace.
4. [bus-reconcile](./bus-reconcile) and [bus-journal](./bus-journal) to connect source rows to accounting entries and maintain the ledger.
5. [bus-reports](./bus-reports), [bus-status](./bus-status), and [bus-validate](./bus-validate) to review readiness, produce reports, and catch problems before close or filing.

If you need architectural background on why modules are independent and how they integrate, see [Independent modules](../architecture/independent-modules) and [Modularity](../design-goals/modularity).

For cross-module capability scanning, use the [BusDK module feature table](./features). It aggregates feature rows from each module repository `FEATURES.md` and shows user-visible capability, interface type, evidence, coverage, and maturity in one table.

### Data files and path ownership

Each module that owns workspace data defines where its data files live. Today these are conventional names at the workspace root (for example `accounts.csv`, `periods.csv`, `datapackage.json`). Only the owning module may write to those files or apply business logic to them; other tools that need read-only access should use the owning module’s documented command and file contract. The design allows future configuration of paths (for example in a data package) so that end users can customize where data is stored without breaking how other tools discover it. [`bus-files`](./bus-files) is the deliberate exception in this list: it is a filesystem-facing parser/finder surface for local evidence files and does not start from a canonical workspace dataset.

Core entrypoints are [`bus`](./bus), [`bus init`](./bus-init), [`bus config`](./bus-config), [`bus data`](./bus-data), [`bus preferences`](./bus-preferences), and [`bus status`](./bus-status). Use these when you need to dispatch commands, initialize a workspace, maintain `datapackage.json`, inspect low-level datasets and schemas, or check workspace readiness.

Local interfaces are [`bus api`](./bus-api), [`bus api provider billing`](./bus-api-provider-billing), [`bus api provider books`](./bus-api-provider-books), [`bus api provider containers`](./bus-api-provider-containers), [`bus api provider data`](./bus-api-provider-data), [`bus api provider llm`](./bus-api-provider-llm), [`bus api provider session`](./bus-api-provider-session), [`bus api provider usage`](./bus-api-provider-usage), [`bus api provider vm`](./bus-api-provider-vm), [`bus billing`](./bus-billing), [`bus sheets`](./bus-sheets), [`bus books`](./bus-books), [`bus chat`](./bus-chat), [`bus ui`](./bus-ui), and [`bus portal`](./bus-portal). They expose workspace data, assistant chat, provider adapters, billing setup, backend usage collection, model proxying, VM/container APIs, and browser-facing UIs.

Automation and developer tooling live in [`bus dev`](./bus-dev), [`bus agent`](./bus-agent), [`bus run`](./bus-run), [`bus work`](./bus-work), [`bus update`](./bus-update), [`bus secrets`](./bus-secrets), [`bus shell`](./bus-shell), [`bus gateway`](./bus-gateway), [`bus factory`](./bus-factory), [`bus events`](./bus-events), [`bus operator`](./bus-operator), [`bus operator auth`](./bus-operator-auth), [`bus operator billing`](./bus-operator-billing), [`bus operator stripe`](./bus-operator-stripe), [`bus operator token`](./bus-operator-token), [`bus integration billing`](./bus-integration-billing), [`bus integration ssh runner`](./bus-integration-ssh-runner), [`bus integration stripe`](./bus-integration-stripe), [`bus integration usage`](./bus-integration-usage), [`bus integration upcloud`](./bus-integration-upcloud), [`bus init`](./bus-init), [`bus inspection`](./bus-inspection), [`bus faq`](./bus-faq), and [`bus bfl`](./bus-bfl). `bus dev` focuses on module-repository workflows, `bus run` focuses on local user-defined prompts/scripts/pipelines, `bus work` focuses on durable asynchronous work streams over Bus Events, and `bus shell` provides an interactive or one-shot command shell that dispatches through `bus`. These modules rely on `bus-agent` where agent runtime execution is required. `bus secrets` provides deterministic secret reference storage and resolution for step-level environment configuration. `bus gateway`, `bus factory`, the API/provider modules, operator modules, and event-driven integration workers support integration and service composition around the same workspace data.

Accounting domain modules are [`bus ledger`](./bus-ledger), [`bus accounts`](./bus-accounts), [`bus balances`](./bus-balances), [`bus debts`](./bus-debts), [`bus entities`](./bus-entities), [`bus customers`](./bus-customers), [`bus vendors`](./bus-vendors), [`bus period`](./bus-period), [`bus files`](./bus-files), [`bus attachments`](./bus-attachments), [`bus invoices`](./bus-invoices), [`bus memo`](./bus-memo), [`bus journal`](./bus-journal), [`bus bank`](./bus-bank), [`bus reconcile`](./bus-reconcile), [`bus assets`](./bus-assets), [`bus loans`](./bus-loans), [`bus inventory`](./bus-inventory), [`bus payroll`](./bus-payroll), and [`bus budget`](./bus-budget).

Reporting, quality, and filing modules are [`bus reports`](./bus-reports), [`bus replay`](./bus-replay), [`bus validate`](./bus-validate), [`bus vat`](./bus-vat), [`bus pdf`](./bus-pdf), [`bus filing`](./bus-filing), [`bus filing prh`](./bus-filing-prh), and [`bus filing vero`](./bus-filing-vero).

All current top-level modules in this superproject have matching end-user pages under this reference section, including supporting modules that are less often part of the first accounting workflow pass such as [`bus auth`](./bus-auth), [`bus billing`](./bus-billing), [`bus chat`](./bus-chat), [`bus containers`](./bus-containers), [`bus events`](./bus-events), [`bus gateway`](./bus-gateway), [`bus inspection`](./bus-inspection), [`bus operator`](./bus-operator), [`bus portal`](./bus-portal), [`bus preferences`](./bus-preferences), [`bus shell`](./bus-shell), [`bus status`](./bus-status), [`bus ui`](./bus-ui), [`bus vm`](./bus-vm), and [`bus work`](./bus-work).

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
- [Deployment and data control](../integration/deployment-and-data-control)
- [Independent modules](../architecture/independent-modules)
- [Modularity](../design-goals/modularity)
- [bus-books module](./bus-books)
- [Finnish balance sheet and income statement regulation](../compliance/fi-balance-sheet-and-income-statement-regulation)
- [OpenAI Help Center: Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
