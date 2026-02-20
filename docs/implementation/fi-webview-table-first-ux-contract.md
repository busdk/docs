---
title: Finnish WebView table-first UX contract
description: Deterministic table behavior contract for high-volume bookkeeping work in Finnish accounting UI.
---

## Overview

This page defines the table-first interaction contract for high-volume bookkeeping workflows.

## Four-task table model

Every major accounting list must support four tasks in one view: find/filter, compare rows, edit/open detail, and execute row or bulk actions. This model applies consistently to inbox, payables, receivables, bank lines, reconciliation differences, journal rows, and audit events.

## Required table capabilities

The list contract requires virtualization for large datasets, deterministic sorting, server-side filtering for large views, fixed columns where needed, column visibility control, saved views, row selection, and explicit bulk-action controls.

Row-level validation errors must be shown inline with deterministic error text. Bulk operations must report clear progress and deterministic failure rows.

## Consistency rule

Power users must not relearn table interaction per module. Core keyboard actions, filter semantics, selection behavior, and bulk-action affordances should remain stable across all table-heavy screens.

## Acceptance focus

A table implementation is accepted only when production workflows can complete with predictable latency and low interaction friction on large row counts.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-webview-ia-and-navigation-model">Finnish WebView IA and navigation model</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./fi-webview-accounting-ui-requirements">Finnish WebView UI requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fi-webview-compliance-and-audit-ux">Finnish WebView compliance and audit UX</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-books module SDD](../sdd/bus-books)
- [Nielsen Norman Group: Enterprise UX and tables](https://www.nngroup.com/articles/enterprise-ux-design/)
- [W3C WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
