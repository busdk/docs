---
title: Finnish WebView accessibility and performance
description: Accessibility, keyboard, and performance requirements for accounting UI in browser and embedded WebView contexts.
---

## Overview

This page defines accessibility and runtime behavior requirements for bookkeeping UI in browser and WebView contexts.

## Accessibility and keyboard contract

Grid, form, and dialog interactions must be keyboard-first and follow predictable focus order. Visible focus indicators are required, and status/error communication must not rely on color alone.

Long-running operations must expose accessible status updates. Chart views cannot be the only representation of accounting-critical information; equivalent tabular representation must exist.

## Performance baseline

The UI must stay responsive in data-heavy list workflows and large accounting datasets. List virtualization and server-assisted filtering/sorting are required where row volume is high.

## WebView runtime behavior

Embedded WebView operation must handle unstable connectivity and constrained local storage. Caching strategy should prefer deterministic stale-while-revalidate behavior for safe read paths and static assets, with explicit cache-budget management.

Offline-aware behavior must include clear connectivity state, safe queueing where possible, and deterministic conflict handling for competing edits.

## Validation approach

Validation combines automated accessibility checks with manual keyboard-path testing for grids and dialogs, plus performance profiling on representative data volume and WebView targets.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-webview-compliance-and-audit-ux">Finnish WebView compliance and audit UX</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./fi-webview-accounting-ui-requirements">Finnish WebView UI requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./cost-summary">Cost summary</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [W3C WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM: Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Workbox documentation](https://developer.chrome.com/docs/workbox/)
- [bus-books module SDD](../sdd/bus-books)
