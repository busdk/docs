## Purpose and scope

BusDK (Business Development Kit), formerly known as Bus, is a modular, command-line-first toolkit for running a business, including accounting and bookkeeping. It is intentionally designed for longevity, clarity, and extensibility: all financial data is stored in transparent, human-readable text files and tracked in a Git repository so that the full history of bookkeeping activity remains auditable and reproducible. BusDK does not execute any Git commands or commit changes; Git operations are handled externally by the user or automation. The primary target user is a business user who wants to automate their business operations in areas such as ledger entries, invoicing, VAT (ALV) handling, bank transaction imports, PDF invoice generation, and budgeting, while keeping the system sufficiently structured and standardized to support future AI-assisted automation without making AI a dependency.

While bookkeeping is the current focus, BusDK is intended to grow into a broader, CLI-first toolkit for running a business end-to-end. That scope includes not only administrative back-office domains such as invoicing, payments, reporting, and compliance, but also end-user business-specific operational modules. Those operational modules must plug into the same shared data repository and schema-driven contracts so that both humans and automation can audit real workflows with the same guarantees as core accounting tasks.

This spec defines BusDK’s goals, system architecture, data formats and storage conventions, CLI tooling and workflow expectations, extensibility model, canonical data directory layout, and an end-to-end example workflow illustrating day-to-day use. Finnish bookkeeping and tax-audit compliance requirements are specified separately in [Finnish bookkeeping and tax-audit compliance](../compliance/fi-bookkeeping-and-tax-audit).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">BusDK Design Spec: Overview</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">BusDK Design Spec: Overview</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./visual-identity">Visual identity and branding on outputs</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
