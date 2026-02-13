---
title: bus-payroll — Software Design Document
description: Bus Payroll maintains employee and payroll run datasets, validates payroll totals, and produces journal posting outputs for salaries and taxes.
---

## bus-payroll

### Introduction and Overview

Bus Payroll maintains employee and payroll run datasets, validates payroll totals, and produces journal posting outputs for salaries and taxes.

### Requirements

FR-PAY-001 Payroll datasets. The module MUST store employee and payroll run data as schema-validated datasets with stable identifiers. Acceptance criteria: payroll rows validate against schemas and reference valid entities and accounts.

FR-PAY-002 Payroll run outputs. The module MUST produce posting outputs for payroll runs suitable for the journal. Acceptance criteria: postings reference payroll run identifiers and vouchers.

NFR-PAY-001 Auditability. Payroll corrections MUST be append-only and traceable to the original runs. Acceptance criteria: payroll datasets remain reviewable in repository history.

### System Architecture

Bus Payroll owns the payroll datasets and produces posting outputs for the journal. It relies on `bus accounts` and `bus entities` for reference data and contributes to reporting workflows.

### Key Decisions

KD-PAY-001 Payroll data is repository data. Payroll runs and employee records are stored as datasets for auditability and exportability.

### Component Design and Interfaces

Interface IF-PAY-001 (module CLI). The module exposes `bus payroll` with subcommands `init`, `run`, `list`, and `employee` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline payroll datasets and schemas (employee and payroll run data) when they are absent. If all owned payroll datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

Documented parameters for `bus payroll run` are `--month <YYYY-MM>`, `--run-id <id>`, and `--pay-date <YYYY-MM-DD>`. The `--month` value selects the calendar month for the payroll period and uses the same `YYYY-MM` form as other period-scoped commands. The run uses employee records that are active for the pay date, where `start-date` is on or before the pay date and `end-date` is either empty or after the pay date, and it posts wages and withholdings using the account identifiers recorded on each employee row.

Employee management commands are `bus payroll employee add` and `bus payroll employee list`. Documented parameters for `employee add` are `--employee-id <id>`, `--entity <entity-id>`, `--start-date <YYYY-MM-DD>`, `--end-date <YYYY-MM-DD>`, `--gross <decimal>`, `--withholding-rate <percent>`, `--wage-expense <account-id>`, `--withholding-payable <account-id>`, and `--net-payable <account-id>`. The `--end-date` parameter is optional; when omitted the employee remains active after the start date. The `employee list` command accepts no module-specific filters and returns employees in stable identifier order.

Usage examples:

```bash
bus payroll init
bus payroll employee add --employee-id EMP-001 --entity ENT-EMP-001 --start-date 2026-01-01 --gross 3500 --withholding-rate 25 --wage-expense 5000 --withholding-payable 2940 --net-payable 2930
bus payroll run --month 2026-01 --run-id PAY-2026-01 --pay-date 2026-01-31
```

### Data Design

The module reads and writes payroll datasets in the payroll area, with JSON Table Schemas stored beside each CSV dataset. Master data owned by this module is stored in the workspace root only; the module does not create or use a `payroll/` or other subdirectory for its datasets and schemas.

### Assumptions and Dependencies

Bus Payroll depends on reference data from `bus accounts` and `bus entities` and on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Payroll datasets contain sensitive personal data and should be protected by repository access controls. Evidence references remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover payroll validation and posting output logic, and command-level tests exercise `init`, `run`, and `list` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic payroll data handling.

### Glossary and Terminology

Payroll run: a dataset record describing a payroll period and its totals.  
Employee record: a reference dataset row for a payroll recipient.

---

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
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
