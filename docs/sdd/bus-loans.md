## bus-loans

### Introduction and Overview

Bus Loans maintains loan master data and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions for loan activity.

### Requirements

FR-LOAN-001 Loan registry. The module MUST store loan contracts and events as schema-validated datasets with stable identifiers. Acceptance criteria: loan rows validate against schemas and reference counterparties and accounts.

FR-LOAN-002 Amortization outputs. The module MUST generate amortization schedules and posting outputs for the journal. Acceptance criteria: outputs reference the originating loan identifiers and vouchers.

NFR-LOAN-001 Auditability. Loan corrections MUST be append-only and traceable to original records. Acceptance criteria: schedules and events remain reviewable in repository history.

### System Architecture

Bus Loans owns the loan datasets and generates schedules and posting suggestions. It relies on `bus accounts` and `bus entities` for reference data and integrates with the journal and reporting workflows.

### Key Decisions

KD-LOAN-001 Loan records are repository data. Loan contracts, events, and schedules are stored as datasets for auditability and exportability.

### Component Design and Interfaces

Interface IF-LOAN-001 (module CLI). The module exposes `bus loans` with subcommands `init`, `add`, `event`, and `amortize` and follows BusDK CLI conventions for deterministic output and diagnostics.

The `init` command creates the baseline loan register and event datasets and schemas when they are absent. If all owned loan datasets and schemas already exist and are consistent, `init` prints a warning to standard error and exits 0 without modifying anything. If the data exists only partially, `init` fails with a clear error to standard error, does not write any file, and exits non-zero (see [bus-init](../sdd/bus-init) FR-INIT-004).

The `add` command records a new loan contract in the loan register. It accepts `--loan-id <id>`, `--counterparty <entity-id>`, `--principal <amount>`, `--start-date <YYYY-MM-DD>`, `--maturity-date <YYYY-MM-DD>`, `--interest-rate <percent>`, `--principal-account <account-id>`, `--interest-account <account-id>`, and `--cash-account <account-id>` as required parameters, and it accepts `--name <text>`, `--rate-type <fixed|variable>`, `--payment-frequency <monthly|quarterly|yearly>`, and `--desc <text>` as optional parameters. When `--rate-type` is omitted, the rate is treated as fixed; when `--payment-frequency` is omitted, the schedule assumes monthly payments.

The `event` command appends an event record that references the loan contract and produces posting output when applicable. It accepts `--loan-id <id>`, `--date <YYYY-MM-DD>`, `--type <disbursement|repayment|interest|fee|adjustment>`, and `--amount <amount>` as required parameters, and it accepts `--principal <amount>`, `--interest <amount>`, `--fees <amount>`, `--desc <text>`, `--voucher <voucher-id>`, and `--cash-account <account-id>` as optional parameters. When allocation fields are omitted, the module derives allocation deterministically from the loan contract terms.

The `amortize` command generates amortization schedules and posting output for a specific period. It accepts `--period <period>` as a required parameter and `--loan-id <id>` and `--post-date <YYYY-MM-DD>` as optional parameters. When `--loan-id` is omitted, the command scopes to all loans; when `--post-date` is omitted, the posting date is the last date of the selected period.

Usage examples:

```bash
bus loans init
bus loans add --loan-id LN-100 --counterparty ACME-BANK --principal 250000 --start-date 2026-01-01 --maturity-date 2031-01-01 --interest-rate 4.5 --principal-account "Long-term loans" --interest-account "Interest expense" --cash-account "Bank"
bus loans event --loan-id LN-100 --date 2026-01-01 --type disbursement --amount 250000 --voucher V-2026-0001
bus loans amortize --period 2026-02
```

### Data Design

The module reads and writes loan register and event datasets in the loans area, with JSON Table Schemas stored beside each CSV dataset. Master data owned by this module is stored in the workspace root only; the module does not create or use a `loans/` or other subdirectory for its datasets and schemas.

### Assumptions and Dependencies

Bus Loans depends on reference data from `bus accounts` and `bus entities` and on the workspace layout and schema conventions. Missing datasets or schemas result in deterministic diagnostics.

### Security Considerations

Loan data is repository data and should be protected by repository access controls. Evidence references remain intact for auditability.

### Observability and Logging

Command results are written to standard output, and diagnostics are written to standard error with deterministic references to dataset paths and identifiers.

### Error Handling and Resilience

Invalid usage exits with a non-zero status and a concise usage error. Schema or reference violations exit non-zero without modifying datasets.

### Testing Strategy

Unit tests cover loan validation and amortization logic, and command-level tests exercise `init`, `add`, `event`, and `amortize` against fixture workspaces.

### Deployment and Operations

Not Applicable. The module ships as a BusDK CLI component and relies on the standard workspace layout.

### Migration/Rollout

Not Applicable. Schema evolution is handled through the standard schema migration workflow for workspace datasets.

### Risks

Not Applicable. Module-specific risks are not enumerated beyond the general need for deterministic loan data handling.

### Glossary and Terminology

Loan event: an append-only record of loan activity such as disbursement or repayment.  
Amortization schedule: derived records allocating principal and interest over time.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-assets">bus-assets</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-inventory">bus-inventory</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Owns master data: Loans](../master-data/loans/index)
- [Master data: Parties (customers and suppliers)](../master-data/parties/index)
- [Master data: Chart of accounts](../master-data/chart-of-accounts/index)
- [Master data: Accounting entity](../master-data/accounting-entity/index)
- [End user documentation: bus-loans CLI reference](../modules/bus-loans)
- [Repository](https://github.com/busdk/bus-loans)
- [Table schema contract](../data/table-schema-contract)
- [Append-only and soft deletion](../data/append-only-and-soft-deletion)

### Document control

Title: bus-loans module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-LOANS`  
Version: 2026-02-07  
Status: Draft  
Last updated: 2026-02-07  
Owner: BusDK development team  
