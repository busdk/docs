---
title: Bus project cost summary
description: Snapshot of total days, commits, and AI-related spend across the BusDK org (2026-02-17), with cost per day, commits per day, per-module breakdown including avg commits per day per module, and average cost per commit.
---

## Overview

This page summarizes project cost metrics captured on **2026-02-17 at approximately 16:24 Europe/Helsinki (EET, UTC+02:00)**. The numbers are intended as a snapshot for comparing relative effort and spend across repositories.

**Total commits** across the BusDK org repositories are used as a proxy for work units. **Total cost** is the sum of AI-related spend (Cursor team subscription and usage, plus ChatGPT Plus and any extra costs). Commits were mostly produced via automated AI-driven commit workflows, so commits are intended to be small and semantically meaningful; that makes the metric useful for comparing relative effort across modules.

All amounts are in **USD**. Totals may not exactly match the sum of per-module rounded values because of rounding; the stated totals below are authoritative.

### Totals

| Metric | Value |
|--------|--------|
| **Date span** | 2025-12-25 to 2026-02-17 |
| **Active days (union)** | 20 |
| **Total commits** | 1,216 |
| **Avg commits per day** | 60.80 |
| **Busiest day** | 2026-02-15 (144 commits) |
| **Avg active modules per day** | 12.75 |
| **Total cost** | **938.14 USD** |
| **Cost per active day** | **46.91 USD** |
| **Approximate average cost per commit** | **0.77 USD** |

### Cost breakdown

| Component | USD |
|-----------|-----|
| ChatGPT Plus | 21.76 |
| Cursor team (spend over included) | 821.28 |
| Cursor team (included) | 95.10 |
| Cursor team total | 916.38 |
| Extra costs | 0 |
| **Overall total** | **938.14** |

### Per-module breakdown

Module order below matches the source snapshot (no reordering). *Active days* is the number of distinct days with at least one commit in that module. *Avg commits/day* is commits divided by active days for that module (average on days when the module had commits). Cost per module is derived from each module’s share of total commits.

| Module | Commits | Active days | Avg commits/day | % of commits | Cost (USD) | % of cost |
|--------|--------|-------------|-----------------|---------------|------------|-----------|
| [bus](../modules/bus) | 35 | 9 | 3.89 | 2.9% | 27.02 | 2.9% |
| [bus-accounts](../modules/bus-accounts) | 53 | 8 | 6.62 | 4.4% | 40.95 | 4.4% |
| [bus-agent](../modules/bus-agent) | 15 | 2 | 7.50 | 1.2% | 11.58 | 1.2% |
| [bus-api](../modules/bus-api) | 10 | 2 | 5.00 | 0.8% | 7.72 | 0.8% |
| [bus-assets](../modules/bus-assets) | 29 | 10 | 2.90 | 2.4% | 22.38 | 2.4% |
| [bus-attachments](../modules/bus-attachments) | 27 | 10 | 2.70 | 2.2% | 20.84 | 2.2% |
| [bus-balances](../modules/bus-balances) | 16 | 2 | 8.00 | 1.3% | 12.35 | 1.3% |
| [bus-bank](../modules/bus-bank) | 38 | 10 | 3.80 | 3.1% | 29.35 | 3.1% |
| [bus-bfl](../modules/bus-bfl) | 17 | 4 | 4.25 | 1.4% | 13.12 | 1.4% |
| [bus-books](../modules/bus-books) | 18 | 1 | 18.00 | 1.5% | 13.91 | 1.5% |
| [bus-budget](../modules/bus-budget) | 27 | 8 | 3.38 | 2.2% | 20.84 | 2.2% |
| [bus-config](../modules/bus-config) | 10 | 3 | 3.33 | 0.8% | 7.72 | 0.8% |
| [bus-data](../modules/bus-data) | 35 | 6 | 5.83 | 2.9% | 27.02 | 2.9% |
| [bus-dev](../modules/bus-dev) | 54 | 8 | 6.75 | 4.4% | 41.70 | 4.4% |
| [bus-entities](../modules/bus-entities) | 48 | 11 | 4.36 | 4.0% | 37.06 | 4.0% |
| [bus-filing](../modules/bus-filing) | 24 | 8 | 3.00 | 2.0% | 18.51 | 2.0% |
| [bus-filing-prh](../modules/bus-filing-prh) | 22 | 8 | 2.75 | 1.8% | 16.98 | 1.8% |
| [bus-filing-vero](../modules/bus-filing-vero) | 28 | 9 | 3.11 | 2.3% | 21.61 | 2.3% |
| [bus-init](../modules/bus-init) | 19 | 8 | 2.38 | 1.6% | 14.66 | 1.6% |
| [bus-inventory](../modules/bus-inventory) | 20 | 8 | 2.50 | 1.6% | 15.43 | 1.6% |
| [bus-invoices](../modules/bus-invoices) | 40 | 11 | 3.64 | 3.3% | 30.88 | 3.3% |
| [bus-journal](../modules/bus-journal) | 66 | 9 | 7.33 | 5.4% | 50.95 | 5.4% |
| [bus-loans](../modules/bus-loans) | 28 | 6 | 4.67 | 2.3% | 21.61 | 2.3% |
| [bus-payroll](../modules/bus-payroll) | 23 | 8 | 2.88 | 1.9% | 17.76 | 1.9% |
| [bus-pdf](../modules/bus-pdf) | 24 | 7 | 3.43 | 2.0% | 18.51 | 2.0% |
| [bus-period](../modules/bus-period) | 73 | 13 | 5.62 | 6.0% | 56.30 | 6.0% |
| [bus-preferences](../modules/bus-preferences) | 4 | 1 | 4.00 | 0.3% | 3.09 | 0.3% |
| [bus-reconcile](../modules/bus-reconcile) | 20 | 9 | 2.22 | 1.6% | 15.43 | 1.6% |
| [bus-replay](../modules/bus-replay) | 3 | 1 | 3.00 | 0.2% | 2.32 | 0.2% |
| [bus-reports](../modules/bus-reports) | 35 | 8 | 4.38 | 2.9% | 27.02 | 2.9% |
| [bus-run](../modules/bus-run) | 11 | 3 | 3.67 | 0.9% | 8.49 | 0.9% |
| [bus-sheets](../modules/bus-sheets) | 4 | 1 | 4.00 | 0.3% | 3.09 | 0.3% |
| [bus-validate](../modules/bus-validate) | 24 | 9 | 2.67 | 2.0% | 18.51 | 2.0% |
| [bus-vat](../modules/bus-vat) | 36 | 10 | 3.60 | 3.0% | 27.80 | 3.0% |
| busdk.com | 16 | 6 | 2.67 | 1.3% | 12.35 | 1.3% |
| docs | 264 | 18 | 14.67 | 21.7% | 203.68 | 21.7% |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./regulated-report-pdfs">Regulated report PDFs (TASE and tuloslaskelma)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

The numbers come from `scripts/get-cost-metrics.sh`: commit and active-day metrics are derived from Git history across BusDK repositories; cost figures are from internal tracking (Cursor team and ChatGPT Plus). The snapshot timestamp is 2026-02-17, approximately 16:24 EET.
