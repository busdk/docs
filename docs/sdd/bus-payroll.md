---
title: bus-payroll — validate payroll datasets and export postings (SDD)
description: Bus Payroll validates payroll datasets and exports deterministic posting lines for final payruns.
---

## bus-payroll — validate payroll datasets and export postings

### Introduction and Overview

Bus Payroll validates payroll datasets and exports deterministic posting lines for final payruns so salary and withholding entries can be posted to the journal.

### Requirements

FR-PAY-001 Payroll datasets. The module MUST read payroll data as schema-validated datasets with stable identifiers from the workspace root. Acceptance criteria: payroll rows validate against schemas and reference valid entities and accounts.

FR-PAY-002 Payroll run outputs. The module MUST produce posting outputs for final payroll runs suitable for the journal. Acceptance criteria: postings reference payroll run identifiers and employee identifiers and are deterministic for the same inputs.

NFR-PAY-001 Auditability. Payroll corrections MUST be append-only and traceable to the original runs. Acceptance criteria: payroll datasets remain reviewable in repository history.

NFR-PAY-002 Path exposure via Go library. The module MUST expose a Go library API that returns the workspace-relative path(s) to its owned data file(s) (employee and payroll run datasets and their schemas). Other modules that need read-only access to payroll raw file(s) MUST obtain the path(s) from this module’s library, not by hardcoding file names. The API MUST be designed so that future dynamic path configuration can be supported without breaking consumers. Acceptance criteria: the library provides path accessor(s) for the payroll datasets; consumers use these accessors for read-only access; no consumer hardcodes payroll file names outside this module.

### System Architecture

Bus Payroll reads payroll datasets from the workspace root and produces posting outputs for the journal. It relies on `bus accounts` and `bus entities` for reference data and contributes to reporting workflows.

### Key Decisions

KD-PAY-001 Payroll data is repository data. Payroll runs, employees, payments, and posting-account mappings are kept as datasets for auditability and exportability.

KD-PAY-002 Path exposure for read-only consumption. The module exposes path accessors in its Go library so that other modules can resolve the location of payroll datasets for read-only access. Write access and all payroll business logic remain in this module.

### Component Design and Interfaces

Interface IF-PAY-001 (module CLI). The module exposes `bus payroll validate` and `bus payroll export <payrun-id>` and follows BusDK CLI conventions for deterministic output and diagnostics.

`validate` checks payroll datasets and schemas and exits non-zero on missing files, schema errors, or data constraint violations.

`export <payrun-id>` validates first, then emits deterministic posting CSV lines for the selected final payrun.

Interface IF-PAY-002 (path accessors, Go library). The module exposes Go library functions that return the workspace-relative path(s) to payroll datasets and their schemas. Given a workspace root path, the library returns the path(s); resolution MUST allow future override from workspace or data package configuration. Other modules use these accessors for read-only access only; payroll validation and posting logic remain in this module.

Usage examples:

```bash
bus payroll validate
bus payroll export pr-001
```

### Data Design

The module reads payroll datasets from workspace-root files, with JSON Table Schemas stored beside each CSV dataset. The expected dataset set includes `employees.csv`, `payruns.csv`, `payments.csv`, and `posting_accounts.csv`, each with a beside-the-table schema file. Master data owned by this module is documented as workspace-root only; module-owned datasets are not placed under a `payroll/` or other subdirectory.

Other modules that need read-only access to payroll datasets MUST obtain the path(s) from this module’s Go library (IF-PAY-002). All writes and payroll-domain logic remain in this module.

### Assumptions and Dependencies

Bus Payroll depends on reference data from `bus accounts` and `bus entities` and on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Payroll datasets contain sensitive personal data and should be protected by repository access controls. Evidence references remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover payroll validation and posting output logic, and command-level tests exercise `validate` and `export` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic payroll data handling.

### Glossary and Terminology

Payroll run: a dataset record describing a payroll period and its totals.  
Employee record: a reference dataset row for a payroll recipient.

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-inventory">bus-inventory</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-budget">bus-budget</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Employees](../master-data/employees/index)
- [Owns master data: Payroll runs](../master-data/payroll-runs/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-payroll CLI reference](../modules/bus-payroll)
- [Repository](https://github.com/busdk/bus-payroll)
- [Table schema contract](../data/table-schema-contract)
- [Accounting workflow overview](../workflow/accounting-workflow-overview)

### Document control

Title: bus-payroll module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-PAYROLL`  
Version: 2026-02-19  
Status: Draft  
Last updated: 2026-02-19  
Owner: BusDK development team  
