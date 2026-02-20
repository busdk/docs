---
title: Finnish closing checklist and reconciliations
description: Pre-close checklist for Finnish year-end readiness, with reconciliation priorities before official income statement and balance sheet outputs.
---

## Overview

This page covers pre-close execution work before official financial statement generation. The focus is practical readiness: reconciliations, cut-off discipline, and closing control evidence.

## Pre-close readiness model

A Finnish close is ready for official statement generation only when bookkeeping records are current, voucher-backed, and reconcilable from source events to ledger totals. The closing sequence should move from completeness controls to reconciliation controls and then to adjustment controls.

The minimum practical sequence is:

1. Confirm posting completeness for the period and controlled cut-off handling.
2. Reconcile core subledgers and cash movement against general-ledger control accounts.
3. Freeze an adjusted trial-balance boundary before generating official statements.

## Reconciliation priorities

Cash and bank reconciliation is first priority, because unresolved cash movements propagate errors to VAT, payables/receivables, and period results. Receivable and payable subledgers are then reconciled to control accounts with open-item explanations.

Inventory and fixed-asset reconciliations follow as separate controls. Inventory requires quantity and valuation support at period end. Fixed assets require register-to-ledger alignment and depreciation basis support.

Financing and tax control accounts are reconciled next, including interest accruals, VAT balances versus filed periods, and payroll liabilities versus payroll runs and reporting obligations.

## Cut-off and period boundary controls

Cut-off procedures must prove period ownership of income and expenses based on delivery/receipt substance, not payment date alone. Delivered-not-invoiced and received-not-invoiced items must be identified and posted through accrual entries where required.

Closing control should define a final posting boundary and a controlled exception path for late evidence. Any post-boundary entry should be explicitly tagged and reviewable in change history.

## BusDK execution mapping

In BusDK terms, this page maps to the execution order of `bus validate`, module reconciliations, closing entries, and period close/lock steps in [Year-end close (closing entries)](../workflow/year-end-close). Use [Finnish closing adjustments and evidence controls](./fi-closing-adjustments-and-evidence-controls) for mandatory adjustment categories and note-evidence controls.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-closing-deadlines-and-legal-milestones">Finnish closing deadlines and legal milestones</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fi-closing-adjustments-and-evidence-controls">Finnish closing adjustments and evidence controls</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finlex: Kirjanpitolaki 1336/1997 (KPL)](https://www.finlex.fi/fi/lainsaadanto/1997/1336)
- [KILA: Yleisohje kirjanpidon menetelmistä ja aineistoista](https://kirjanpitolautakunta.fi/documents/8208007/11087193/final+2021-04-20+KILA-menetelmaohje+(1).pdf/d19100d1-1b6d-e652-3be0-a22a1a157291/final+2021-04-20+KILA-menetelmaohje+(1).pdf?t=1619681814561)
- [Year-end close (closing entries)](../workflow/year-end-close)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
