---
title: Accounting entity
description: An accounting entity is the bookkeeping scope you keep separate journals, VAT, and reports for.
---

## Accounting entity

An accounting entity is the bookkeeping scope you keep separate journals, VAT, and reports for. In BusDK, that scope is defined by the workspace directory: one BusDK workspace represents exactly one internal business entity, and all datasets inside that workspace belong to that entity by construction.

### Ownership

Owner: [bus init](../../modules/bus-init). This module creates a new workspace and writes the workspace-level accounting entity settings into the workspace `datapackage.json` as a BusDK extension (see [Workspace configuration (`datapackage.json` extension)](../../data/workspace-configuration)).

Other modules consume the accounting entity settings as read-only workspace configuration when they validate, post, reconcile, report, or produce filings:

- [bus accounts](../../modules/bus-accounts): reads workspace scope and entity settings to keep charts and validations consistent.
- [bus invoices](../../modules/bus-invoices): reads entity settings to interpret invoice dates, currency, and VAT context.
- [bus vat](../../modules/bus-vat): reads VAT registration and reporting cadence for period reporting.
- [bus journal](../../modules/bus-journal): posts and reports per entity scope.

### Actions

- [Create an accounting entity](./create): Create a new workspace directory so journals and VAT never mix across business entities.
- [Configure accounting entity settings](./configure): Edit workspace configuration that controls currency, fiscal year boundaries, and VAT reporting expectations.

### Properties

Accounting entity settings are workspace-level configuration stored in `datapackage.json` at the workspace root as BusDK metadata. The settings include base currency ([base_currency](./base-currency)), fiscal year boundaries ([fiscal_year_start](./fiscal-year-start) and [fiscal_year_end](./fiscal-year-end)), VAT registration ([vat_registered](./vat-registered)), and VAT reporting cadence ([vat_reporting_period](./vat-reporting-period)). The canonical reference for keys and semantics is [Workspace configuration (`datapackage.json` extension)](../../data/workspace-configuration).

### Relations

An accounting entity is the shared scope for all master data and bookkeeping records in a workspace. Scope is derived from the workspace root directory, not from a per-row key, and entity-wide settings are resolved from `datapackage.json` rather than being referenced on row-level in operational datasets.

Within a workspace, there is one [chart of accounts](../chart-of-accounts/index) (and therefore many ledger accounts) and one set of [accounting periods](../accounting-periods/index) that define when bookkeeping is open, closed, and locked.

Multi-company workflows are expressed as multi-workspace operations; see [Workspace scope and multi-workspace workflows](../../architecture/workspace-scope-and-multi-workspace).

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">Master data (business objects)</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="../chart-of-accounts/index">Chart of accounts</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish bookkeeping and tax-audit compliance](../../compliance/fi-bookkeeping-and-tax-audit)
- [Accounting workflow overview](../../workflow/accounting-workflow-overview)
- [Year-end close (closing entries)](../../workflow/year-end-close)
- [VAT reporting and payment](../../workflow/vat-reporting-and-payment)

