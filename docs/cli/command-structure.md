---
title: Command structure and discoverability
description: BusDK is CLI-first.
---

## Command structure and discoverability

BusDK is CLI-first. Commands are organized by module and generally follow a verb-noun structure. Subcommand names follow [CLI command naming](./command-naming). Most modules accept a common set of [standard global flags](./global-flags) (help, version, verbosity, working directory, output redirection, format, and color) before the subcommand. Examples include `bus accounts add` for chart-of-accounts changes; `bus journal add` for appending balanced journal entries; `bus invoices add` for adding invoice records; `bus invoices pdf` for rendering invoice PDFs from stored invoice data; `bus vat report` for VAT summaries; and `bus budget set` or `bus budget add` for budgeting operations. The top-level `bus` command or `bus help` is expected to list available modules and commands, while module-level help such as `bus journal --help` provides command usage details.

### Development state

The dispatcher runs today: it delegates to `bus-<module>` binaries on PATH and orchestrates `bus init` with config and module-include flags. Every module is invoked through it when users run `bus <module> …` or `bus init`. Planned next: when the first argument is `help` and `bus-help` is not on PATH, show usage and available commands then exit 2; add e2e tests for no-args, missing subcommand, and successful dispatch; add CONTRIBUTING.md or update README. The bus repo has no dependency on other modules. See [Development status](../implementation/development-status) for the project-wide snapshot.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./automated-git-commits">Git commit conventions per operation (external Git)</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="../cli/index">BusDK Design Spec: CLI tooling and workflow</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./global-flags">Standard global flags</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->
