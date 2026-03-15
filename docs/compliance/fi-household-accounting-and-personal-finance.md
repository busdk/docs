---
title: Household accounting and personal-finance workspaces
description: BusDK guidance for personal and household finance workspaces, including reporting needs, tax-evidence expectations, banking imports, and privacy implications.
---

## Overview

Personal and household finance is a valid BusDK use case, but it is not the same thing as Finnish statutory business bookkeeping. Ordinary household money management is not the same reporting problem as KPA- or PMA-shaped annual statements, even when the same repository still benefits from deterministic accounts, journals, attachments, and audit-style traceability.

For this use case, the practical pressure usually comes from tax evidence, receipts, and note-taking obligations for specific income-producing activity such as rental income, investment activity, forestry, or other non-business tulonhankkimistoiminta. [Kirjanpitolaki 1336/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1336) is still the key boundary because it frames ordinary household use differently from business bookkeeping, while [Verohallinnon guidance on luonnollisen henkilön ilmoittamisvelvollisuus](https://www.vero.fi/syventavat-vero-ohjeet/ohje-hakusivu/48486/luonnollisen-henkil%C3%B6n-ja-kuolinpes%C3%A4n-ilmoittamisvelvollisuus-tuloverotuksessa/) and [muistiinpanovelvollisuutta koskeva päätös 881/2024](https://www.finlex.fi/fi/viranomaiset/normi/201901/20240320) define when records must still be kept in chronological, tax-defensible form.

## What a personal workspace should optimize for

A personal workspace should default to reports that answer household questions directly. The normal starting set is monthly budget versus actual, cashflow, net worth, account-movement summaries, and transfer-aware views that keep movement between a user’s own accounts separate from true income and expense. Those outputs are easier to understand in household use than company-style profit-and-loss and balance-sheet layouts.

The category baseline should still be systematic. [COICOP 2018](https://unstats.un.org/unsd/classifications/Family/Detail/1161) is the strongest general-purpose default for expense categories because it gives a stable structure for spending analysis, while still allowing workspace-specific subcategories for household routines, children, hobbies, or project-like spending.

The same workspace also needs long-lived evidence handling. [Verohallinnon receipts guidance](https://www.vero.fi/henkiloasiakkaat/verokortti-ja-veroilmoitus/veroilmoitus_ja_verotuspaato/kuitit_ja_tosittee/) makes tax-relevant receipts, deduction evidence, and acquisition-cost documents operationally important even when a user is not running a company. BusDK should therefore treat attachments, tax tags, and retention-oriented evidence links as first-class parts of the household workflow rather than as business-only bookkeeping accessories.

## Banking data and imports

The safest default path for household banking data is file import first. [ISO 20022](https://www.iso20022.org/) account-report files such as `camt.053` and `camt.054` fit a repository-based workflow well because they can be imported without immediately taking on the compliance and operating-model burden of a live bank-feed service.

If Bus later offers live household bank feeds, that design must respect [PSD2](https://eur-lex.europa.eu/eli/dir/2015/2366/oj/eng) and the [strong-authentication and secure-communication RTS](https://eur-lex.europa.eu/eli/reg_del/2018/389/oj/eng). That means a normal product direction should assume secure API-based consent flows rather than any screen-scraping or credential-sharing model.

## Household collaboration and privacy

Household finance is often shared, but not always fully shared. A useful personal workspace therefore needs household members, shared accounts, transaction splitting, and visibility levels that can distinguish summary-only access from row-level access. A family may want one combined cashflow view while still hiding selected transaction details.

That is not only a UX preference. Personal finance data is personal data, and [GDPR](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng) matters even when the end user is “only” managing household money. The service side should therefore bias toward minimization, explicit retention behavior, exportability, and delete paths rather than assuming that all repository content should be visible to every participant forever.

## Workspace defaults and planned BusDK direction

The current BusDK reporting surface is still business-oriented. `bus reports` can already render useful PDFs from a personal repository, but the terminology, grouping, evidence-package defaults, and metadata remain shaped primarily for business and statutory reporting.

BusDK now has a workspace-level entity-kind value under `busdk.accounting_entity`. Set it to `personal` when the repository is a household or natural-person workspace, and keep `business` for company/statutory-default workspaces. That shared metadata gives downstream modules one deterministic source for switching report families, evidence-pack profiles, metadata expectations, and wording without relying on local wrapper scripts.

The remaining gap is consumer behavior. Today the metadata exists in workspace configuration, but the main reporting defaults are still business-oriented. In practice that means a personal workspace can now declare itself correctly, while [bus-reports](../modules/bus-reports) still needs dedicated household defaults and layouts so personal workspaces stop looking like company filing projects by default.

That design boundary matters because the same repository engine can support both domains while still keeping the defaults honest. A personal workspace should not accidentally look like a company filing project, and a business workspace should not silently fall back to household-style reporting.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./fi-reporting-taxonomy-and-account-classification">Finnish reporting taxonomy and account classification</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../index">BusDK Docs</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./fi-closing-deadlines-and-legal-milestones">Finnish closing deadlines and legal milestones</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [bus-reports](../modules/bus-reports)
- [bus-config](../modules/bus-config)
- [Workspace configuration (`datapackage.json` extension)](../data/workspace-configuration)
- [Household accounting and personal-finance architecture](../../../sdd/docs/implementation/fi-household-accounting-and-personal-finance.md)
- [Finlex: Kirjanpitolaki 1336/1997](https://www.finlex.fi/fi/lainsaadanto/1997/1336)
- [Verohallinto: Luonnollisen henkilön ja kuolinpesän ilmoittamisvelvollisuus tuloverotuksessa](https://www.vero.fi/syventavat-vero-ohjeet/ohje-hakusivu/48486/luonnollisen-henkil%C3%B6n-ja-kuolinpes%C3%A4n-ilmoittamisvelvollisuus-tuloverotuksessa/)
- [Finlex: Verohallinnon päätös muistiinpanovelvollisuudesta 881/2024](https://www.finlex.fi/fi/viranomaiset/normi/201901/20240320)
- [Verohallinto: Säilytä kuitit ja tositteet](https://www.vero.fi/henkiloasiakkaat/verokortti-ja-veroilmoitus/veroilmoitus_ja_verotuspaato/kuitit_ja_tosittee/)
- [UN Statistics Division: COICOP 2018](https://unstats.un.org/unsd/classifications/Family/Detail/1161)
- [ISO 20022](https://www.iso20022.org/)
- [GDPR](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng)
- [PSD2](https://eur-lex.europa.eu/eli/dir/2015/2366/oj/eng)
- [RTS for strong customer authentication and secure communication](https://eur-lex.europa.eu/eli/reg_del/2018/389/oj/eng)
