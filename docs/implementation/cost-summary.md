---
title: Bus project cost summary
description: Snapshot of total days, commits, and AI-related spend across the BusDK org (2025-02-15), with cost per day, commits per day, per-module breakdown, and average cost per commit.
---

## Overview

This page summarizes project cost metrics captured on **2025-02-15 at approximately 19:00 Europe/Helsinki (EET, UTC+02:00)**. The numbers are intended as a snapshot for comparing relative effort and spend across repositories.

**Total commits** across the BusDK org repositories are used as a proxy for work units. **Total cost** is the sum of AI-related spend attributed per repository or module (documentation, code, and tooling). Commits were mostly produced via automated AI-driven commit workflows, so commits are intended to be small and semantically meaningful; that makes the metric useful for comparing relative effort across modules.

All amounts are in **USD**. Totals may not exactly match the sum of per-module rounded values because of rounding; the stated totals below are authoritative.

### Totals

| Metric | Value |
|--------|--------|
| **Total days** | 17 |
| **Total commits** | 1,005 |
| **Commits per day** | 60 |
| **Total cost** | **654.63 USD** |
| **Cost per day** | **38.51 USD** |
| **Approximate average cost per commit** | **0.65 USD** |

### Per-module breakdown

Module order below matches the source snapshot (no reordering).

| Module | Commits | % of commits | Cost (USD) | % of cost |
|--------|--------|---------------|------------|-----------|
| [bus](../modules/bus) | 35 | 3.5% | 22.80 | 3.5% |
| [bus-accounts](../modules/bus-accounts) | 46 | 4.6% | 29.96 | 4.6% |
| [bus-agent](../modules/bus-agent) | 15 | 1.5% | 9.77 | 1.5% |
| [bus-api](../modules/bus-api) | 10 | 1.0% | 6.51 | 1.0% |
| [bus-assets](../modules/bus-assets) | 26 | 2.6% | 16.94 | 2.6% |
| [bus-attachments](../modules/bus-attachments) | 26 | 2.6% | 16.94 | 2.6% |
| [bus-bank](../modules/bus-bank) | 37 | 3.7% | 24.10 | 3.7% |
| [bus-bfl](../modules/bus-bfl) | 17 | 1.7% | 11.07 | 1.7% |
| [bus-budget](../modules/bus-budget) | 27 | 2.7% | 17.59 | 2.7% |
| [bus-config](../modules/bus-config) | 10 | 1.0% | 6.51 | 1.0% |
| [bus-data](../modules/bus-data) | 27 | 2.7% | 17.59 | 2.7% |
| [bus-dev](../modules/bus-dev) | 49 | 4.9% | 31.92 | 4.9% |
| [bus-entities](../modules/bus-entities) | 47 | 4.7% | 30.61 | 4.7% |
| [bus-filing](../modules/bus-filing) | 24 | 2.4% | 15.63 | 2.4% |
| [bus-filing-prh](../modules/bus-filing-prh) | 22 | 2.2% | 14.33 | 2.2% |
| [bus-filing-vero](../modules/bus-filing-vero) | 20 | 2.0% | 13.03 | 2.0% |
| [bus-init](../modules/bus-init) | 19 | 1.9% | 12.38 | 1.9% |
| [bus-inventory](../modules/bus-inventory) | 20 | 2.0% | 13.03 | 2.0% |
| [bus-invoices](../modules/bus-invoices) | 26 | 2.6% | 16.94 | 2.6% |
| [bus-journal](../modules/bus-journal) | 52 | 5.2% | 33.87 | 5.2% |
| [bus-loans](../modules/bus-loans) | 28 | 2.8% | 18.24 | 2.8% |
| [bus-payroll](../modules/bus-payroll) | 23 | 2.3% | 14.98 | 2.3% |
| [bus-pdf](../modules/bus-pdf) | 11 | 1.1% | 7.17 | 1.1% |
| [bus-period](../modules/bus-period) | 54 | 5.4% | 35.17 | 5.4% |
| [bus-preferences](../modules/bus-preferences) | 4 | 0.4% | 2.61 | 0.4% |
| [bus-reconcile](../modules/bus-reconcile) | 19 | 1.9% | 12.38 | 1.9% |
| [bus-reports](../modules/bus-reports) | 22 | 2.2% | 14.33 | 2.2% |
| [bus-run](../modules/bus-run) | 5 | 0.5% | 3.26 | 0.5% |
| [bus-sheets](../modules/bus-sheets) | 4 | 0.4% | 2.61 | 0.4% |
| [bus-validate](../modules/bus-validate) | 22 | 2.2% | 14.33 | 2.2% |
| [bus-vat](../modules/bus-vat) | 33 | 3.3% | 21.50 | 3.3% |
| docs | 225 | 22.4% | 146.56 | 22.4% |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./development-status">Development status — BusDK modules</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Implementation and development status</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../data/index">Data format and storage</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources / method

The numbers come from internal cost tracking tied to automated AI commit workflows and represent a snapshot at the stated timestamp (2025-02-15, ~19:00 EET).
