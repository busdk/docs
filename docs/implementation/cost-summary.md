---
title: Bus project cost summary
description: Snapshot of total days, commits, AI and human labour cost across the BusDK org (2026-02-18), with cost per day, commits per day, total cost (AI + human), per-module breakdown, and average cost per commit.
---

## Overview

This page summarizes project cost metrics captured on **2026-02-18 at approximately 09:51 Europe/Helsinki (EET, UTC+02:00)**. The numbers are intended as a snapshot for comparing relative effort and spend across repositories.

**Total commits** across the BusDK org repositories are used as a proxy for work units. When Cursor usage events are available from the Admin API, **total cost** is the sum of ChatGPT Plus and Cursor usage cost from those events (usage-based). Otherwise it is the sum of ChatGPT Plus and the Cursor team subscription total. Commits were mostly produced via automated AI-driven commit workflows, so commits are intended to be small and semantically meaningful; that makes the metric useful for comparing relative effort across modules.

All amounts are in **USD**. Totals may not exactly match the sum of per-module rounded values because of rounding; the stated totals below are authoritative.

### Totals

| Metric | Value |
|--------|--------|
| **Date span** | 2025-12-25 to 2026-02-18 |
| **Active days (union)** | 21 |
| **Total commits** | 1,388 |
| **Avg commits per day** | 66.10 |
| **Busiest day** | 2026-02-17 (232 commits) |
| **Avg active modules per day** | 13.19 |
| **Total cost (usage-based)** | **846.47 USD** |
| **Total cost (AI + human labour)** | **27,190.71 USD** |
| **Cost per active day** | **40.31 USD** |
| **Approximate average cost per commit** | **0.61 USD** |
| **Cursor usage tokens (total)** | 1,989,948,859 |

### Cost breakdown

| Component | USD |
|-----------|-----|
| ChatGPT Plus | 21.76 |
| Cursor usage (from API) | 824.71 |
| Cursor team (spend over included) | 1,109.87 |
| Cursor team (included) | 95.10 |
| Cursor team total | 1,204.97 |
| Extra costs | 0 |
| **Overall total (usage-based)** | **846.47** |

Cursor usage events were ingested for this snapshot. Total Cursor usage cost from the API is 824.71 USD across 1,989,948,859 tokens (15 days, 3,993 events). Peak cost day was 2026-02-17 (290.41 USD, 681.3M tokens). The script allocates that cost and token count to each module by commit-share; the per-module table below shows the allocated Cursor tokens. Human labour (USD) is the script’s commit-based estimate (implementation, review, and upkeep per commit) for each module.

### Per-module breakdown

Module order below matches the source snapshot (no reordering). *Active days* is the number of distinct days with at least one commit in that module. *Avg commits/day* is commits divided by active days for that module (average on days when the module had commits). *Cost (USD)* is each module’s share of total AI cost (usage-based, commit-share). *Human labour (USD)* is the script’s estimate from each module’s commit count (fixed cost per commit for implementation, review, and upkeep). *Total (AI + human) USD* is the sum of those two for the module. *Cursor tokens* are allocated from Cursor usage events by commit-share.

| Module | Commits | Active days | Avg commits/day | % of commits | Cost (USD) | % of cost | Human labour (USD) | Total (AI + human) USD | Cursor tokens |
|--------|--------|-------------|-----------------|---------------|------------|-----------|-------------------|------------------------|---------------|
| [bus](../modules/bus) | 35 | 9 | 3.89 | 2.5% | 21.34 | 2.5% | 664.35 | 685.69 | 50,178,826 |
| [bus-accounts](../modules/bus-accounts) | 54 | 9 | 6.00 | 3.9% | 32.93 | 3.9% | 1,024.99 | 1,057.92 | 77,418,759 |
| [bus-agent](../modules/bus-agent) | 15 | 2 | 7.50 | 1.1% | 9.15 | 1.1% | 284.72 | 293.87 | 21,505,211 |
| [bus-api](../modules/bus-api) | 24 | 4 | 6.00 | 1.7% | 14.64 | 1.7% | 455.55 | 470.19 | 34,408,337 |
| [bus-assets](../modules/bus-assets) | 43 | 11 | 3.91 | 3.1% | 26.22 | 3.1% | 816.20 | 842.42 | 61,648,271 |
| [bus-attachments](../modules/bus-attachments) | 28 | 11 | 2.55 | 2.0% | 17.07 | 2.0% | 531.48 | 548.55 | 40,143,061 |
| [bus-balances](../modules/bus-balances) | 16 | 2 | 8.00 | 1.2% | 9.76 | 1.2% | 303.70 | 313.46 | 22,938,892 |
| [bus-bank](../modules/bus-bank) | 40 | 12 | 3.33 | 2.9% | 24.40 | 2.9% | 759.25 | 783.65 | 57,347,228 |
| [bus-bfl](../modules/bus-bfl) | 17 | 4 | 4.25 | 1.2% | 10.37 | 1.2% | 322.68 | 333.05 | 24,372,572 |
| [bus-books](../modules/bus-books) | 44 | 2 | 22.00 | 3.2% | 26.83 | 3.2% | 835.18 | 862.01 | 63,081,952 |
| [bus-budget](../modules/bus-budget) | 27 | 8 | 3.38 | 1.9% | 16.46 | 1.9% | 512.50 | 528.96 | 38,709,380 |
| [bus-config](../modules/bus-config) | 10 | 3 | 3.33 | 0.7% | 6.10 | 0.7% | 189.81 | 195.91 | 14,336,807 |
| [bus-data](../modules/bus-data) | 49 | 7 | 7.00 | 3.5% | 29.88 | 3.5% | 930.09 | 959.97 | 70,250,356 |
| [bus-dev](../modules/bus-dev) | 60 | 8 | 7.50 | 4.3% | 36.59 | 4.3% | 1,138.88 | 1,175.47 | 86,020,845 |
| [bus-entities](../modules/bus-entities) | 48 | 11 | 4.36 | 3.5% | 29.27 | 3.5% | 911.11 | 940.38 | 68,816,675 |
| [bus-filing](../modules/bus-filing) | 24 | 8 | 3.00 | 1.7% | 14.64 | 1.7% | 455.55 | 470.19 | 34,408,337 |
| [bus-filing-prh](../modules/bus-filing-prh) | 22 | 8 | 2.75 | 1.6% | 13.42 | 1.6% | 417.59 | 431.01 | 31,540,977 |
| [bus-filing-vero](../modules/bus-filing-vero) | 35 | 10 | 3.50 | 2.5% | 21.34 | 2.5% | 664.35 | 685.69 | 50,178,826 |
| [bus-init](../modules/bus-init) | 19 | 8 | 2.38 | 1.4% | 11.59 | 1.4% | 360.65 | 372.24 | 27,239,934 |
| [bus-inventory](../modules/bus-inventory) | 20 | 8 | 2.50 | 1.4% | 12.20 | 1.4% | 379.63 | 391.83 | 28,673,614 |
| [bus-invoices](../modules/bus-invoices) | 42 | 12 | 3.50 | 3.0% | 25.61 | 3.0% | 797.22 | 822.83 | 60,214,590 |
| [bus-journal](../modules/bus-journal) | 66 | 9 | 7.33 | 4.8% | 40.26 | 4.8% | 1,252.77 | 1,293.03 | 94,622,929 |
| [bus-loans](../modules/bus-loans) | 28 | 6 | 4.67 | 2.0% | 17.07 | 2.0% | 531.48 | 548.55 | 40,143,061 |
| [bus-payroll](../modules/bus-payroll) | 23 | 8 | 2.88 | 1.7% | 14.02 | 1.7% | 436.57 | 450.59 | 32,974,658 |
| [bus-pdf](../modules/bus-pdf) | 27 | 8 | 3.38 | 1.9% | 16.46 | 1.9% | 512.50 | 528.96 | 38,709,380 |
| [bus-period](../modules/bus-period) | 74 | 14 | 5.29 | 5.3% | 45.14 | 5.3% | 1,404.62 | 1,449.76 | 106,092,374 |
| [bus-preferences](../modules/bus-preferences) | 4 | 1 | 4.00 | 0.3% | 2.44 | 0.3% | 75.93 | 78.37 | 5,734,724 |
| [bus-reconcile](../modules/bus-reconcile) | 33 | 11 | 3.00 | 2.4% | 20.12 | 2.4% | 626.39 | 646.51 | 47,311,464 |
| [bus-replay](../modules/bus-replay) | 17 | 2 | 8.50 | 1.2% | 10.37 | 1.2% | 322.68 | 333.05 | 24,372,572 |
| [bus-reports](../modules/bus-reports) | 44 | 9 | 4.89 | 3.2% | 26.83 | 3.2% | 835.18 | 862.01 | 63,081,952 |
| [bus-run](../modules/bus-run) | 16 | 4 | 4.00 | 1.2% | 9.76 | 1.2% | 303.70 | 313.46 | 22,938,892 |
| [bus-sheets](../modules/bus-sheets) | 6 | 2 | 3.00 | 0.4% | 3.66 | 0.4% | 113.89 | 117.55 | 8,602,084 |
| [bus-validate](../modules/bus-validate) | 26 | 10 | 2.60 | 1.9% | 15.86 | 1.9% | 493.52 | 509.38 | 37,275,700 |
| [bus-vat](../modules/bus-vat) | 49 | 11 | 4.45 | 3.5% | 29.88 | 3.5% | 930.09 | 959.97 | 70,250,356 |
| busdk.com | 16 | 6 | 2.67 | 1.2% | 9.76 | 1.2% | 303.70 | 313.46 | 22,938,892 |
| docs | 287 | 19 | 15.11 | 20.7% | 174.89 | 20.7% | 5,447.65 | 5,622.54 | 411,466,371 |

### Human labor (estimated)

The script applies a fixed cost per commit (implementation, review, and upkeep) to estimate equivalent human labor. This snapshot uses 18.98 USD per commit across 1,388 commits, for an estimated human-labor total of **26,344.24 USD**. The script reports overall total including human as **27,190.71 USD** (usage-based AI cost 846.47 plus that human-labor estimate). Per-module estimates are shown in the table above as Human labour (USD).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./regulated-report-pdfs">Regulated report PDFs (TASE and tuloslaskelma)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

The numbers come from `scripts/get-cost-metrics.sh`: commit and active-day metrics are derived from Git history across BusDK repositories; cost figures are from internal tracking (Cursor team and ChatGPT Plus). The snapshot timestamp is 2026-02-18, approximately 09:51 EET.
