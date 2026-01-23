# BuSDK Design Spec: Overview

Modular CLI-First Accounting Toolkit (CSV + Frictionless Data + Git)

## Purpose and scope

BuSDK (Business Unit Software Development Kit), formerly known as Bus, is a modular, command-line-first toolkit for small-business accounting and bookkeeping. It is intentionally designed for longevity, clarity, and extensibility: all financial data is stored in transparent, human-readable text files and tracked in a Git repository so that the full history of bookkeeping activity remains auditable and reproducible. The primary target user is a sole entrepreneur who wants to automate their own bookkeeping in areas such as ledger entries, invoicing, VAT (ALV) handling, bank transaction imports, PDF invoice generation, and budgeting, while keeping the system sufficiently structured and standardized to support future AI-assisted automation without making AI a dependency.

This spec defines BuSDK’s goals, system architecture, data formats and storage conventions, CLI tooling and workflow expectations, extensibility model, canonical data directory layout, and an end-to-end example workflow illustrating day-to-day use.

A visual identity is assumed to exist for produced documents and outputs, including a BuSDK logo. The logo is explicitly expected to appear on generated artifacts such as invoices.

## Navigation

- [Design goals and requirements](01-design-goals.md)
- [System architecture](02-architecture.md)
- [Data format and storage](03-data-formats-and-storage.md)
- [CLI tooling and workflow](04-cli-workflow.md)
- [Integration and future interfaces](05-integration-future-interfaces.md)
- [Extensibility model](06-extensibility-model.md)
- [Data directory layout](07-data-directory-layout.md)
- [Example end-to-end workflow](08-example-workflow.md)
- [References and external foundations](09-references.md)

