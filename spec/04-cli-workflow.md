# BuSDK Design Spec: CLI tooling and workflow

## Command structure and discoverability

BuSDK is CLI-first. Commands are organized by module and generally follow a verb-noun structure. Examples include `busdk accounts add` for chart-of-accounts changes; `busdk journal record` (and, in some contexts, `busdk journal add`) for ledger entry creation; `busdk invoice create` for invoice creation; `busdk invoice generate-pdf` or `busdk invoice pdf` for invoice document generation; `busdk vat report` for VAT summaries; and `busdk budget set` or `busdk budget add` for budgeting operations. The top-level `busdk` command or `busdk help` is expected to list available modules and commands, while module-level help such as `busdk journal --help` provides command usage details.

## Interactive use and scripting parity

Every command must be usable interactively and non-interactively. Interactive prompts are used when the user omits parameters, enabling a guided experience. Non-interactive flags and arguments must allow full scripting and automation. This includes workflows such as nightly cron-driven bank imports or scripted ledger entries produced by external systems.

## Validation and safety checks

Before any data mutation, the CLI performs schema validation and logical validation. Schema validation ensures type correctness and referential integrity. Logical validation enforces business rules such as existing account references, balanced debits and credits for transactions, invoice totals matching line items, and VAT classification completeness when generating VAT reports. If errors are found, the command fails with a clear diagnostic and refuses to commit invalid data.

## Automated Git commits per operation

A distinctive behavior of BuSDK is integrating Git into the default workflow. After a command successfully updates data, the CLI stages and commits changes with templated, descriptive messages so the user does not need to manually perform `git add` and `git commit` for routine bookkeeping. For example:

```bash
busdk accounts add --code 3000 --name "Consulting Income" --type Income
```

is expected to append a new account row to `accounts.csv` and commit with a message such as “Add account 3000 Consulting Income.”

The default model is “one commit per high-level operation” to maximize audit clarity and align with append-only discipline. BuSDK may also support batching operations into a single commit either through explicit batch modes or by allowing auto-commit to be disabled so the user can commit manually after a series of commands.

## Reporting and query commands

In addition to mutating commands, BuSDK provides read-only query and reporting commands that compute balances, statuses, and summaries from the CSV resources. Examples include `busdk accounts list`; `busdk journal balance --as-of 2026-03-31`; `busdk invoice list --status unpaid`; `busdk vat report Q1-2026`; and `busdk budget report --period 2026`. Output is expected to be human-readable and may include tabular terminal formatting; where relevant, machine-readable output options should exist for integration with scripts and downstream analysis.

## Extensible CLI surface and API parity

As new modules are added, they introduce new subcommands without breaking existing behavior. The CLI should correspond to underlying library functions where feasible so that future API layers can wrap the same logic. The eventual architecture anticipates an “API parity” model where CLI operations map cleanly to callable functions or REST endpoints.

## Error handling, dry-run, and diagnostics

The CLI is expected to fail gracefully and provide clear error messages. If Git is not available or the repository is not initialized, the tool should detect this and instruct the user to run an initialization command or to operate within the correct directory. Merge conflicts caused by concurrent edits or manual file modifications must be detected and surfaced, with guidance for resolution. A `--dry-run` flag should be available to preview changes without committing. Optional logging should provide visibility into validation steps and Git commands executed, supporting trust and diagnosability.

