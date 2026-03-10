---
title: Finnish reporting taxonomy and account classification
description: Background for separating statutory statement layout, account meaning, entity context, and company-specific overrides in Finnish bookkeeping.
---

## Overview

Finnish financial reporting works best when four concerns stay separate. The statutory statement layout defines how balance sheet and income statement lines must be presented. Account classification defines what each ledger account means in bookkeeping. Workspace entity context defines which framework and presentation rules apply to that entity. Company-specific overrides handle the exceptional cases that do not fit the defaults.

This separation matters because the same business meaning should not need to be rebuilt separately for every report layout. A chart of accounts may stay stable while the entity moves between KPA and PMA presentation, switches from expense-by-nature to function-based income statement, or needs a special scheme for a housing company, association, or foundation. The legal output changes, but the bookkeeping meaning of cash, receivables, VAT, depreciation, or personnel expenses does not.

## The four layers

### Statutory taxonomy

The statutory taxonomy is the external statement tree. In Finland that means KPA, PMA, and the special schemes those frameworks allow. It defines line order, headings, subtotals, and filing-facing wording. It should be versioned because regulation, PRH filing formats, and future iXBRL/XBRL requirements can change over time.

### Account classification

Account classification is the semantic meaning of an account. It answers questions such as whether an account is cash, trade receivables, VAT payable, personnel expense, depreciation, financial income, or an equity item. This layer should stay independent from the exact printed statement layout so that one account meaning can feed several reporting views without being redefined each time.

### Entity context

Entity context tells the reporting system which legal and practical rules apply to the workspace. Typical inputs are business form, size-sensitive framework choice, income statement scheme, language, presentation unit, and special characteristics such as housing-company, nonprofit, or other scheme-sensitive status. These settings belong to workspace configuration rather than to individual account rows.

### Company-specific overrides

Overrides are the exceptional company-level rules. They are needed when one account must be presented differently from the default semantic classification, when a special statutory line is required, or when local wording differs from the built-in taxonomy. Keeping overrides separate makes them easier to review and audit because they stay small and explicit.

## Deterministic resolution

A robust reporting system resolves statement placement in a fixed order. First it applies an explicit account override. If none exists, it applies the canonical account classification. If classification is still missing, it can use a numbering-family or range-based default where the chart supports that convention. If the account still cannot be placed confidently, the correct result is a validation error rather than a silent guess.

That model fits Finnish bookkeeping practice well. Many charts use stable numeric families, but numbering alone is not enough for every case. VAT settlement accounts, depreciation and tax adjustments, capital charges in housing companies, and nonprofit activity classes often need explicit semantics or entity-context conditions.

## Typical Finnish special cases

KPA and PMA are not just cosmetic layout choices. They change the permitted statement structure and the level of aggregation. PMA also contains special schemes for real-estate and housing-company reporting and for associations and foundations. Those differences belong in the statutory taxonomy and entity-context layers, not in repeated manual remapping of every account.

VAT and depreciation are good examples of why semantic classification matters. VAT accounts usually belong on the balance sheet, not in the income statement, even if they sit near income or expense accounts in the chart. Depreciation, plan depreciation, and tax-driven adjustments also need a more precise model than a simple account-number range when statements, tax returns, and notes must stay consistent.

Notes and internal evidence are related but separate. The balance sheet and income statement are filing-facing statements. Notes, balance-sheet specifications, reconciliation reports, and evidence-pack artifacts belong to the same reporting family, but they should inherit the same account meaning instead of redefining it independently.

## BusDK background

In current BusDK workspaces, these layers are represented mainly through workspace reporting profile settings in `datapackage.json`, account master data in `accounts.csv`, and explicit report-line mappings in `report-account-mapping.csv`. The architectural direction is to keep those responsibilities clearer over time so that an operator can set entity context, review account classification, add only true exceptions, and then generate reports.

This background is useful when you configure [bus config](../modules/bus-config), curate the [chart of accounts](../master-data/chart-of-accounts/index), or troubleshoot [bus reports](../modules/bus-reports). It explains why a report layout choice, an account’s bookkeeping meaning, and a company-specific exception should not be treated as the same piece of data.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-balance-sheet-and-income-statement-regulation">Finnish balance sheet and income statement regulation</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fi-closing-deadlines-and-legal-milestones">Finnish closing deadlines and legal milestones</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Finnish balance sheet and income statement regulation](./fi-balance-sheet-and-income-statement-regulation)
- [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
- [Chart of accounts](../master-data/chart-of-accounts/index)
- [bus-config](../modules/bus-config)
- [bus-accounts](../modules/bus-accounts)
- [bus-reports](../modules/bus-reports)
- [Finlex: Kirjanpitoasetus 1339/1997 (KPA)](https://www.finlex.fi/fi/lainsaadanto/1997/1339)
- [Finlex: Valtioneuvoston asetus 1753/2015 (PMA)](https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2015/1753)
- [KILA: Yleisohje tuloslaskelman ja taseen esittämisestä](https://kirjanpitolautakunta.fi/documents/8208007/10349155/TP_YLEIS2006.pdf/68053376-f0fc-c32b-fbe4-f11359672996/TP_YLEIS2006.pdf)
