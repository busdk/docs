---
title: Module source access and pricing
description: Pricing for BusDK modules offered under source-available licenses, including foundational cost allocation and how to request source access.
---

## Module source access and pricing

This page defines how BusDK module source access is licensed and priced. Sellable modules are offered under source-available terms using the [Functional Source License (FSL)](https://fsl.software/). FSL converts each released version to Apache 2.0 or MIT after two years. This price list excludes foundational modules from source-access sales pricing, but not all foundational modules are binary-only: the dispatcher `bus`, the documentation site, and `busdk.com` are already open source. The pricing below uses the [Bus project cost summary](./cost-summary) snapshot (2026-02-18) and combines each module’s own cost with a commit-based share of foundational cost to produce one module price.

### Foundational modules (cost allocation pool)

The following components are excluded from this source-access sale list and used as the foundational cost allocation pool. `bus`, `docs`, and `busdk.com` are open source, and their source repositories are available at `https://github.com/busdk/{NAME}` (for example [`bus`](https://github.com/busdk/bus), [`docs`](https://github.com/busdk/docs), and [`busdk.com`](https://github.com/busdk/busdk.com)). The remaining foundational modules are currently distributed as binaries.

| Module | Total (AI + human) USD |
|--------|-------------------------|
| [bus](../modules/bus) | 685.69 |
| docs | 5,622.54 |
| busdk.com | 313.46 |
| [bus-dev](../modules/bus-dev) | 1,175.47 |
| [bus-agent](../modules/bus-agent) | 293.87 |
| **Total foundational cost** | **8,091.03** |

Total commits in the snapshot are 1,388; the foundational modules account for 413 of those. The remaining 975 commits belong to the sellable modules. Each sellable module’s price is its **Total (AI + human) USD** from the cost summary plus its **commit-based share** of the 8,091.03 USD foundational cost (i.e. module_commits ÷ 975 × 8,091.03).

### Source-available modules and price

Module order matches the cost summary. *Module cost* is the module’s own Total (AI + human) USD. *Foundational share* is (commits ÷ 975) × 8,091.03. *Price (USD)* is the sum of those two and is the listed sale price for that module.

| Module | Commits | Module cost (USD) | Foundational share (USD) | Price (USD) |
|--------|---------|-------------------|--------------------------|-------------|
| [bus-accounts](../modules/bus-accounts) | 54 | 1,057.92 | 448.12 | 1,506.04 |
| [bus-api](../modules/bus-api) | 24 | 470.19 | 199.16 | 669.35 |
| [bus-assets](../modules/bus-assets) | 43 | 842.42 | 356.84 | 1,199.26 |
| [bus-attachments](../modules/bus-attachments) | 28 | 548.55 | 232.36 | 780.91 |
| [bus-balances](../modules/bus-balances) | 16 | 313.46 | 132.78 | 446.24 |
| [bus-bank](../modules/bus-bank) | 40 | 783.65 | 331.94 | 1,115.59 |
| [bus-bfl](../modules/bus-bfl) | 17 | 333.05 | 141.07 | 474.12 |
| [bus-books](../modules/bus-books) | 44 | 862.01 | 365.13 | 1,227.14 |
| [bus-budget](../modules/bus-budget) | 27 | 528.96 | 224.06 | 753.02 |
| [bus-config](../modules/bus-config) | 10 | 195.91 | 82.98 | 278.89 |
| [bus-data](../modules/bus-data) | 49 | 959.97 | 406.63 | 1,366.60 |
| [bus-entities](../modules/bus-entities) | 48 | 940.38 | 398.33 | 1,338.71 |
| [bus-filing](../modules/bus-filing) | 24 | 470.19 | 199.16 | 669.35 |
| [bus-filing-prh](../modules/bus-filing-prh) | 22 | 431.01 | 182.57 | 613.58 |
| [bus-filing-vero](../modules/bus-filing-vero) | 35 | 685.69 | 290.45 | 976.14 |
| [bus-init](../modules/bus-init) | 19 | 372.24 | 157.67 | 529.91 |
| [bus-inventory](../modules/bus-inventory) | 20 | 391.83 | 165.97 | 557.80 |
| [bus-invoices](../modules/bus-invoices) | 42 | 822.83 | 348.54 | 1,171.37 |
| [bus-journal](../modules/bus-journal) | 66 | 1,293.03 | 547.70 | 1,840.73 |
| [bus-loans](../modules/bus-loans) | 28 | 548.55 | 232.36 | 780.91 |
| [bus-payroll](../modules/bus-payroll) | 23 | 450.59 | 190.87 | 641.46 |
| [bus-pdf](../modules/bus-pdf) | 27 | 528.96 | 224.06 | 753.02 |
| [bus-period](../modules/bus-period) | 74 | 1,449.76 | 614.09 | 2,063.85 |
| [bus-preferences](../modules/bus-preferences) | 4 | 78.37 | 33.19 | 111.56 |
| [bus-reconcile](../modules/bus-reconcile) | 33 | 646.51 | 273.85 | 920.36 |
| [bus-replay](../modules/bus-replay) | 17 | 333.05 | 141.07 | 474.12 |
| [bus-reports](../modules/bus-reports) | 44 | 862.01 | 365.13 | 1,227.14 |
| [bus-run](../modules/bus-run) | 16 | 313.46 | 132.78 | 446.24 |
| [bus-sheets](../modules/bus-sheets) | 6 | 117.55 | 49.79 | 167.34 |
| [bus-validate](../modules/bus-validate) | 26 | 509.38 | 215.76 | 725.14 |
| [bus-vat](../modules/bus-vat) | 49 | 959.97 | 406.63 | 1,366.60 |

To buy source access for one or more modules, email [sales@hg.fi](mailto:sales@hg.fi) and include the module names you are interested in.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./cost-summary">Bus project cost summary</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Bus project cost summary](./cost-summary) (snapshot 2026-02-18)
- [Functional Source License (FSL)](https://fsl.software/)
