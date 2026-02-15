---
title: Bus project cost summary
description: Snapshot of total days, commits, and AI-related spend across the BusDK org (2026-02-15), with cost per day, commits per day, per-module breakdown including avg commits per day per module, and average cost per commit.
---

## Overview

This page summarizes project cost metrics captured on **2026-02-15 at approximately 22:11 Europe/Helsinki (EET, UTC+02:00)**. The numbers are intended as a snapshot for comparing relative effort and spend across repositories.

**Total commits** across the BusDK org repositories are used as a proxy for work units. **Total cost** is the sum of AI-related spend (Cursor team subscription and usage, plus ChatGPT Plus and any extra costs). Commits were mostly produced via automated AI-driven commit workflows, so commits are intended to be small and semantically meaningful; that makes the metric useful for comparing relative effort across modules.

All amounts are in **USD**. Totals may not exactly match the sum of per-module rounded values because of rounding; the stated totals below are authoritative.

### Totals

| Metric | Value |
|--------|--------|
| **Date span** | 2025-12-25 to 2026-02-15 |
| **Active days (union)** | 18 |
| **Total commits** | 1,027 |
| **Avg commits per day** | 57.06 |
| **Busiest day** | 2026-01-25 (140 commits) |
| **Avg active modules per day** | 12.56 |
| **Total cost** | **708.45 USD** |
| **Cost per active day** | **39.36 USD** |
| **Approximate average cost per commit** | **0.69 USD** |

### Cost breakdown

| Component | USD |
|-----------|-----|
| ChatGPT Plus | 21.76 |
| Cursor team (spend over included) | 591.59 |
| Cursor team (included) | 95.10 |
| Cursor team total | 686.69 |
| Extra costs | 0 |
| **Overall total** | **708.45** |

### Per-module breakdown

Module order below matches the source snapshot (no reordering). *Active days* is the number of distinct days with at least one commit in that module. *Avg commits/day* is commits divided by active days for that module (average on days when the module had commits). Cost per module is derived from each module’s share of total commits.

| Module | Commits | Active days | Avg commits/day | % of commits | Cost (USD) | % of cost |
|--------|--------|-------------|-----------------|---------------|------------|-----------|
| [bus](../modules/bus) | 35 | 9 | 3.89 | 3.4% | 24.14 | 3.4% |
| [bus-accounts](../modules/bus-accounts) | 46 | 7 | 6.57 | 4.5% | 31.78 | 4.5% |
| [bus-agent](../modules/bus-agent) | 15 | 2 | 7.50 | 1.5% | 10.36 | 1.5% |
| [bus-api](../modules/bus-api) | 10 | 2 | 5.00 | 1.0% | 6.90 | 1.0% |
| [bus-assets](../modules/bus-assets) | 26 | 8 | 3.25 | 2.5% | 17.94 | 2.5% |
| [bus-attachments](../modules/bus-attachments) | 26 | 9 | 2.89 | 2.5% | 17.94 | 2.5% |
| [bus-bank](../modules/bus-bank) | 37 | 9 | 4.11 | 3.6% | 25.52 | 3.6% |
| [bus-bfl](../modules/bus-bfl) | 17 | 4 | 4.25 | 1.7% | 11.73 | 1.7% |
| [bus-budget](../modules/bus-budget) | 27 | 8 | 3.38 | 2.6% | 18.63 | 2.6% |
| [bus-config](../modules/bus-config) | 10 | 3 | 3.33 | 1.0% | 6.90 | 1.0% |
| [bus-data](../modules/bus-data) | 28 | 5 | 5.60 | 2.7% | 19.31 | 2.7% |
| [bus-dev](../modules/bus-dev) | 49 | 6 | 8.17 | 4.8% | 33.81 | 4.8% |
| [bus-entities](../modules/bus-entities) | 47 | 10 | 4.70 | 4.6% | 32.44 | 4.6% |
| [bus-filing](../modules/bus-filing) | 24 | 8 | 3.00 | 2.3% | 16.56 | 2.3% |
| [bus-filing-prh](../modules/bus-filing-prh) | 22 | 8 | 2.75 | 2.1% | 15.18 | 2.1% |
| [bus-filing-vero](../modules/bus-filing-vero) | 20 | 8 | 2.50 | 1.9% | 13.80 | 1.9% |
| [bus-init](../modules/bus-init) | 19 | 8 | 2.38 | 1.8% | 13.11 | 1.8% |
| [bus-inventory](../modules/bus-inventory) | 20 | 8 | 2.50 | 1.9% | 13.80 | 1.9% |
| [bus-invoices](../modules/bus-invoices) | 26 | 9 | 2.89 | 2.5% | 17.94 | 2.5% |
| [bus-journal](../modules/bus-journal) | 52 | 8 | 6.50 | 5.1% | 35.88 | 5.1% |
| [bus-loans](../modules/bus-loans) | 28 | 6 | 4.67 | 2.7% | 19.31 | 2.7% |
| [bus-payroll](../modules/bus-payroll) | 23 | 8 | 2.88 | 2.2% | 15.87 | 2.2% |
| [bus-pdf](../modules/bus-pdf) | 11 | 5 | 2.20 | 1.1% | 7.59 | 1.1% |
| [bus-period](../modules/bus-period) | 55 | 12 | 4.58 | 5.4% | 37.96 | 5.4% |
| [bus-preferences](../modules/bus-preferences) | 4 | 1 | 4.00 | 0.4% | 2.76 | 0.4% |
| [bus-reconcile](../modules/bus-reconcile) | 19 | 8 | 2.38 | 1.8% | 13.11 | 1.8% |
| [bus-reports](../modules/bus-reports) | 22 | 7 | 3.14 | 2.1% | 15.18 | 2.1% |
| [bus-run](../modules/bus-run) | 5 | 1 | 5.00 | 0.5% | 3.45 | 0.5% |
| [bus-sheets](../modules/bus-sheets) | 4 | 1 | 4.00 | 0.4% | 2.76 | 0.4% |
| [bus-validate](../modules/bus-validate) | 22 | 8 | 2.75 | 2.1% | 15.18 | 2.1% |
| [bus-vat](../modules/bus-vat) | 33 | 8 | 4.13 | 3.2% | 22.78 | 3.2% |
| busdk.com | 16 | 6 | 2.67 | 1.6% | 11.04 | 1.6% |
| docs | 229 | 16 | 14.31 | 22.3% | 158.02 | 22.3% |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./development-status">Development status — BusDK modules</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

The numbers come from `scripts/get-cost-metrics.sh`: commit and active-day metrics are derived from Git history across BusDK repositories; cost figures are from internal tracking (Cursor team and ChatGPT Plus). The snapshot timestamp is 2026-02-15, approximately 22:11 EET.
