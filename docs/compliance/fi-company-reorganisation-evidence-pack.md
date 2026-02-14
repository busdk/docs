---
title: Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack
description: Use case and evidence-pack scope for court-supervised reorganisation — bookkeeping traceability, snapshots, loan registry, and budget/liquidity evidence in BusDK.
---

## Overview

Court-supervised company reorganisation (yrityssaneeraus) aims to rehabilitate a viable business through a confirmed restructuring plan. The procedure typically requires an evidence pack built from accounting data: recent financial statements or equivalent bookkeeping-based summaries (where no formal statements are required), an interim snapshot, a list of significant assets, a creditor and debt picture including a loan registry, and forward-looking budgets and cashflow showing ability to cover procedure costs and post-commencement obligations. BusDK supports building this evidence in a reviewable, deterministic audit trail in a Git workspace.

This use case emphasises correctness and traceability of bookkeeping, explicit separation of snapshot reporting (baseline and interim) from ongoing operational postings, loan registry roll-forward and debt visibility, and budget or forecast and liquidity evidence. In practice the application or assessment often expects recent financial statements or equivalent bookkeeping summaries, an interim snapshot, a significant-assets list, and where applicable an independent auditor or expert report in debtor-led filings. BusDK does not provide legal or procedural advice; it provides the accounting and reporting primitives so that the evidence pack can be assembled and reviewed from workspace data.

### Module readiness for this journey

Which BusDK modules contribute to the evidence pack and what is verified today (by tests) is summarised in the [Development status — BusDK modules](../implementation/development-status#finnish-company-reorganisation-yrityssaneeraus--audit-and-evidence-pack) page under the section **Finnish company reorganisation (yrityssaneeraus) — audit and evidence pack**. That section lists bus-period, bus-reports, bus-validate, bus-attachments, bus-journal, bus-invoices, bus-bank, bus-reconcile, bus-loans, bus-budget, and bus-assets with their readiness percentages, value for the evidence pack, planned next steps, and blockers.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-bookkeeping-and-tax-audit">Finnish bookkeeping and tax-audit compliance</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../implementation/development-status">Development status — BusDK modules</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../workflow/accounting-workflow-overview">Accounting workflow overview</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Development status — BusDK modules](../implementation/development-status#finnish-company-reorganisation-yrityssaneeraus--audit-and-evidence-pack)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)
- [Finnish bookkeeping and tax-audit compliance](./fi-bookkeeping-and-tax-audit)
