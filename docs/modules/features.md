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
| `add` | creates a new account and fails if --code already exists | CLI | docs, e2e, unit | partial |
| `init` | creates baseline accounts datasets and schemas | CLI | docs, e2e, unit | partial |
| `list` | prints the current chart in deterministic order | CLI | docs, e2e, unit | partial |
| `report` | renders a filing-grade tililuettelo in text, tsv, csv, markdown, or pdf format with deterministic ordering and optional workspace metadata from datapackage.json | CLI | docs, e2e, unit | partial |
| `set` | updates an existing account by --code and changes only attributes you provide, such as --name or --type | CLI | docs, e2e, unit | partial |
| `sole-proprietor` | emits balanced double-entry lines for owner withdrawal (withdrawal) and owner investment (investment) | CLI | docs, e2e, unit | partial |
| `validate` | checks both data rows and accounts.schema.json, including malformed schema-level definitions. | CLI | docs, e2e, unit | partial |

### [`bus-agent`](./bus-agent)

CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus agent: detect enabled runtimes, render prompt templates, run an agent with a prompt, format NDJSON output; for diagnostics and development only. | CLI | docs, e2e, unit | partial |
| `detect` | List currently available agent runtimes | CLI | docs, e2e, unit | partial |
| `format` | Read raw agent output from stdin and write formatted text to stdout | CLI | docs, e2e, unit | partial |
| `render` | Render a prompt template with the supplied variables and print the result to stdout | CLI | docs, e2e, unit | partial |
| `run` | Run the selected agent runtime with a prompt and stream output. | CLI | docs, e2e, unit | partial |
| `set` | Set a bus-agent persistent preference via the [bus-preferences](./bus-preferences) Go library (no shell-out to bus preferences) | CLI | docs, e2e, unit | partial |

### [`bus-api`](./bus-api)

Bus API provides a local REST JSON API over the BusDK workspace in the selected root.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Bus API provides a local REST JSON API over the BusDK workspace in the selected root. | API | docs, e2e, unit | partial |
| `openapi` | Emit the OpenAPI 3.1 document (JSON) to stdout | API | docs, e2e, unit | partial |
| `serve` | (default) — Start the HTTP server | API | docs, e2e, unit | partial |
| `version` | Print the tool name and version to stdout and exit 0 | API | docs, e2e, unit | partial |

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
| `add` | records a new asset acquisition | CLI | docs, e2e, unit | partial |
| `depreciate` | generates depreciation postings for a period | CLI | docs, e2e, unit | partial |
| `dispose` | records an asset disposal and emits disposal postings. | CLI | docs, e2e, unit | partial |
| `init` | creates the baseline assets datasets and schemas | CLI | docs, e2e, unit | partial |

### [`bus-attachments`](./bus-attachments)

CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus attachments: register evidence files, store metadata in attachments.csv, and let other modules link to evidence without embedding paths. | CLI | docs, e2e, unit | partial |
| `add` | registers a file and writes attachment metadata | CLI | docs, e2e, unit | partial |
| `init` | creates baseline attachment metadata and link datasets and schemas | CLI | docs, e2e, unit | partial |
| `link` | adds deterministic links from attachments to domain resources such as bank rows, vouchers, invoices, or custom kind/id targets | CLI | docs, e2e, unit | partial |
| `list` | prints registered attachments in deterministic order and supports filters, reverse-link graph output, and strict audit flags. | CLI | docs, e2e, unit | partial |

### [`bus-balances`](./bus-balances)

bus balances owns an append-only snapshot dataset; use add or import to build snapshots, then apply to materialize one balanced journal transaction for opening or cutover.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus balances owns an append-only snapshot dataset; use add or import to build snapshots, then apply to materialize one balanced journal transaction for opening or cutover. | CLI | docs, e2e, unit | partial |
| `add` | appends exactly one row to the snapshot | CLI | docs, e2e, unit | partial |
| `apply` | reads the effective snapshot for an as-of date and writes exactly one balanced journal transaction. | CLI | docs, e2e, unit | partial |
| `import` | appends one row per CSV data line into the same snapshot dataset, equivalent to many add runs | CLI | docs, e2e, unit | partial |
| `init` | creates the snapshot dataset and schema (balances.csv, balances.schema.json) when absent | CLI | docs, e2e, unit | partial |
| `list` | prints effective balances (one row per as-of and account, latest recorded_at wins) | CLI | docs, e2e, unit | partial |
| `template` | prints a CSV template (header plus example row) to stdout for import and does not read or write workspace files. | CLI | docs, e2e, unit | partial |
| `validate` | checks the snapshot dataset against its schema | CLI | docs, e2e, unit | partial |

### [`bus-bank`](./bus-bank)

bus bank normalizes bank statement data into schema-validated datasets, supports adding bank accounts and transactions manually, and provides listing output for reconciliation and posting workflows.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus bank normalizes bank statement data into schema-validated datasets, supports adding bank accounts and transactions manually, and provides listing output for reconciliation and posting workflows. | CLI | docs, e2e, unit | partial |
| `backlog` | reports posted versus unposted transactions for coverage checks and CI gates | CLI | docs, e2e, unit | partial |
| `config` | manages counterparty normalization and reference extractors | CLI | docs, e2e, unit | partial |
| `import` | ingests either a statement file (--file <path>) or profile-driven ERP input (--profile <path> --source <path>, optional --year) into normalized datasets | CLI | docs, e2e, unit | partial |
| `init` | creates baseline bank datasets and schemas | CLI | docs, e2e, unit | partial |
| `list` | prints filtered bank transactions deterministically | CLI | docs, e2e, unit | partial |
| `statement` | Extract and verify statement balance checkpoints | CLI | docs, e2e, unit | partial |

### [`bus-bfl`](./bus-bfl)

BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | BusDK Formula Language (BFL) is a small, deterministic expression language used to define computed fields in workspace datasets. | CLI | docs, e2e, unit | partial |
| `eval` | Evaluates a BFL expression against a provided JSON context (and optional schema) to produce deterministic typed results. | CLI | docs, e2e, unit | partial |
| `format` | Rewrites BFL expressions into canonical formatting so expressions are stable and readable across tools and commits. | CLI | docs, e2e, unit | partial |
| `funcset` | Lists compiled-in BFL function sets so users can see which functions are available for validation and evaluation. | CLI | docs, e2e, unit | partial |
| `parse` | Parses a BFL expression and prints its AST representation so syntax and structure can be verified quickly. | CLI | docs, e2e, unit | partial |
| `validate` | Validates expression parsing and type compatibility against a schema before formulas are used in datasets. | CLI | docs, e2e, unit | partial |

### [`bus-books`](./bus-books)

Local web UI for BusDK bookkeeping: dashboard, Inbox, Journal, Periods, VAT, Bank, Attachments, validation; embeds Bus API and domain module backends.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Local web UI for BusDK bookkeeping: dashboard, Inbox, Journal, Periods, VAT, Bank, Attachments, validation; embeds Bus API and domain module backends. | UI/API | docs, e2e, unit | partial |
| `serve` | (default) — Start the local HTTP server that serves the Bus Books web UI | UI/API | docs, e2e, unit | partial |
| `version` | Print the tool name and version to stdout and exit 0 | UI/API | docs, e2e, unit | partial |

### [`bus-budget`](./bus-budget)

CLI reference for bus budget: maintain budget datasets by account and period, add or set amounts, and emit budget vs actual variance from journal data.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | CLI reference for bus budget: maintain budget datasets by account and period, add or set amounts, and emit budget vs actual variance from journal data. | CLI | docs, e2e, unit | partial |
| `add` | inserts a budget row for an account and period | CLI | docs, e2e, unit | partial |
| `init` | creates baseline budget datasets and schemas | CLI | docs, e2e, unit | partial |
| `report` | emits budget-versus-actual variance output. | CLI | docs, e2e, unit | partial |
| `set` | upserts by account, year, and period | CLI | docs, e2e, unit | partial |

### [`bus-config`](./bus-config)

bus config owns workspace-level configuration stored in datapackage.json at the workspace root.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus config owns workspace-level configuration stored in datapackage.json at the workspace root. | CLI | docs, e2e, unit | partial |
| `init` | Create or ensure datapackage.json at the effective workspace root with a busdk.accounting_entity object | CLI | docs, e2e, unit | partial |
| `set` | Update accounting entity settings in the workspace datapackage.json. | CLI | docs, e2e, unit | partial |

### [`bus-data`](./bus-data)

bus data provides the shared tabular data layer for BusDK with deterministic Frictionless Table Schema and Data Package handling for workspace datasets.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus data provides the shared tabular data layer for BusDK with deterministic Frictionless Table Schema and Data Package handling for workspace datasets. | CLI | docs, e2e, unit | partial |
| `init` | Creates an empty workspace `datapackage.json` so dataset resources can be discovered and managed deterministically. | CLI | docs, e2e, unit | partial |
| `package` | Discovers, shows, patches, and validates `datapackage.json` resources so workspace package metadata stays consistent with tables and schemas. | CLI | docs, e2e, unit | partial |
| `resource` | Adds, lists, validates, and removes package resources with schema-aware safety checks, including foreign-key-aware removal rules. | CLI | docs, e2e, unit | partial |
| `row` | Adds, updates, and deletes table rows with schema validation, primary-key enforcement, and policy-based soft-delete behavior. | CLI | docs, e2e, unit | partial |
| `schema` | Initializes, inspects, infers, patches, and evolves table schemas, including field-level updates and formula metadata. | CLI | docs, e2e, unit | partial |
| `table` | Lists and reads table data with deterministic filtering, key-based lookup, and workbook-style cell/range extraction. | CLI | docs, e2e, unit | partial |

### [`bus-dev`](./bus-dev)

bus dev is a developer-only companion that centralizes workflow logic that module repositories would otherwise duplicate in scripts/: module scaffolding, AGENTS.md creation and refinement, commit workflows, planning, agent-runner workflows, e2e test scaffolding, development-state documentation triage, and repository-local extensions (.bus/dev/) plus a context subcommand for prompt and script authors.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus dev is a developer-only companion that centralizes workflow logic that module repositories would otherwise duplicate in scripts/: module scaffolding, AGENTS.md creation and refinement, commit workflows, planning, agent-runner workflows, e2e test scaffolding, development-state documentation triage, and repository-local extensions (.bus/dev/) plus a context subcommand for prompt and script authors. | CLI | docs, e2e, unit | partial |
| `action` | Management operations for repository-local prompt actions (.bus/dev/<name>.txt) | CLI | docs, e2e, unit | partial |
| `commit` | Create one or more commits from the currently staged changes only | CLI | docs, e2e, unit | partial |
| `context` | Print the full prompt-variable catalog and the current resolved values in deterministic, script-friendly form | CLI | docs, e2e, unit | partial |
| `e2e` | Guided workflow to detect missing end-to-end tests for the current module and scaffold them in a hermetic way, consistent with BusDK testing conventions and the module’s [SDD](../sdd/bus-dev) and end-user documentation | CLI | docs, e2e, unit | partial |
| `each` | Superproject-only helper that dispatches the remaining command as bus dev TOKEN.. | CLI | docs, e2e, unit | partial |
| `init` | Initialize module root files without performing any Git operations | CLI | docs, e2e, unit | partial |
| `list` | Print every runnable token available in the current context and what each executes, without running any agent, script, or Git operation | CLI | docs, e2e, unit | partial |
| `pipeline` | Management operations for user-defined pipelines | CLI | docs, e2e, unit | partial |
| `plan` | Build or refresh PLAN.md at repository root as a compact prioritized checklist of undone work | CLI | docs, e2e, unit | partial |
| `round` | Runs the built-in round pipeline (`work`, `e2e`, `stage`, `commit`) to execute one full implementation-and-commit cycle in one command. | CLI | docs, e2e, unit | partial |
| `script` | Management operations for repository-local script actions (.bus/dev/<name>.sh, .bus/dev/<name>.bat, and .bus/dev/<name>.ps1) | CLI | docs, e2e, unit | partial |
| `set` | Set a persistent preference via the [bus-preferences](./bus-preferences) Go library (no shell-out to bus preferences) | CLI | docs, e2e, unit | partial |
| `spec` | Ensure the repository has a compact but detailed local spec in [AGENTS.md](https://agents.md/) that reflects the latest BusDK specifications and describes how to implement this tool | CLI | docs, e2e, unit | partial |
| `stage` | Prepare the working tree for commit by ensuring only intended files are staged | CLI | docs, e2e, unit | partial |
| `triage` | Keep development-state documentation accurate, compact, and evidence-based by reconciling what users can actually do (as proven by tests) with what is planned next (PLAN.md) and what depends on what | CLI | docs, e2e, unit | partial |
| `work` | Run the canonical “do the work in this repo now” workflow | CLI | docs, e2e, unit | partial |

### [`bus-entities`](./bus-entities)

bus entities maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus entities maintains counterparty reference datasets with stable entity identifiers used by invoices, bank imports, reconciliation, and other modules. | CLI | docs, e2e, unit | partial |
| `add` | appends a new entity record. | CLI | docs, e2e, unit | partial |
| `init` | creates baseline entity datasets and schemas | CLI | docs, e2e, unit | partial |
| `list` | prints the registry in stable identifier order | CLI | docs, e2e, unit | partial |

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
| `prh` | produces a PRH-ready export bundle by invoking [bus-filing-prh](./bus-filing-prh) | CLI | docs, e2e, unit | partial |
| `tax-audit-pack` | produces a tax-audit filing bundle. | CLI | docs, e2e, unit | partial |
| `vero` | produces a Vero-ready export bundle by invoking bus-filing-vero | CLI | docs, e2e, unit | partial |

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
| `defaults` | ) and no module flags, only config init runs. | CLI | docs, e2e, unit | partial |

### [`bus-inventory`](./bus-inventory)

bus inventory maintains item master data and stock movement ledgers as schema-validated repository data.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus inventory maintains item master data and stock movement ledgers as schema-validated repository data. | CLI | docs, e2e, unit | partial |
| `add` | inserts an item into item master data | CLI | docs, e2e, unit | partial |
| `init` | creates the baseline inventory datasets and schemas | CLI | docs, e2e, unit | partial |
| `move` | appends stock movement records (in, out, or adjust) | CLI | docs, e2e, unit | partial |
| `valuation` | computes valuation output as of the selected date. | CLI | docs, e2e, unit | partial |

### [`bus-invoices`](./bus-invoices)

bus invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the…

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus invoices stores sales and purchase invoices as schema-validated repository data, validates totals and VAT amounts, and can emit posting outputs for the… | CLI | docs, e2e, unit | partial |
| `add` | creates invoice headers, and <invoice-id> add appends line items for an existing invoice | CLI | docs, e2e, unit | partial |
| `import` | maps ERP export data into canonical invoice datasets using a versioned profile and supports --dry-run | CLI | docs, e2e, unit | partial |
| `init` | creates baseline invoice datasets and schemas at workspace root when absent | CLI | docs, e2e, unit | partial |
| `list` | returns invoice rows with optional filters (combined with logical AND) | CLI | docs, e2e, unit | partial |
| `pdf` | delegates rendering to bus-pdf | CLI | docs, e2e, unit | partial |
| `postings` | emits invoice posting rows for bus-journal. | CLI | docs, e2e, unit | partial |
| `validate` | checks full invoice datasets, while <invoice-id> validate checks one invoice’s lines and totals. | CLI | docs, e2e, unit | partial |

### [`bus-journal`](./bus-journal)

bus journal maintains the authoritative ledger as append-only journal entries.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus journal maintains the authoritative ledger as append-only journal entries. | CLI | docs, e2e, unit | partial |
| `add` | appends a balanced transaction with one or more debit and credit lines | CLI | docs, e2e, unit | partial |
| `balance` | prints account balances as of a given date. | CLI | docs, e2e, unit | partial |
| `classify` | supports deterministic bank-driven proposal and apply flows | CLI | docs, e2e, unit | partial |
| `init` | creates the journal index and baseline datasets and schemas | CLI | docs, e2e, unit | partial |
| `template` | posts a single template-driven entry | CLI | docs, e2e, unit | partial |

### [`bus-loans`](./bus-loans)

bus loans maintains loan contracts and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions…

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus loans maintains loan contracts and event logs as schema-validated repository data, generates amortization schedules, and produces posting suggestions… | CLI | docs, e2e, unit | partial |
| `add` | records a loan contract in the register | CLI | docs, e2e, unit | partial |
| `amortize` | generates amortization and posting output for a period. | CLI | docs, e2e, unit | partial |
| `event` | appends a disbursement, repayment, interest, fee, or adjustment event and can produce postings | CLI | docs, e2e, unit | partial |
| `init` | creates the baseline loan datasets and schemas | CLI | docs, e2e, unit | partial |

### [`bus-payroll`](./bus-payroll)

bus payroll validates payroll datasets and exports deterministic journal posting lines for a selected final payrun.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus payroll validates payroll datasets and exports deterministic journal posting lines for a selected final payrun. | CLI | docs, e2e, unit | partial |
| `export` | validates first, then emits deterministic posting CSV for the selected final payrun. | CLI | docs, e2e, unit | partial |
| `validate` | checks payroll datasets and schemas in the workspace root | CLI | docs, e2e, unit | partial |

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
| `add` | creates a single period row in state future | CLI | docs, e2e, unit | partial |
| `close` | creates closing entries and transitions open to closed | CLI | docs, e2e, unit | partial |
| `init` | creates the period control dataset and schema when absent | CLI | docs, e2e, unit | partial |
| `list` | shows effective current state per period and supports --history where available | CLI | docs, e2e, unit | partial |
| `lock` | transitions closed to locked without creating postings | CLI | docs, e2e, unit | partial |
| `open` | moves a period from future to open | CLI | docs, e2e, unit | partial |
| `opening` | generates one balanced opening transaction from a prior workspace’s closing balances and requires --from, --as-of, --post-date, and --period. | CLI | docs, e2e, unit | partial |
| `set` | appends a retained-earnings account repair record for an existing period and is allowed only in future or open. | CLI | docs, e2e, unit | partial |
| `validate` | checks dataset integrity and rejects invalid effective records and duplicate primary keys | CLI | docs, e2e, unit | partial |

### [`bus-preferences`](./bus-preferences)

Set, get, list, and unset user-level BusDK preferences in a namespaced key-value file outside any workspace; no Git or network.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Set, get, list, and unset user-level BusDK preferences in a namespaced key-value file outside any workspace; no Git or network. | CLI | docs, e2e, unit | partial |
| `get` | Print value for <key> to stdout. | CLI | docs, e2e, unit | partial |
| `list` | List keys in sorted deterministic order. | CLI | docs, e2e, unit | partial |
| `set` | Store <value> as a JSON string for <key>. | CLI | docs, e2e, unit | partial |
| `set-json` | Store arbitrary JSON value for <key>. | CLI | docs, e2e, unit | partial |
| `unset` | Remove <key> if present. | CLI | docs, e2e, unit | partial |

### [`bus-reconcile`](./bus-reconcile)

bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus reconcile links bank transactions to invoices or journal entries and records allocations for partials, splits, and fees. | CLI | docs, e2e, unit | partial |
| `allocate` | records split allocations across multiple invoices or journal entries, and allocations must sum to the bank amount | CLI | docs, e2e, unit | partial |
| `apply` | consumes approved proposals and writes matches or allocations deterministically, with --dry-run and idempotent re-apply behavior | CLI | docs, e2e, unit | partial |
| `init` | bootstraps matches.csv and matches.schema.json at workspace root with deterministic defaults | CLI | docs, e2e, unit | partial |
| `list` | prints reconciliation records. | CLI | docs, e2e, unit | partial |
| `match` | records one-to-one links between bank transactions and invoice or journal transactions, with exact amount matching | CLI | docs, e2e, unit | partial |
| `post` | converts invoice_payment match rows to journal postings using invoice evidence (net plus VAT) | CLI | docs, e2e, unit | partial |
| `propose` | generates deterministic proposal rows from unreconciled bank and invoice/journal data and includes confidence and reason fields | CLI | docs, e2e, unit | partial |

### [`bus-replay`](./bus-replay)

bus replay exports a workspace to a deterministic, append-only replay log (JSONL or shell script) and applies it into a clean workspace for migration and parity verification.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus replay exports a workspace to a deterministic, append-only replay log (JSONL or shell script) and applies it into a clean workspace for migration and parity verification. | CLI | docs, e2e, unit | partial |
| `apply` | executes a replay log against a target workspace | CLI | docs, e2e, unit | partial |
| `export` | reads the current workspace snapshot and emits a deterministic replay log | CLI | docs, e2e, unit | partial |
| `render` | transforms a replay log into another format | CLI | docs, e2e, unit | partial |

### [`bus-reports`](./bus-reports)

bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus reports computes financial reports from journal and reference data, including deterministic Finnish statutory statement layouts for Tase and tuloslaskelma. | CLI | docs, e2e, unit | partial |
| `balance-sheet` | prints balance sheet as of a date. | CLI | docs, e2e, unit | partial |
| `balance-sheet-specification` | emits an internal-only balance-sheet breakdown (tase-erittely) by statement line and account with evidence references for audit packs; it is not a public filing document. | CLI | docs, e2e, unit | partial |
| `compliance-checklist` | emits a Finnish legal-form-aware checklist for the selected period with required, conditionally_required, and not_applicable states | CLI | docs, e2e, unit | partial |
| `day-book` | prints postings in date order (päiväkirja) for the period | CLI | docs, e2e, unit | partial |
| `general-ledger` | prints ledger detail for a period and can be filtered by account | CLI | docs, e2e, unit | partial |
| `journal-coverage` | emits deterministic monthly comparison between imported operational totals and non-opening journal activity | CLI | docs, e2e, unit | partial |
| `journal-gap` | emit deterministic migration-review artifacts for use with bus-validate threshold and CI behavior | CLI | docs, e2e, unit | partial |
| `materials-register` | emits a deterministic index of accounting records and materials (luettelo kirjanpidoista ja aineistoista) based on datapackage.json resources and their schemas, including linkage fields and retention classes for audit evidence packs | CLI | docs, e2e, unit | partial |
| `parity` | and journal-gap emit deterministic migration-review artifacts for use with [bus-validate](./bus-validate) threshold and CI behavior | CLI | docs, e2e, unit | partial |
| `profit-and-loss` | prints period P&L, and balance-sheet prints balance sheet as of a date. | CLI | docs, e2e, unit | partial |
| `trial-balance` | prints trial balance as of a date and supports text (default) or csv | CLI | docs, e2e, unit | partial |

### [`bus-run`](./bus-run)

bus run executes user-defined prompts, pipelines, and scripts with agentic support via the bus-agent library; no built-in developer workflows and no dependency on bus-dev. Optional bux shorthand for bus run.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus run executes user-defined prompts, pipelines, and scripts with agentic support via the bus-agent library; no built-in developer workflows and no dependency on bus-dev. Optional bux shorthand for bus run. | CLI | docs, e2e, unit | partial |
| `action` | Creates, lists, and removes project-local prompt actions (`.bus/run/<name>.txt`) that can be executed as run tokens. | CLI | docs, e2e, unit | partial |
| `list` | Prints every runnable token in the current project with source details and normalized pipeline expansions, without executing anything. | CLI | docs, e2e, unit | partial |
| `pipeline` | Defines, previews, lists, and removes user pipelines from `.bus/run/*.yml` or `bus-run.pipeline.*` preferences. | CLI | docs, e2e, unit | partial |
| `script` | Creates, lists, and removes project-local script actions (`.sh`, `.bat`, `.ps1`) that run as named bus run tokens. | CLI | docs, e2e, unit | partial |

### [`bus-secrets`](./bus-secrets)

How to store and resolve repository-local secret references for BusDK workflows, and how to use them from bus dev and bus run.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | How to store and resolve repository-local secret references for BusDK workflows, and how to use them from bus dev and bus run. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-sheets`](./bus-sheets)

Local web UI for BusDK workspaces: multi-tab workbook over CSV resources, view and edit rows and schemas, run validation; delegates to bus-api in-process.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | Local web UI for BusDK workspaces: multi-tab workbook over CSV resources, view and edit rows and schemas, run validation; delegates to bus-api in-process. | UI/API | docs, e2e, unit | partial |
| `serve` | (default) — Start the local HTTP server that serves the Bus Sheets web UI | UI/API | docs, e2e, unit | partial |
| `version` | Print the tool name and version to stdout and exit 0 | UI/API | docs, e2e, unit | partial |

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
| `readiness` | checks core workspace readiness and latest period close state. | CLI | docs, e2e, unit | partial |

### [`bus-update`](./bus-update)

bus update checks whether newer module versions are available from the BusDK release index and can block stale module execution.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus update checks whether newer module versions are available from the BusDK release index and can block stale module execution. | CLI | docs, e2e, unit | partial |
| Single-command workflow | Operates through module-level flags without named subcommands | CLI | docs, e2e, unit | partial |

### [`bus-validate`](./bus-validate)

bus validate checks all workspace datasets against their schemas and enforces cross-table invariants (e.g.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus validate checks all workspace datasets against their schemas and enforces cross-table invariants (e.g. | CLI | docs, e2e, unit | partial |
| `evidence-coverage` | provides evidence link coverage totals and missing IDs; see Evidence coverage below. | CLI | docs, e2e, unit | partial |
| `journal-gap` | provide first-class migration checks; see Parity and gap checks (first-class) below | CLI | docs, e2e, unit | partial |
| `parity` | and journal-gap provide first-class migration checks; see Parity and gap checks (first-class) below | CLI | docs, e2e, unit | partial |

### [`bus-vat`](./bus-vat)

bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven and reconcile-evidence cash-basis VAT modes.

| Feature | User-visible capability | Interface | Coverage | Maturity |
| --- | --- | --- | --- | --- |
| Core capability | bus vat computes VAT totals per reporting period, validates VAT code and rate mappings, reconciles invoice VAT with ledger postings, and supports journal-driven and reconcile-evidence cash-basis VAT modes. | CLI | docs, e2e, unit | partial |
| `explain` | emits deterministic row-level FI filing trace grouped by FI field keys (tsv/json) for audit verification. | CLI | docs, e2e, unit | partial |
| `export` | writes VAT export output for a period (e.g | CLI | docs, e2e, unit | partial |
| `fi-file` | emits one-command Finnish VAT filing payload values (machine-consumable json/csv/tsv) with deterministic formulas, provenance refs, and calculation_version metadata. | CLI | docs, e2e, unit | partial |
| `filed-diff` | compares filed VAT totals vs replay totals for the same period and emits deterministic machine-readable TSV with filed/replay/delta values for output/input/net VAT | CLI | docs, e2e, unit | partial |
| `filed-import` | imports externally filed VAT evidence for a period with provenance (source_path, source_sha256) and writes canonical period data at workspace root (vat-filed-<period>.csv) plus an index row in vat-filed.csv | CLI | docs, e2e, unit | partial |
| `init` | creates the baseline VAT datasets and schemas (e.g | CLI | docs, e2e, unit | partial |
| `list` | outputs deterministic profile rows | CLI | docs, e2e, unit | partial |
| `period-profile` | manages named filing period profiles in vat-period-profiles.csv: | CLI | docs, e2e, unit | partial |
| `report` | computes and emits the VAT summary for a given period | CLI | docs, e2e, unit | partial |
| `validate` | Validate VAT master data (rates, mappings) and optionally invoice, journal, or reconcile evidence rows per --source | CLI | docs, e2e, unit | partial |

