---
title: Finnish WebView compliance and audit UX
description: UI requirements for Finnish filing deadlines, authority context, audit trail visibility, and evidence export in bookkeeping workflows.
---

## Overview

This page defines how Finnish compliance obligations must appear in the bookkeeping UI.

## Deadline-first filing UX

VAT and filing workflows must expose due-date state at all times, with readiness checks before submit. The UI must prioritize late-risk visibility because Finnish filing timelines are strict and delay handling is limited.

## Authority and representation visibility

Where filing actions are performed on behalf of another organization, UI must show the current authorization context, validity state, and allowed action scope in company context. Submit actions must fail early with explicit reason when authorization is missing, expired, or scope-incompatible.

## Audit trail as primary screen

Audit trail is a first-class workflow view, not only an admin backend utility. It must expose actor, timestamp, object, action type, and before/after change context, with links back to underlying bookkeeping objects and filing outputs where lineage is available.

The UI must preserve traceability from event to voucher to posting to ledger to statement and related note support paths.

## Evidence portability and reviewability

Compliance UX must include deterministic export paths for period-scoped evidence and report bundles, because Finnish control expectations require portable and reviewable material over long retention windows.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-webview-table-first-ux-contract">Finnish WebView table-first UX contract</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./fi-webview-accounting-ui-requirements">Finnish WebView UI requirements</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fi-webview-accessibility-and-performance">Finnish WebView accessibility and performance</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit)
- [Finnish closing deadlines and legal milestones](../compliance/fi-closing-deadlines-and-legal-milestones)
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)
- [NIST RBAC project overview](https://csrc.nist.gov/projects/role-based-access-control)
