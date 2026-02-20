---
title: Finnish WebView IA and navigation model
description: Information architecture and navigation contract for multi-company Finnish bookkeeping work in browser and embedded WebView.
---

## Overview

This page defines information architecture and navigation for Finland-focused bookkeeping UI in browser and embedded WebView usage.

## Two-space architecture

The product model uses two explicit contexts. Firm space handles multi-company portfolio operations such as assignment, deadline monitoring, workload queues, and firm-level access administration. Company space handles one legal entity’s accounting work: source intake, posting, reconciliation, tax filing flow, reports, and evidence.

This split is required for accounting-firm operations because users switch between many companies in one session and need shared queue visibility at firm level.

## App shell contract

The shell must include a persistent module sidebar and a top bar with active-company selector, global search/quick actions, notifications, and user controls.

Active company must be always visible and quickly switchable. Navigation and quick actions must be keyboard-operable and must support command-first operation (`Ctrl+K`) for power users.

## Minimum screen map

Firm space includes a workbench with company rows, status, due-date signals, and assignment actions. Company space includes dashboard, inbox, AP, AR, bank processing, reconciliation, journal, periods, VAT/filing, reports/exports, and audit trail.

The IA requirement is not satisfied by only dashboard cards. The model must support list-heavy workflows as the default accounting interaction.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-webview-accounting-ui-requirements">Finnish WebView bookkeeping UI requirements</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./fi-webview-accounting-ui-requirements">Finnish WebView UI requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fi-webview-table-first-ux-contract">Finnish WebView table-first UX contract</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-books module SDD](../sdd/bus-books)
- [bus-books module page](../modules/bus-books)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
