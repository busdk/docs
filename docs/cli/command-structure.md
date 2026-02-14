---
title: Command structure and discoverability
description: BusDK is CLI-first.
---

## Command structure and discoverability

BusDK is CLI-first. Commands are organized by module and generally follow a verb-noun structure. Subcommand names follow [CLI command naming](./command-naming). Most modules accept a common set of [standard global flags](./global-flags) (help, version, verbosity, working directory, output redirection, format, and color) before the subcommand. Examples include `bus accounts add` for chart-of-accounts changes; `bus journal add` for appending balanced journal entries; `bus invoices add` for adding invoice records; `bus invoices pdf` for rendering invoice PDFs from stored invoice data; `bus vat report` for VAT summaries; and `bus budget set` or `bus budget add` for budgeting operations. The top-level `bus` command or `bus help` is expected to list available modules and commands, while module-level help such as `bus journal --help` provides command usage details.

### Development state

**Value:** Single entrypoint that delegates to `bus-<module>` binaries and orchestrates `bus init` (config and optional module inits) so users can run one command to set up or run any module.

**Completeness:** 50% (Primary journey) — no-args and missing-subcommand behavior are verified by unit tests; successful dispatch is tested; `bus help` when bus-help is missing and e2e are not yet in place.

**Current:** With no arguments the dispatcher prints usage and available commands and exits 2 (`internal/dispatch/run_test.go`). When the subcommand is missing or not on PATH it exits 127 and reports the missing command. Successful delegation to a module binary is covered by the same tests.

**Planned next:** When the first argument is `help` and `bus-help` is not on PATH, show usage and available commands then exit 2; add e2e tests for no-args, missing subcommand, and successful dispatch; add CONTRIBUTING.md or update README.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Every [module](../modules/index) is invoked through it when users run `bus <module> …` or `bus init`.

See [Development status](../implementation/development-status) for the project-wide snapshot.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./automated-git-commits">Git commit conventions per operation (external Git)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./global-flags">Standard global flags</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
