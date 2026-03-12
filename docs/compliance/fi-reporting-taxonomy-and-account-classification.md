---
title: Finnish reporting hierarchy for TASE and tuloslaskelma
description: Background for deriving Finnish statutory statements from one canonical account-group hierarchy, with explicit TASE sides and a separate current-year result row.
---

## Overview

Finnish statutory reporting needs one clear reporting hierarchy, not several overlapping mapping layers. The practical starting point is a chart of posting accounts in `accounts.csv` and one canonical reporting tree in `account-groups.csv`. Every posting account belongs to one reporting group through `accounts.csv:group_id`, and balance sheet and income statement outputs are derived from that same tree.

This matters because the same business meaning must not be rebuilt separately for every printed layout. If one account belongs to one reporting group in bookkeeping, it should stay under that group in every statutory output. Short and full statement variants may hide or show groups differently, but they must not remap accounts to different logical statement lines.

## Canonical hierarchy

The reporting tree must model the real Finnish statement structure. In practice that means the tree needs explicit roots or subtrees for the balance-sheet sides and the income statement. TASE is one statement under one heading, but it is always divided into `VASTAAVA` and `VASTATTAVAA`. The income statement is a separate subtree with its statutory line order and subtotal order.

The tree should also carry presentation profiles such as `bs_short`, `bs_full`, `pl_short`, and `pl_full`. These profiles control whether one group is visible in one output variant, but they do not change the parent-child hierarchy itself.

## TASE sides and result rows

The balance-sheet split into `VASTAAVA` and `VASTATTAVAA` must be explicit in the reporting model. This should not be guessed from a printed layout or from ad hoc account-number rules. The reporting tree needs a deterministic way to say whether a balance-sheet group belongs on the asset side or on the liabilities-and-equity side.

The current-year result row is also special. `Tilikauden tulos` is not a transaction row by itself; it is a calculated statement result that must appear both as the final row of the income statement and as a separate equity item in the balance sheet. That means software must treat it as a reporting result, not merely as another ordinary posting account.

The same applies to `Edellisten tilikausien voitto (tappio)`: it is a separate equity presentation item and must not be silently merged with the current-year result.

## Why one hierarchy matters

One hierarchy is easier to review and safer to maintain. Auditors, accountants, and software users can inspect one group tree and see where each account belongs. The same tree can then feed TASE, tuloslaskelma, close packages, and internal reconciliation outputs without per-layout remapping files that make the same account mean different things in different places.

This is also a better fit for digital reporting and data export. A stable group id and stable parent-child structure give you a clean bridge from bookkeeping data to filing-facing outputs, even if wording, profile visibility, or exported schema details evolve later.

## Workspace context still matters

Workspace configuration still decides which statutory family is active, for example KPA versus PMA and expense-by-nature versus function-based income statement. That context controls how the reporting tree is rendered and which report profiles are shown, but it should not redefine where accounts belong inside the canonical group hierarchy.

## Practical modeling rule

The safe practical rule is simple: keep only posting accounts in `accounts.csv`, keep only the canonical reporting hierarchy in `account-groups.csv`, and derive all statutory statements from that pair. Special output variants are profile-visibility choices on groups. Special calculated lines such as the current-year result must still be treated as reporting-level results, not as excuses to reintroduce parallel account-to-layout mapping layers.

This background is useful when you configure [bus config](../modules/bus-config), curate the [chart of accounts](../master-data/chart-of-accounts/index), or troubleshoot [bus reports](../modules/bus-reports). It explains why one canonical account-group tree is safer than separate mapping and classification files.

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
