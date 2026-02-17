---
title: Bus project cost summary
description: Snapshot of total days, commits, and AI-related spend across the BusDK org (2026-02-17), with cost per day, commits per day, per-module breakdown including avg commits per day per module, and average cost per commit.
---

## Overview

This page summarizes project cost metrics captured on **2026-02-17 at approximately 22:52 Europe/Helsinki (EET, UTC+02:00)**. The numbers are intended as a snapshot for comparing relative effort and spend across repositories.

**Total commits** across the BusDK org repositories are used as a proxy for work units. **Total cost** is the sum of AI-related spend (Cursor team subscription and usage, plus ChatGPT Plus and any extra costs). Commits were mostly produced via automated AI-driven commit workflows, so commits are intended to be small and semantically meaningful; that makes the metric useful for comparing relative effort across modules.

All amounts are in **USD**. Totals may not exactly match the sum of per-module rounded values because of rounding; the stated totals below are authoritative.

### Totals

| Metric | Value |
|--------|--------|
| **Date span** | 2025-12-25 to 2026-02-17 |
| **Active days (union)** | 20 |
| **Total commits** | 1,327 |
| **Avg commits per day** | 66.35 |
| **Busiest day** | 2026-02-17 (210 commits) |
| **Avg active modules per day** | 12.90 |
| **Total cost** | **1,090.31 USD** |
| **Cost per active day** | **54.52 USD** |
| **Approximate average cost per commit** | **0.82 USD** |

### Cost breakdown

| Component | USD |
|-----------|-----|
| ChatGPT Plus | 21.76 |
| Cursor team (spend over included) | 973.45 |
| Cursor team (included) | 95.10 |
| Cursor team total | 1,068.55 |
| Extra costs | 0 |
| **Overall total** | **1,090.31** |

### Per-module breakdown

Module order below matches the source snapshot (no reordering). *Active days* is the number of distinct days with at least one commit in that module. *Avg commits/day* is commits divided by active days for that module (average on days when the module had commits). Cost per module is derived from each module’s share of total commits.

| Module | Commits | Active days | Avg commits/day | % of commits | Cost (USD) | % of cost |
|--------|--------|-------------|-----------------|---------------|------------|-----------|
| [bus](../modules/bus) | 35 | 9 | 3.89 | 2.6% | 28.76 | 2.6% |
| [bus-accounts](../modules/bus-accounts) | 53 | 8 | 6.62 | 4.0% | 43.55 | 4.0% |
| [bus-agent](../modules/bus-agent) | 15 | 2 | 7.50 | 1.1% | 12.32 | 1.1% |
| [bus-api](../modules/bus-api) | 19 | 3 | 6.33 | 1.4% | 15.61 | 1.4% |
| [bus-assets](../modules/bus-assets) | 40 | 10 | 4.00 | 3.0% | 32.87 | 3.0% |
| [bus-attachments](../modules/bus-attachments) | 27 | 10 | 2.70 | 2.0% | 22.18 | 2.0% |
| [bus-balances](../modules/bus-balances) | 16 | 2 | 8.00 | 1.2% | 13.15 | 1.2% |
| [bus-bank](../modules/bus-bank) | 39 | 11 | 3.55 | 2.9% | 32.04 | 2.9% |
| [bus-bfl](../modules/bus-bfl) | 17 | 4 | 4.25 | 1.3% | 13.97 | 1.3% |
| [bus-books](../modules/bus-books) | 33 | 1 | 33.00 | 2.5% | 27.11 | 2.5% |
| [bus-budget](../modules/bus-budget) | 27 | 8 | 3.38 | 2.0% | 22.18 | 2.0% |
| [bus-config](../modules/bus-config) | 10 | 3 | 3.33 | 0.8% | 8.22 | 0.8% |
| [bus-data](../modules/bus-data) | 47 | 6 | 7.83 | 3.5% | 38.62 | 3.5% |
| [bus-dev](../modules/bus-dev) | 59 | 8 | 7.38 | 4.4% | 48.48 | 4.4% |
| [bus-entities](../modules/bus-entities) | 48 | 11 | 4.36 | 3.6% | 39.44 | 3.6% |
| [bus-filing](../modules/bus-filing) | 24 | 8 | 3.00 | 1.8% | 19.72 | 1.8% |
| [bus-filing-prh](../modules/bus-filing-prh) | 22 | 8 | 2.75 | 1.7% | 18.08 | 1.7% |
| [bus-filing-vero](../modules/bus-filing-vero) | 33 | 9 | 3.67 | 2.5% | 27.11 | 2.5% |
| [bus-init](../modules/bus-init) | 19 | 8 | 2.38 | 1.4% | 15.61 | 1.4% |
| [bus-inventory](../modules/bus-inventory) | 20 | 8 | 2.50 | 1.5% | 16.43 | 1.5% |
| [bus-invoices](../modules/bus-invoices) | 41 | 11 | 3.73 | 3.1% | 33.69 | 3.1% |
| [bus-journal](../modules/bus-journal) | 66 | 9 | 7.33 | 5.0% | 54.23 | 5.0% |
| [bus-loans](../modules/bus-loans) | 28 | 6 | 4.67 | 2.1% | 23.01 | 2.1% |
| [bus-payroll](../modules/bus-payroll) | 23 | 8 | 2.88 | 1.7% | 18.90 | 1.7% |
| [bus-pdf](../modules/bus-pdf) | 25 | 7 | 3.57 | 1.9% | 20.54 | 1.9% |
| [bus-period](../modules/bus-period) | 73 | 13 | 5.62 | 5.5% | 59.98 | 5.5% |
| [bus-preferences](../modules/bus-preferences) | 4 | 1 | 4.00 | 0.3% | 3.29 | 0.3% |
| [bus-reconcile](../modules/bus-reconcile) | 30 | 10 | 3.00 | 2.3% | 24.65 | 2.3% |
| [bus-replay](../modules/bus-replay) | 13 | 1 | 13.00 | 1.0% | 10.68 | 1.0% |
| [bus-reports](../modules/bus-reports) | 41 | 8 | 5.12 | 3.1% | 33.69 | 3.1% |
| [bus-run](../modules/bus-run) | 12 | 3 | 4.00 | 0.9% | 9.86 | 0.9% |
| [bus-sheets](../modules/bus-sheets) | 4 | 1 | 4.00 | 0.3% | 3.29 | 0.3% |
| [bus-validate](../modules/bus-validate) | 24 | 9 | 2.67 | 1.8% | 19.72 | 1.8% |
| [bus-vat](../modules/bus-vat) | 46 | 10 | 4.60 | 3.5% | 37.80 | 3.5% |
| busdk.com | 16 | 6 | 2.67 | 1.2% | 13.15 | 1.2% |
| docs | 278 | 18 | 15.44 | 20.9% | 228.41 | 20.9% |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./regulated-report-pdfs">Regulated report PDFs (TASE and tuloslaskelma)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

The numbers come from `scripts/get-cost-metrics.sh`: commit and active-day metrics are derived from Git history across BusDK repositories; cost figures are from internal tracking (Cursor team and ChatGPT Plus). The snapshot timestamp is 2026-02-17, approximately 22:52 EET.
