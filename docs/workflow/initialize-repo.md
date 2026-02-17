---
title: Initialize a new repository
description: Alice begins by creating a dedicated repository for the bookkeeping year.
---

## Initialize a new repository

Alice begins by creating a dedicated repository for the bookkeeping year. The baseline revision establishes the workspace layout and the initial module-owned datasets and schemas, so every later change to the workspace datasets and supporting evidence is reviewable as a normal change to repository data.

The minimal “must exist after initialization” baseline is defined in [Minimal workspace baseline (after initialization)](../layout/minimal-workspace-baseline).

1. Alice creates the repository directory and initializes it with her version control tooling:

```bash
mkdir 2026-bookkeeping
cd 2026-bookkeeping
```

BusDK does not execute any version control commands, so repository setup and revision recording remain explicit and under her control.

2. Alice confirms the CLI is available:

```bash
bus -V
bus -h
```

3. Alice scaffolds the workspace. By default, `bus init` creates only workspace configuration (`datapackage.json` and accounting entity settings). The descriptor is created or ensured via the data layer before accounting entity settings are applied. To create the full standard baseline (config plus all domain datasets), she passes the module-include flags:

```bash
bus init all
```

She can instead run `bus init` with no flags to get only `datapackage.json`, or pass a subset of flags (e.g. `bus init --accounts --entities --journal`) to initialize only the domains she needs. Each module remains the sole owner of its datasets and schemas; `bus init` delegates to `bus config init` and then to each selected module’s `init` in a deterministic order.

4. Alice validates that the baseline datasets and schemas are internally consistent:

```bash
bus validate
bus accounts validate
bus entities validate
bus journal validate
bus invoices validate
bus bank validate
```

The aggregate validator exists to provide a stable “is the workspace data coherent?” check, but module-level validators remain the lowest-level surface area that makes ownership and failure modes explicit.

5. Alice records the initial baseline revision using her version control tooling.

To change accounting entity settings (base currency, fiscal year, VAT registration, or VAT reporting period) after initialization, run `bus config configure` with the desired flags; see the [bus config](../modules/bus-config) CLI reference.

From this point on, the repository is the canonical source of truth for the year’s workspace data, and the revision history provides the reviewable audit trail for all subsequent updates.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./import-bank-transactions-and-apply-payment">Import bank transactions and apply payments</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./invoice-ledger-impact">Invoice ledger impact (integration through journal entries)</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
