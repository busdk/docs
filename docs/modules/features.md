---
title: BusDK module feature table
description: Module-grouped feature tables aggregated from each module FEATURES.md with capability, interface, coverage, and maturity.
---

## BusDK module feature table

This page aggregates module feature rows from each module repository `FEATURES.md` file. Rows are grouped by module so each table stays compact while preserving cross-module scanability.

### [`bus`](./bus)

Use bus as the single entrypoint for modules and to execute deterministic .bus command files with global syntax preflight.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Use bus as the single entrypoint for modules and to execute deterministic .bus command files with global syntax preflight. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-accounts`](./bus-accounts)

CLI reference for bus accounts: init, list, add, set, validate, and sole-proprietor; chart of accounts as schema-validated repository data and stable identifiers for downstream modules.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus accounts: init, list, add, set, validate, and sole-proprietor; chart of accounts as schema-validated repository data and stable identifiers for downstream modules. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-accounts add workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-accounts init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-accounts list workflow | CLI | docs, e2e, unit | partial |
| `report` | Supports bus-accounts report workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-accounts set workflow | CLI | docs, e2e, unit | partial |
| `sole-proprietor` | Supports bus-accounts sole-proprietor workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-accounts validate workflow | CLI | docs, e2e, unit | partial |

### [`bus-agent`](./bus-agent)

CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only. | CLI | docs, e2e, unit | partial |
| `detect` | Supports bus-agent detect workflow | CLI | docs, e2e, unit | partial |
| `format` | Supports bus-agent format workflow | CLI | docs, e2e, unit | partial |
| `render` | Supports bus-agent render workflow | CLI | docs, e2e, unit | partial |
| `run` | Supports bus-agent run workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-agent set workflow | CLI | docs, e2e, unit | partial |

### [`bus-api`](./bus-api)

Bus API provides a local REST JSON API over the BusDK workspace in the selected root.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Bus API provides a local REST JSON API over the BusDK workspace in the selected root. | API | docs, e2e, unit | partial |
| `openapi` | Supports bus-api openapi workflow | API | docs, e2e, unit | partial |
| `serve` | Supports bus-api serve workflow | API | docs, e2e, unit | partial |
| `version` | Supports bus-api version workflow | API | docs, e2e, unit | partial |

### [`bus-api-provider-books`](./bus-api-provider-books)

SDD: https://docs.busdk.com/sdd/bus-api-provider-books

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | SDD: https://docs.busdk.com/sdd/bus-api-provider-books | API | docs, e2e, unit | partial |
| Provider adapter package | Provides books provider handler package for API integration | API | docs, e2e, unit | partial |

### [`bus-api-provider-data`](./bus-api-provider-data)

SDD: https://docs.busdk.com/sdd/bus-api-provider-data

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | SDD: https://docs.busdk.com/sdd/bus-api-provider-data | API | docs, e2e, unit | stub |
| Provider CLI stub | Exposes help/version-only provider binary surface | API | docs, e2e, unit | stub |

### [`bus-api-provider-session`](./bus-api-provider-session)

SDD: https://docs.busdk.com/sdd/bus-api-provider-session

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | SDD: https://docs.busdk.com/sdd/bus-api-provider-session | API | docs, e2e, unit | stub |
| Provider CLI stub | Exposes help/version-only provider binary surface | API | docs, e2e, unit | stub |

### [`bus-assets`](./bus-assets)

bus assets maintains the fixed-asset register and produces depreciation and disposal postings for the journal.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus assets maintains the fixed-asset register and produces depreciation and disposal postings for the journal. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-assets add workflow | CLI | docs, e2e, unit | partial |
| `depreciate` | Supports bus-assets depreciate workflow | CLI | docs, e2e, unit | partial |
| `dispose` | Supports bus-assets dispose workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-assets init workflow | CLI | docs, e2e, unit | partial |

### [`bus-attachments`](./bus-attachments)

CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-attachments add workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-attachments init workflow | CLI | docs, e2e, unit | partial |
| `link` | Supports bus-attachments link workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-attachments list workflow | CLI | docs, e2e, unit | partial |

### [`bus-balances`](./bus-balances)

bus balances owns an append-only snapshot dataset; use add or import to build snapshots, then apply to materialize one balanced journal transaction for opening or cutover.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus balances owns an append-only snapshot dataset; use add or import to build snapshots, then apply to materialize one balanced journal transaction for opening or cutover. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-balances add workflow | CLI | docs, e2e, unit | partial |
| `apply` | Supports bus-balances apply workflow | CLI | docs, e2e, unit | partial |
| `import` | Supports bus-balances import workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-balances init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-balances list workflow | CLI | docs, e2e, unit | partial |
| `template` | Supports bus-balances template workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-balances validate workflow | CLI | docs, e2e, unit | partial |

### [`bus-bank`](./bus-bank)

bus bank normalizes bank statement data into schema-validated datasets, supports adding bank accounts and transactions manually, and provides listing output for reconciliation and posting workflows.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus bank normalizes bank statement data into schema-validated datasets, supports adding bank accounts and transactions manually, and provides listing output for reconciliation and posting workflows. | CLI | docs, e2e, unit | partial |
| `backlog` | Supports bus-bank backlog workflow | CLI | docs, e2e, unit | partial |
| `config` | Supports bus-bank config workflow | CLI | docs, e2e, unit | partial |
| `import` | Supports bus-bank import workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-bank init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-bank list workflow | CLI | docs, e2e, unit | partial |
| `statement` | Supports bus-bank statement workflow | CLI | docs, e2e, unit | partial |

### [`bus-bfl`](./bus-bfl)

BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets. | CLI | docs, e2e, unit | partial |
| `eval` | Supports bus-bfl eval workflow | CLI | docs, e2e, unit | partial |
| `format` | Supports bus-bfl format workflow | CLI | docs, e2e, unit | partial |
| `funcset` | Supports bus-bfl funcset workflow | CLI | docs, e2e, unit | partial |
| `parse` | Supports bus-bfl parse workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-bfl validate workflow | CLI | docs, e2e, unit | partial |

### [`bus-books`](./bus-books)

Local web UI for BusDK bookkeeping: dashboard, Inbox, Journal, Periods, VAT, Bank, Attachments, validation; embeds Bus API and domain module backends.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Local web UI for BusDK bookkeeping: dashboard, Inbox, Journal, Periods, VAT, Bank, Attachments, validation; embeds Bus API and domain module backends. | UI/API | docs, e2e, unit | partial |
| `serve` | Supports bus-books serve workflow | UI/API | docs, e2e, unit | partial |
| `version` | Supports bus-books version workflow | UI/API | docs, e2e, unit | partial |

### [`bus-budget`](./bus-budget)

CLI reference for bus budget: maintain budget datasets by account and period, add or set amounts, and emit budget vs actual variance from journal data.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus budget: maintain budget datasets by account and period, add or set amounts, and emit budget vs actual variance from journal data. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-budget add workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-budget init workflow | CLI | docs, e2e, unit | partial |
| `report` | Supports bus-budget report workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-budget set workflow | CLI | docs, e2e, unit | partial |

### [`bus-config`](./bus-config)

bus config owns workspace-level configuration stored in datapackage.json at the workspace root.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus config owns workspace-level configuration stored in datapackage.json at the workspace root. | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-config init workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-config set workflow | CLI | docs, e2e, unit | partial |

### [`bus-data`](./bus-data)

bus data provides the shared tabular data layer for BusDK with deterministic Frictionless Table Schema and Data Package handling for workspace datasets.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus data provides the shared tabular data layer for BusDK with deterministic Frictionless Table Schema and Data Package handling for workspace datasets. | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-data init workflow | CLI | docs, e2e, unit | partial |
| `package` | Supports bus-data package workflow | CLI | docs, e2e, unit | partial |
| `resource` | Supports bus-data resource workflow | CLI | docs, e2e, unit | partial |
| `row` | Supports bus-data row workflow | CLI | docs, e2e, unit | partial |
| `schema` | Supports bus-data schema workflow | CLI | docs, e2e, unit | partial |
| `table` | Supports bus-data table workflow | CLI | docs, e2e, unit | partial |

### [`bus-dev`](./bus-dev)

bus dev is a developer-only companion that centralizes workflow logic that module repositories would otherwise duplicate in scripts/: module scaffolding, AGENTS.md creation and refinement, commit workflows, planning, agent-runner workflows, e2e test scaffolding, development-state documentation triage, and repository-local extensions (.bus/dev/) plus a context subcommand for prompt and script authors.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus dev is a developer-only companion that centralizes workflow logic that module repositories would otherwise duplicate in scripts/: module scaffolding, AGENTS.md creation and refinement, commit workflows, planning, agent-runner workflows, e2e test scaffolding, development-state documentation triage, and repository-local extensions (.bus/dev/) plus a context subcommand for prompt and script authors. | CLI | docs, e2e, unit | partial |
| `action` | Supports bus-dev action workflow | CLI | docs, e2e, unit | partial |
| `commit` | Supports bus-dev commit workflow | CLI | docs, e2e, unit | partial |
| `context` | Supports bus-dev context workflow | CLI | docs, e2e, unit | partial |
| `e2e` | Supports bus-dev e2e workflow | CLI | docs, e2e, unit | partial |
| `each` | Supports bus-dev each workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-dev init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-dev list workflow | CLI | docs, e2e, unit | partial |
| `pipeline` | Supports bus-dev pipeline workflow | CLI | docs, e2e, unit | partial |
| `plan` | Supports bus-dev plan workflow | CLI | docs, e2e, unit | partial |
| `round` | Supports bus-dev round workflow | CLI | docs, e2e, unit | partial |
| `script` | Supports bus-dev script workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-dev set workflow | CLI | docs, e2e, unit | partial |
| `spec` | Supports bus-dev spec workflow | CLI | docs, e2e, unit | partial |
| `stage` | Supports bus-dev stage workflow | CLI | docs, e2e, unit | partial |
| `triage` | Supports bus-dev triage workflow | CLI | docs, e2e, unit | partial |
| `work` | Supports bus-dev work workflow | CLI | docs, e2e, unit | partial |

### [`bus-entities`](./bus-entities)

bus entities maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus entities maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-entities add workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-entities init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-entities list workflow | CLI | docs, e2e, unit | partial |

### [`bus-events`](./bus-events)

SDD: https://docs.busdk.com/sdd/bus-events

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | SDD: https://docs.busdk.com/sdd/bus-events | Library | docs, e2e, unit | partial |
| Event bus envelope | Provides normalized event envelope and in-memory publish/subscribe for provider integration | Library | e2e, unit | partial |

### [`bus-filing`](./bus-filing)

bus filing produces deterministic filing bundles from validated, closed-period workspace data.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus filing produces deterministic filing bundles from validated, closed-period workspace data. | CLI | docs, e2e, unit | partial |
| `prh` | Supports bus-filing prh workflow | CLI | docs, e2e, unit | partial |
| `tax-audit-pack` | Supports bus-filing tax-audit-pack workflow | CLI | docs, e2e, unit | partial |
| `vero` | Supports bus-filing vero workflow | CLI | docs, e2e, unit | partial |

### [`bus-filing-prh`](./bus-filing-prh)

bus filing prh converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus filing prh converts validated workspace data into PRH-ready export bundles with deterministic packaging, manifests, and hashes. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-filing-vero`](./bus-filing-vero)

bus filing vero produces Vero export bundles from the canonical VAT and report layout; no manual reports or vat directories needed.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus filing vero produces Vero export bundles from the canonical VAT and report layout; no manual reports or vat directories needed. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-init`](./bus-init)

bus init creates workspace configuration (datapackage.json) by default; domain module inits run only when you pass per-module flags.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus init creates workspace configuration (datapackage.json) by default; domain module inits run only when you pass per-module flags. | CLI | docs, e2e, unit | partial |
| `defaults` | Supports bus-init defaults workflow | CLI | docs, e2e, unit | partial |

### [`bus-inventory`](./bus-inventory)

bus inventory maintains item master data and stock movement ledgers as schema-validated repository data.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus inventory maintains item master data and stock movement ledgers as schema-validated repository data. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-inventory add workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-inventory init workflow | CLI | docs, e2e, unit | partial |
| `move` | Supports bus-inventory move workflow | CLI | docs, e2e, unit | partial |
| `valuation` | Supports bus-inventory valuation workflow | CLI | docs, e2e, unit | partial |

### [`bus-invoices`](./bus-invoices)

bus invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the…

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the… | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-invoices add workflow | CLI | docs, e2e, unit | partial |
| `import` | Supports bus-invoices import workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-invoices init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-invoices list workflow | CLI | docs, e2e, unit | partial |
| `pdf` | Supports bus-invoices pdf workflow | CLI | docs, e2e, unit | partial |
| `postings` | Supports bus-invoices postings workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-invoices validate workflow | CLI | docs, e2e, unit | partial |

### [`bus-journal`](./bus-journal)

bus journal maintains the authoritative ledger as append-only journal entries.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus journal maintains the authoritative ledger as append-only journal entries. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-journal add workflow | CLI | docs, e2e, unit | partial |
| `balance` | Supports bus-journal balance workflow | CLI | docs, e2e, unit | partial |
| `classify` | Supports bus-journal classify workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-journal init workflow | CLI | docs, e2e, unit | partial |
| `template` | Supports bus-journal template workflow | CLI | docs, e2e, unit | partial |

### [`bus-loans`](./bus-loans)

bus loans maintains loan contracts and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions…

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus loans maintains loan contracts and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions… | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-loans add workflow | CLI | docs, e2e, unit | partial |
| `amortize` | Supports bus-loans amortize workflow | CLI | docs, e2e, unit | partial |
| `event` | Supports bus-loans event workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-loans init workflow | CLI | docs, e2e, unit | partial |

### [`bus-payroll`](./bus-payroll)

bus payroll validates payroll datasets and exports deterministic journal posting lines for a selected final payrun.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus payroll validates payroll datasets and exports deterministic journal posting lines for a selected final payrun. | CLI | docs, e2e, unit | partial |
| `export` | Supports bus-payroll export workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-payroll validate workflow | CLI | docs, e2e, unit | partial |

### [`bus-pdf`](./bus-pdf)

bus pdf renders deterministic PDFs from a JSON render model; template and content are chosen in the JSON so callers like bus-invoices can drive rendering with a single payload.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus pdf renders deterministic PDFs from a JSON render model; template and content are chosen in the JSON so callers like bus-invoices can drive rendering with a single payload. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-period`](./bus-period)

bus period adds periods in future state and manages period state (open, close, lock) and opening balances from a prior workspace as schema-validated repository data.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus period adds periods in future state and manages period state (open, close, lock) and opening balances from a prior workspace as schema-validated repository data. | CLI | docs, e2e, unit | partial |
| `add` | Supports bus-period add workflow | CLI | docs, e2e, unit | partial |
| `close` | Supports bus-period close workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-period init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-period list workflow | CLI | docs, e2e, unit | partial |
| `lock` | Supports bus-period lock workflow | CLI | docs, e2e, unit | partial |
| `open` | Supports bus-period open workflow | CLI | docs, e2e, unit | partial |
| `opening` | Supports bus-period opening workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-period set workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-period validate workflow | CLI | docs, e2e, unit | partial |

### [`bus-preferences`](./bus-preferences)

Set, get, list, and unset user-level BusDK preferences in a namespaced key-value file outside any workspace; no Git or network.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Set, get, list, and unset user-level BusDK preferences in a namespaced key-value file outside any workspace; no Git or network. | CLI | docs, e2e, unit | partial |
| `get` | Supports bus-preferences get workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-preferences list workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-preferences set workflow | CLI | docs, e2e, unit | partial |
| `set-json` | Supports bus-preferences set-json workflow | CLI | docs, e2e, unit | partial |
| `unset` | Supports bus-preferences unset workflow | CLI | docs, e2e, unit | partial |

### [`bus-reconcile`](./bus-reconcile)

bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees. | CLI | docs, e2e, unit | partial |
| `allocate` | Supports bus-reconcile allocate workflow | CLI | docs, e2e, unit | partial |
| `apply` | Supports bus-reconcile apply workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-reconcile init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-reconcile list workflow | CLI | docs, e2e, unit | partial |
| `match` | Supports bus-reconcile match workflow | CLI | docs, e2e, unit | partial |
| `post` | Supports bus-reconcile post workflow | CLI | docs, e2e, unit | partial |
| `propose` | Supports bus-reconcile propose workflow | CLI | docs, e2e, unit | partial |

### [`bus-replay`](./bus-replay)

bus replay exports a workspace to a deterministic, append-only replay log (JSONL or shell script) and applies it into a clean workspace for migration and parity verification.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus replay exports a workspace to a deterministic, append-only replay log (JSONL or shell script) and applies it into a clean workspace for migration and parity verification. | CLI | docs, e2e, unit | partial |
| `apply` | Supports bus-replay apply workflow | CLI | docs, e2e, unit | partial |
| `export` | Supports bus-replay export workflow | CLI | docs, e2e, unit | partial |
| `render` | Supports bus-replay render workflow | CLI | docs, e2e, unit | partial |

### [`bus-reports`](./bus-reports)

bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma. | CLI | docs, e2e, unit | partial |
| `balance-sheet` | Supports bus-reports balance-sheet workflow | CLI | docs, e2e, unit | partial |
| `balance-sheet-specification` | Supports bus-reports balance-sheet-specification workflow | CLI | docs, e2e, unit | partial |
| `compliance-checklist` | Supports bus-reports compliance-checklist workflow | CLI | docs, e2e, unit | partial |
| `day-book` | Supports bus-reports day-book workflow | CLI | docs, e2e, unit | partial |
| `general-ledger` | Supports bus-reports general-ledger workflow | CLI | docs, e2e, unit | partial |
| `journal-coverage` | Supports bus-reports journal-coverage workflow | CLI | docs, e2e, unit | partial |
| `journal-gap` | Supports bus-reports journal-gap workflow | CLI | docs, e2e, unit | partial |
| `materials-register` | Supports bus-reports materials-register workflow | CLI | docs, e2e, unit | partial |
| `parity` | Supports bus-reports parity workflow | CLI | docs, e2e, unit | partial |
| `profit-and-loss` | Supports bus-reports profit-and-loss workflow | CLI | docs, e2e, unit | partial |
| `trial-balance` | Supports bus-reports trial-balance workflow | CLI | docs, e2e, unit | partial |

### [`bus-run`](./bus-run)

bus run executes user-defined prompts, pipelines, and scripts with agentic support via the bus-agent library; no built-in developer workflows and no dependency on bus-dev. Optional bux shorthand for bus run.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus run executes user-defined prompts, pipelines, and scripts with agentic support via the bus-agent library; no built-in developer workflows and no dependency on bus-dev. Optional bux shorthand for bus run. | CLI | docs, e2e, unit | partial |
| `action` | Supports bus-run action workflow | CLI | docs, e2e, unit | partial |
| `context` | Supports bus-run context workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-run list workflow | CLI | docs, e2e, unit | partial |
| `pipeline` | Supports bus-run pipeline workflow | CLI | docs, e2e, unit | partial |
| `script` | Supports bus-run script workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-run set workflow | CLI | docs, e2e, unit | partial |

### [`bus-secrets`](./bus-secrets)

How to store and resolve repository-local secret references for BusDK workflows, and how to use them from bus dev and bus run.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | How to store and resolve repository-local secret references for BusDK workflows, and how to use them from bus dev and bus run. | CLI | docs, e2e, unit | partial |
| `doctor` | Supports bus-secrets doctor workflow | CLI | docs, e2e, unit | partial |
| `get` | Supports bus-secrets get workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-secrets init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-secrets list workflow | CLI | docs, e2e, unit | partial |
| `resolve` | Supports bus-secrets resolve workflow | CLI | docs, e2e, unit | partial |
| `set` | Supports bus-secrets set workflow | CLI | docs, e2e, unit | partial |
| `uninit` | Supports bus-secrets uninit workflow | CLI | docs, e2e, unit | partial |

### [`bus-sheets`](./bus-sheets)

Local web UI for BusDK workspaces: multi-tab workbook over CSV resources, view and edit rows and schemas, run validation; delegates to bus-api in-process.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Local web UI for BusDK workspaces: multi-tab workbook over CSV resources, view and edit rows and schemas, run validation; delegates to bus-api in-process. | UI/API | docs, e2e, unit | partial |
| `serve` | Supports bus-sheets serve workflow | UI/API | docs, e2e, unit | partial |
| `version` | Supports bus-sheets version workflow | UI/API | docs, e2e, unit | partial |

### [`bus-shell`](./bus-shell)

bus shell starts an interactive BusDK command prompt or runs one command and exits.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus shell starts an interactive BusDK command prompt or runs one command and exits. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-status`](./bus-status)

bus status reports deterministic workspace readiness and period close-state status for close-flow checks and automation.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus status reports deterministic workspace readiness and period close-state status for close-flow checks and automation. | CLI | docs, e2e, unit | partial |
| `readiness` | Supports bus-status readiness workflow | CLI | docs, e2e, unit | partial |

### [`bus-update`](./bus-update)

bus update checks whether newer module versions are available from the BusDK release index and can block stale module execution.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus update checks whether newer module versions are available from the BusDK release index and can block stale module execution. | CLI | docs, e2e, unit | partial |
| `check` | Supports bus-update check workflow | CLI | docs, e2e, unit | partial |
| `status` | Supports bus-update status workflow | CLI | docs, e2e, unit | partial |

### [`bus-validate`](./bus-validate)

bus validate checks workspace datasets against schemas and cross-table invariants such as balanced debits and credits, valid references, and period integrity.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus validate checks workspace datasets against schemas and cross-table invariants such as balanced debits and credits, valid references, and period integrity. | CLI | docs, e2e, unit | partial |
| `evidence-coverage` | Supports bus-validate evidence-coverage workflow | CLI | docs, e2e, unit | partial |
| `journal-gap` | Supports bus-validate journal-gap workflow | CLI | docs, e2e, unit | partial |
| `parity` | Supports bus-validate parity workflow | CLI | docs, e2e, unit | partial |

### [`bus-vat`](./bus-vat)

bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven and reconcile-evidence cash-basis VAT modes.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven and reconcile-evidence cash-basis VAT modes. | CLI | docs, e2e, unit | partial |
| `explain` | Supports bus-vat explain workflow | CLI | docs, e2e, unit | partial |
| `export` | Supports bus-vat export workflow | CLI | docs, e2e, unit | partial |
| `fi-file` | Supports bus-vat fi-file workflow | CLI | docs, e2e, unit | partial |
| `filed-diff` | Supports bus-vat filed-diff workflow | CLI | docs, e2e, unit | partial |
| `filed-import` | Supports bus-vat filed-import workflow | CLI | docs, e2e, unit | partial |
| `init` | Supports bus-vat init workflow | CLI | docs, e2e, unit | partial |
| `list` | Supports bus-vat list workflow | CLI | docs, e2e, unit | partial |
| `period-profile` | Supports bus-vat period-profile workflow | CLI | docs, e2e, unit | partial |
| `report` | Supports bus-vat report workflow | CLI | docs, e2e, unit | partial |
| `validate` | Supports bus-vat validate workflow | CLI | docs, e2e, unit | partial |

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus">bus</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module CLI reference index](./index)
- [Modules (SDD)](../sdd/modules)
- [Independent modules](../architecture/independent-modules)
