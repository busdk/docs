# BuSDK Design Spec: System architecture

## Architectural overview

BuSDK is a collection of loosely coupled modules centered around a single Git-backed data repository. It intentionally avoids a monolithic application design and instead follows a “micro-tool” architecture: each feature area is implemented as an independent CLI tool (or service) that reads and writes a shared dataset. Modules coordinate by sharing data and by relying on the Git history as a durable audit trail, rather than by calling each other’s internal APIs.

This design mirrors the practical benefits of Unix composability in modern toolchains, where interoperability arises from stable, simple interfaces and predictable conventions. ([catb.org](https://www.catb.org/esr/writings/taoup/html/ch01s06.html?utm_source=chatgpt.com)) In BuSDK, the stable interface is the repository: a set of CSV resources governed by Frictionless schemas and organized in a consistent directory structure.

## Core components

The data store is a Git repository containing all business records in CSV form plus their schemas. Git is not used merely for source control; it is treated as the database. Modules treat the Git-managed files as the single source of truth. When reading data, a module operates on the current working state of the repository. When writing data, it modifies the relevant CSV files and produces a commit describing the operation. Git provides an immutable log of changes, revert capability, and branching for experimentation or review. The Git internals model—content-addressed objects and parent-linked commits—provides a cryptographically chained record that supports tamper-evidence when histories are shared and anchor points are agreed. ([Git](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects?utm_source=chatgpt.com))

Modules are independent tools or services. Each functional area is a module: ledger, invoice, bank import, VAT, budget, and related features. Modules encapsulate their domain logic and do not call each other’s functions directly. Integration occurs through shared datasets. When the invoice module needs to produce ledger impact, it writes journal entries into the journal dataset through the same data layer conventions as the ledger module, rather than invoking ledger APIs. This keeps modules loosely coupled and allows modules to be implemented in different languages. For example, a Python component could generate PDFs while a Go component enforces ledger integrity, both interoperating through CSV files and Git commits.

The CLI is the primary interface. Commands are expected to perform a controlled read-modify-write cycle: load the necessary resources from the repository, validate requested changes against schema and business rules, apply the operation, write the updated files, then commit the change with a descriptive message. For example, a journal command such as:

```bash
busdk journal add --date 2026-01-15 --debit Cash --credit Sales --amount 500 --desc "Invoice 1001 payment"
```

is expected to append new ledger rows to the journal file and commit with a message that narrates what happened, such as “Add journal entry: 2026-01-15 Invoice 1001 payment.” This makes the CLI the gatekeeper of data integrity and reduces the risk of user error compared with manual CSV editing.

A shared validation layer is foundational. Each module relies on schema validation and logical validation before accepting a mutation. Schema validation checks types and constraints such as required fields, formats, keys, and referential integrity. Logical validation enforces accounting rules such as balanced double-entry transactions and consistency of invoice totals. Schema compliance is standardized via Table Schema. ([Frictionless Data](https://frictionlessdata.io/specs/table-schema/?utm_source=chatgpt.com)) Logical validation is implemented in module logic, particularly where cross-row invariants are required (for example, “sum of debits equals sum of credits for a transaction group”).

## Append-only discipline and security model

Historical financial data is append-only. Modules add lines, mark records inactive where appropriate, and avoid destructive updates. If scrubbing sensitive data is ever required, it is handled via an explicit redaction commit that flags the redaction rather than silently excising history.

In single-user operation on a local machine, security is primarily OS-level control. In collaborative scenarios, Git permissions and workflows are used to control who can propose and approve changes. Branch protections, pull requests, and reviews can enforce separation of duties such as preparer-versus-approver. The architecture is designed so these workflows are natural extensions of the Git data store rather than special cases.

