---
title: Purpose and scope
description: BusDK is a modular platform for self-hostable AI products, CLI automation, API providers, portals, runtime workers, and auditable business data.
---

## Current scope

BusDK (Business Development Kit), formerly known as Bus, is a modular platform for building and operating AI products. It combines deterministic command-line tools, API providers, event-driven integration workers, portal modules, VM and container runtime clients, authentication, billing, usage capture, and auditable workspace data. The same platform can run as a managed service, as a dedicated deployment, or inside infrastructure controlled by the customer.

BusDK remains command-line-first because the CLI is the stable automation and review surface. Modules can also expose HTTP APIs, browser portals, event workers, and service integrations around those same contracts. AI assistants and service workers are expected to use deterministic module surfaces rather than bypassing ownership boundaries or writing directly to another module's data.

Accounting and bookkeeping are still major BusDK use cases. Ledger entries, invoicing, VAT (ALV), bank imports, reconciliation, reporting, filing, evidence handling, and budgeting use transparent workspace datasets with schemas and reviewable change history. They now sit alongside AI platform modules such as `bus auth`, `bus billing`, `bus api provider llm`, `bus events`, `bus work`, `bus vm`, `bus containers`, portal modules, and integration workers.

This documentation defines BusDK’s goals, system architecture, data formats and storage conventions, CLI tooling and workflow expectations, extensibility model, canonical data directory layout, deployment boundaries, and example workflows. Finnish bookkeeping and tax-audit compliance requirements are specified separately in [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit). Deployment ownership and data-control choices are described in [Deployment and data control](../integration/deployment-and-data-control).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">BusDK overview</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK overview</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./visual-identity">Visual identity and branding on outputs</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Overview index](./index)
- [Design goals index](../design-goals/index)
- [Architecture index](../architecture/index)
- [Deployment and data control](../integration/deployment-and-data-control)
