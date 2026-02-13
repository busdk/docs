---
title: bus-dev
description: "bus dev is a developer-only companion that centralizes workflow logic that module repositories would otherwise duplicate in scripts/: module scaffolding,…"
---

## bus-dev

### Name

`bus dev` — developer workflows for BusDK module repositories.

### Synopsis

`bus dev [-h] [-V] [-v] [-q] [-C <dir>] [-o <file>] [--color <auto|always|never>] [--no-color] [--agent <cursor|codex|gemini|claude>] <operation> [operation ...]`

Operations: **`init`**, **`commit`**, **`plan`**, **`spec`**, **`work`**, **`e2e`**. You can pass one operation per invocation, or list two or more of the workflow operations (**spec**, **work**, **e2e**) to run them in sequence, one at a time. The first operation determines how remaining arguments are parsed: **init** accepts an optional directory argument, then optional workflow operations from the same set; **commit** and **plan** take no further positionals; **spec**, **work**, and **e2e** accept optional further operations from that same set and run in order.

`bus dev init [DIR] [--lang go] [spec|work|e2e ...]` — initialize module files in the current directory by default, or in `DIR` when provided; does not run spec/work/e2e unless explicitly listed.  
`bus dev commit` — commit staged changes with high-quality messages (no remote, no history rewrite).  
`bus dev plan` — review SDD and docs against repository state, then refresh `PLAN.md` with prioritized unchecked undone work items only.  
`bus dev spec` — refine only the current module’s Cursor MDC rule file to align with BusDK specs.  
`bus dev work` — run the “do the work in this repo” agent workflow (code, tests, README).  
`bus dev e2e` — guided workflow to detect and scaffold missing end-to-end tests.  
`bus dev spec [work [e2e]]` — run one or more of spec, work, e2e in the order given (e.g. `bus dev spec work e2e` runs all three in sequence; if one fails, the run stops).

### Description

Command names follow [CLI command naming](../cli/command-naming). `bus dev` is a developer-only companion that centralizes workflow logic that module repositories would otherwise duplicate in `scripts/`: module scaffolding, commit workflows, planning from documentation coverage gaps, agent-runner workflows, MDC refinement, and e2e test scaffolding. It provides a single entry point so behavior and prompts stay consistent and maintainable in one place, as described in the [module SDD](../sdd/bus-dev). Agent runtime execution (invoking Cursor CLI, Codex, Gemini CLI, or Claude CLI) is provided by the [bus-agent](../sdd/bus-agent) library so that runtimes, detection, and diagnostics are consistent across BusDK; bus-dev supplies the workflow prompts and repository context. The CLI accepts a single operation (e.g. `bus dev work`) or multiple workflow operations in one invocation (e.g. `bus dev spec work e2e`); when multiple are given, they run in order, one at a time, and the run stops on first failure. Most subcommands operate on the **current Git repository** (source code and Cursor rules); `bus dev init` is the exception — it can initialize files in place for the current directory, or in an explicitly provided target directory, without creating or touching a Git repository unless you do that yourself later. The tool does not operate on workspace accounting datasets. End users running `bus accounts`, `bus journal`, or `bus validate` do not need `bus dev`; it exists for contributors and automation working inside (or creating) a BusDK module repository.

All paths and the working directory are resolved relative to the current directory unless you set `-C` / `--chdir`. The tool discovers the repository root from the effective working directory and does not require a config file for repository-scoped commands. Subcommands that need a module name in repository scope (for example for the MDC path or e2e script naming) derive it deterministically from the repository: the module name is the base name of the repository root directory (the last path component of the absolute path to the repo root). For `init`, which can run outside a Git repository, the module name is derived from the base name of the init target directory.

**Safety.** `bus dev` never runs remote Git operations (no push, pull, fetch, clone) and never rewrites history (no amend, rebase, squash). It may run local `git commit` only on already-staged content. Diagnostics and progress go to stderr; stdout is reserved for deterministic results when a subcommand produces them. When run from a script or CI (headless), workflows remain non-interactive and do not perform prohibited actions such as network operations or modifying user-global agent configuration.

### Commands

**`init [DIR] [--lang go] [spec|work|e2e ...]`** — Initialize module root files without performing any Git operations. If `DIR` is omitted, initialization happens in the effective current working directory. If `DIR` is provided, initialization happens there (the directory is created if missing). Initialization ensures a `.cursor/rules` directory exists, ensures the module MDC file exists at `.cursor/rules/<module>.mdc` (where `<module>` is the target directory name), and ensures a root `Makefile` exists by writing a built-in sample Makefile when missing. The `--lang` flag defaults to `go` and controls which default MDC content is used. By default this command only initializes files; it does **not** run `spec`, `work`, or `e2e`. To run workflow operations as part of init, append them explicitly and they will run in the exact order provided, for example `bus dev init spec work e2e` (current directory) or `bus dev init bus-accounts spec work e2e` (target directory). If any requested step fails, the command exits non-zero with a clear diagnostic. Use this when you want deterministic in-place initialization first, then optional AI workflow steps under explicit control.

**`commit`** — Create one or more commits from the **currently staged** changes only. If there is nothing staged (and no submodules with staged changes to commit), the command does nothing and exits 0. The tool does not modify files, does not stage anything, and does not amend or rebase. If the repository has submodules, it commits inside submodules first (depth-first), then the superproject only if it has staged changes. If a submodule commit leaves an unstaged gitlink in the superproject, the tool reports that clearly and stops without staging it; you must stage the gitlink manually if desired. For each commit, the message must have a concise, imperative subject line; a body may follow, with traceability (issue IDs or URLs) when helpful. By default the tool commits exactly what is currently staged and does not alter the staging area. If a hook (e.g. pre-commit, commit-msg) fails, the tool reports the failure and exits non-zero; it does not retry.

**`plan`** — Build or refresh `PLAN.md` at repository root as a compact prioritized checklist of undone work. The command reviews the current repository, the [main SDD](../sdd), the current module SDD, the current module end-user docs, and other project SDD pages relevant to requirement coverage. It detects unimplemented features and other undone work and writes only `PLAN.md`. When `PLAN.md` already exists, the command re-validates existing items, removes items that are already done (including checked items), keeps items that are still undone, and adds newly detected missing work. This command is the one that prunes completed checked items from the plan. The file written by `bus dev plan` is a compact unchecked task list ordered by priority, with one unchecked item per undone work item and no implementation-level detail that should instead come from the SDD and related docs.

**`work`** — Run the canonical “do the work in this repo now” workflow. May be combined with **spec** and **e2e** in one invocation (e.g. `bus dev spec work e2e`); operations run in the order given and stop on first failure. At the start of each agent step (plan, work, spec, e2e), the tool prints to stderr which internal agent runtime and which model are in use for that step. The tool invokes the configured external agent runtime with an embedded prompt that tells it to operate only inside the current module repository: make concrete code changes, add or update tests, run the Makefile checks, and update README before finishing. The agent is allowed to read the repository’s Cursor rules and design docs as the authoritative specs. When `PLAN.md` exists at repository root, the workflow reads it first and prioritizes unchecked items before proposing additional work. As work items are completed, `bus dev work` checks them off in `PLAN.md`. It does not remove already checked items; checked-item pruning is handled by `bus dev plan`. When the selected runtime is Gemini CLI, the agent may also use repository-local Gemini context (e.g. repo-root `GEMINI.md`, `.gemini/settings.json`, `.geminiignore`); Bus Dev never modifies user-global Gemini configuration or memory. Which agent runtime is used is determined by the agent selection configuration (see below). This subcommand does not perform any Git remote operations.

**`spec`** — Refine only the current module’s Cursor MDC rule file so it accurately reflects the latest BusDK specifications. May be combined with **work** and **e2e** in one invocation (e.g. `bus dev spec work e2e`); operations run in the order given and stop on first failure. The MDC path is `.cursor/rules/<module>.mdc` where `<module>` is the module name (base name of the repository root directory). No source code, tests, or README are changed. If that file does not exist, the command exits with a clear error (exit 2) and does not invoke the agent. The refinement is driven by an embedded prompt inside the binary; the agent may read BusDK docs to align the MDC. When Gemini CLI is selected, repository-local Gemini context is used in parallel; Bus Dev does not write to user-global Gemini config or memory.

**`e2e`** — Guided workflow to detect missing end-to-end tests for the current module and scaffold them in a hermetic way, consistent with BusDK testing conventions and the module’s [SDD](../sdd/bus-dev) and end-user documentation. May be combined with **spec** and **work** in one invocation (e.g. `bus dev spec work e2e`); operations run in the order given and stop on first failure. E2E tests are Bash scripts under `tests/` named `e2e_bus_<name>.sh`, where `<name>` is the module name with the `bus-` prefix stripped (for example `bus-accounts` → `tests/e2e_bus_accounts.sh`). The tool uses the module’s SDD and end-user docs to determine which tests are needed and produces scaffolds that cover the behavior described there. When `PLAN.md` exists at repository root, the workflow reads it first, treats checked items as completed-feature coverage obligations, verifies each checked item is fully covered by e2e tests, and prioritizes unchecked test-related items. It also continues to search SDD and end-user docs for other untested behavior exactly as it does without `PLAN.md`. This subcommand does not remove already checked plan items; checked-item pruning is handled by `bus dev plan`. The command does not perform remote Git operations or modify workspace accounting datasets.

### Global flags

These flags apply to all subcommands. The common subset matches the [standard global flags](../cli/global-flags); `bus dev` adds `--agent` for runtime selection. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

- **`-h`**, **`--help`** — Print help to stdout and exit 0. Other flags and arguments are ignored when help is requested.
- **`-V`**, **`--version`** — Print the tool name and version to stdout and exit 0.
- **`-v`**, **`--verbose`** — Send verbose progress and diagnostics to stderr. You can repeat the flag (e.g. `-vv`) to increase verbosity. Verbose output does not change what is written to stdout.
- **`-q`**, **`--quiet`** — Suppress normal command result output. When quiet is set, only errors go to stderr. Exit codes are unchanged. You cannot combine `--quiet` with `--verbose`; doing so is invalid usage (exit 2).
- **`-C <dir>`**, **`--chdir <dir>`** — Use `<dir>` as the effective working directory. The repository root and all paths are resolved from this directory. If it does not exist or is not accessible, the command exits with code 1. If the effective directory is not inside a Git repository, subcommands that require a repo exit with code 2 and a clear message.
- **`-o <file>`**, **`--output <file>`** — Redirect normal command output to `<file>` instead of stdout. The file is created or truncated. Errors and diagnostics still go to stderr. If both `--output` and `--quiet` are used, quiet wins: no output is written to the file.
- **`--color <mode>`** — Control colored output on stderr. `<mode>` must be `auto`, `always`, or `never`. Invalid value is usage error (exit 2).
- **`--no-color`** — Same as `--color=never`.
- **`--agent <runtime>`** — Select the agent runtime for this invocation only. `<runtime>` must be one of `cursor`, `codex`, `gemini`, or `claude`. Invalid value is usage error (exit 2). This overrides the default set by the `BUS_DEV_AGENT` environment variable (see Agent runtime selection below).

Command results are written to stdout when a subcommand produces them. Diagnostics, progress, and human-readable agent output are written to stderr.

### Agent runtime selection

Subcommands that invoke an external agent (`plan`, `work`, `spec`, and `e2e`, including when these are requested after `init`) use the [bus-agent](../sdd/bus-agent) library and one of its supported runtimes: **Cursor CLI**, **Codex**, **Gemini CLI**, and **Claude CLI**. At the start of each such step, the tool prints to stderr which internal agent and which model are in use so that logs and scripts can see the active runtime and model.

The active runtime is chosen as follows. The `--agent <runtime>` flag for that invocation overrides everything else. If no flag is given, the session-stored preference **`BUS_DEV_AGENT`** applies when set (e.g. `export BUS_DEV_AGENT=codex`); that value is used as the default for every `bus dev` command in that session until the variable is unset or changed. When neither flag nor session preference is set, the tool uses the automatic default from the [bus-agent](../sdd/bus-agent) library: the set of available runtimes (those whose CLI exists in PATH, minus any user-disabled or restricted to user-enabled when configured) is considered, and the first in the effective order is chosen. By default that order is alphabetical by runtime ID (e.g. claude, codex, cursor, gemini). You can configure which agent is used first by setting an agent order, and you can disable or enable specific agents so that only certain runtimes are available; see the [bus-agent](../sdd/bus-agent) SDD and module docs for the exact environment variables or config.

Invalid runtime names (e.g. `--agent unknown` or an invalid value in `BUS_DEV_AGENT`) produce a clear usage error and exit 2. If the user has selected an agent (via flag or `BUS_DEV_AGENT`) and that agent’s CLI is not installed or not in PATH, the tool reports that on stderr, directs you to the canonical installation URL for that runtime, and exits with code 1. When no runtime is selected and no agent is available (none in PATH or all disabled/restricted), the tool exits with a clear diagnostic and directs you to install or enable at least one supported agent, with pointers to the canonical installation URLs for each runtime. Model, output format, and timeout for the agent are configurable via the runtime’s own environment variables or flags (documented by each runtime).

### Example: building a module from scratch with AI

BusDK specifications are openly readable. You can have an AI-assisted workflow build a bus module from scratch, then optionally initialize Git and commit. Prerequisites: install one of the supported agent runtimes (Cursor CLI, Codex, Gemini CLI, or Claude CLI), BusDK (at least v0.0.15), and Go.

**Option: initialize only, then run workflows explicitly.** From the module root you want to initialize, run `bus dev init [--lang go]`. Or from a parent directory, run `bus dev init bus-accounts [--lang go]`. The tool initializes `.cursor/rules`, the module MDC, and a root `Makefile` (from a built-in sample when missing). It does not run any Git commands and does not run `spec`, `work`, or `e2e` unless you ask for them. After initialization, run `bus dev plan` to refresh `PLAN.md`, then run `bus dev spec work e2e` in that module directory when you want the AI workflow sequence.

**Option: initialize and run ordered workflows in one command.** If you want initialization plus workflow operations in one invocation, append the operations after init. `bus dev init spec work e2e` initializes the current directory and runs the three operations in that exact order. `bus dev init bus-accounts spec work e2e` does the same in `bus-accounts`. If one operation fails, later operations are not run.

**Option: manual steps.** If you prefer to create everything yourself, create the module directory, `.cursor/rules`, the MDC file, and a root `Makefile`, then run `bus dev spec work e2e` (or the three operations in separate invocations), then initialize Git and commit as desired. The `--lang` flag on `init` (default `go`) controls which default MDC content is installed when you use init instead of creating files manually.

Because the specs are public and machine-readable, this flow lets you regenerate or rewrite any bus module from scratch with AI, without depending on pre-packaged source. If you prefer not to build from specs yourself, we offer tested and verified bus module source code for a fee. We also offer compiled binaries for free.

### Files

`bus dev` does not read or write workspace accounting datasets (CSV, schemas, datapackage.json). It operates on the Git repository (metadata and index) and, when running the agent, on the repository working tree (source files, `.cursor/rules/*.mdc`). It also uses repository-root `PLAN.md` for planning continuity: `bus dev work` checks off completed plan items, `bus dev e2e` validates that checked items are fully covered by e2e tests and still searches docs for other missing tests, and neither `work` nor `e2e` removes checked items. `bus dev plan` is the command that re-validates the plan and prunes completed checked items while adding newly detected missing work. When Gemini CLI is selected, the tool uses only repository-local Gemini files (e.g. repo-root `GEMINI.md`, `.gemini/settings.json`, `.geminiignore`) and never modifies user-global Gemini configuration or memory. No bus-dev-specific config file is required; configuration is via flags and environment only.

### Exit status and errors

- **0** — Success. For `bus dev commit`, “nothing to commit” is success.
- **1** — Execution failure: Git command failed, hook failed, agent failed or timed out, selected agent runtime not found or not executable, or no agent enabled when the automatic default would apply.
- **2** — Invalid usage: unknown subcommand, invalid flag (including invalid `--agent` runtime name), or precondition not met (e.g. not in a Git repository for commands that require one, MDC file missing for `bus dev spec`, or init target path is not a directory).

Error messages are always on stderr. If you are not in a Git repository when a subcommand requires one, the tool exits with code 2 and a clear message. If the selected agent runtime is missing or cannot be executed, or if no agent is enabled when the automatic default would apply, the tool exits with code 1 and directs you to the canonical installation URLs for the supported runtimes.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-agent">bus-agent</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK — installation and overview](https://busdk.com/)
- [Module SDD: bus-agent](../sdd/bus-agent)
- [Module SDD: bus-dev](../sdd/bus-dev)
- [CLI: Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Implementation: Module repository structure and dependency rules](../implementation/module-repository-structure)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)
