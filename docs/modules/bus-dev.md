## bus-dev

### Name

`bus dev` — developer workflows for BusDK module repositories.

### Synopsis

`bus dev <subcommand> [options]`

`bus dev init bus-NAME [--lang go]` — scaffold a new module directory and run the spec → work → e2e workflow (no Git operations).  
`bus dev commit` — commit staged changes with high-quality messages (no remote, no history rewrite).  
`bus dev work` — run the “do the work in this repo” agent workflow (code, tests, README).  
`bus dev spec` — refine only the current module’s Cursor MDC rule file to align with BusDK specs.  
`bus dev e2e` — guided workflow to detect and scaffold missing end-to-end tests.

### Description

`bus dev` is a developer-only companion. It centralizes workflow logic that module repositories would otherwise duplicate in `scripts/`: module scaffolding, commit workflows, agent-runner workflows, MDC refinement, and e2e test scaffolding. Most subcommands operate on the **current Git repository** (source code and Cursor rules); `bus dev init` is the exception — it creates a new module directory under the current directory and runs the spec/work/e2e sequence there without creating or touching a Git repo. The tool does not operate on workspace accounting datasets. End users running `bus accounts`, `bus journal`, or `bus validate` do not need `bus dev`; it is for contributors and automation working inside (or creating) a BusDK module repo.

All paths and the working directory are resolved relative to the current directory unless you set `-C` / `--chdir`. The tool discovers the repository root from the effective working directory and does not require a config file. Subcommands that need a module name (for example for the MDC path or e2e script naming) derive it from the repository: the module name is the base name of the repository root directory (the last path component of the absolute path to the repo root).

**Safety.** `bus dev` never runs remote Git operations (no push, pull, fetch, clone) and never rewrites history (no amend, rebase, squash). It may run local `git commit` only on already-staged content. Diagnostics and progress go to stderr; stdout is used for deterministic results when a subcommand produces them.

### Commands

**`init bus-NAME [--lang go]`** — Scaffold a new BusDK module and run the full build-from-spec workflow without performing any Git operations. This subcommand does the same steps as the manual from-scratch flow (create directory, Cursor rules layout, then spec, work, e2e), but it does not create or modify a Git repository. You run it from the parent directory where the new module should appear. The tool creates `bus-NAME/.cursor/rules`, places an initial MDC file at `bus-NAME/.cursor/rules/bus-NAME.mdc` (content or defaults depend on `--lang`), then sets the effective working directory to `bus-NAME` and runs `bus dev spec`, `bus dev work`, and `bus dev e2e` in order. The `--lang` flag defaults to `go` and controls which default MDC content the tool installs so you can scaffold modules for different programming languages. If the target directory `bus-NAME` already exists, the tool exits with code 2 and a clear message without creating or modifying anything. If any later step fails, the tool exits with a non-zero code and a clear diagnostic. Use this when you want a one-command scaffold and AI-driven implementation; run `git init` and subsequent `bus dev commit` yourself when you are ready to version the result.

**`commit`** — Create one or more commits from the **currently staged** changes only. If there is nothing staged (and no submodules with staged changes to commit), the command does nothing and exits 0. The tool does not modify files, does not stage anything, and does not amend or rebase. If the repo has submodules, it commits inside submodules first (depth-first), then the superproject only if it has staged changes. If a submodule commit leaves an unstaged gitlink in the superproject, the tool reports that and stops without staging it. Commit messages follow the usual BusDK conventions: concise, imperative subject; optional body; traceability when helpful. If a hook (e.g. pre-commit, commit-msg) fails, the tool reports the failure and exits non-zero; it does not retry.

**`work`** — Run the canonical “do the work in this repo now” workflow. The tool invokes the configured external agent runtime with an embedded prompt that tells it to operate only inside the current module repo: make concrete code changes, add or update tests, run the Makefile checks, and update README before finishing. The agent is allowed to read the repo’s Cursor rules and design docs as the authoritative specs. Which agent runtime is used is determined by the agent selection configuration (see below). This subcommand does not perform any Git remote operations.

**`spec`** — Refine only the current module’s Cursor MDC rule file so it accurately reflects the latest BusDK specifications. The MDC path is `.cursor/rules/<module>.mdc` where `<module>` is the module name (base name of the repository root directory). No source code, tests, or README are changed. If that file does not exist, the command exits with a clear error (exit 2) and does not invoke the agent. The refinement is driven by an embedded prompt inside `bus-dev`; the agent may read BusDK docs to align the MDC.

**`e2e`** — Guided workflow to detect missing end-to-end tests for the current module and scaffold them in a hermetic way, consistent with BusDK testing conventions and the module’s [SDD](../sdd/bus-dev) and end-user documentation. E2E tests are Bash scripts under `tests/` named `e2e_bus_<name>.sh`, where `<name>` is the module name with the `bus-` prefix stripped (for example `bus-accounts` → `tests/e2e_bus_accounts.sh`). The tool uses the module’s SDD and end-user docs to determine which tests are needed and produces scaffolds that cover the behavior described there. The command does not perform remote Git operations or modify workspace accounting data.

### Global flags

These flags apply to all subcommands. They can appear in any order before the subcommand. A lone `--` ends flag parsing; any following tokens are passed to the subcommand.

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

The default agent CLI is configurable via the environment variable **`BUS_DEV_AGENT`**. Set it in your shell (e.g. `export BUS_DEV_AGENT=codex`) to use that runtime as the default for every `bus dev` command in that session until the variable is unset or changed.

Subcommands that invoke an external agent (work, spec, commit, and when used during init or e2e) use one of four supported runtimes: **Cursor CLI**, **Codex**, **Gemini CLI**, and **Claude CLI**. You can override the default for a single run with the `--agent <runtime>` flag (e.g. `bus dev work --agent codex`). Resolution order: the `--agent` flag for that invocation overrides `BUS_DEV_AGENT`; `BUS_DEV_AGENT` (if set) overrides the implementation-defined default. Invalid runtime names (e.g. `--agent unknown` or an invalid value in `BUS_DEV_AGENT`) produce a clear usage error and exit 2.

Model, output format, and timeout for the agent are configurable via the runtime’s own environment variables or flags (documented by each runtime). If the selected agent binary is not installed or not in PATH, the tool reports that on stderr, directs you to the canonical installation URL for that runtime, and exits with code 1.

### Example: building a module from scratch with AI

BusDK specifications are openly readable. You can have an AI-assisted workflow build a bus module from scratch, then optionally initialize Git and commit. Prerequisites: install one of the supported agent runtimes (Cursor CLI, Codex, Gemini CLI, or Claude CLI), BusDK (at least v0.0.15), and Go.

**Option: one-command scaffold.** From the directory where the new module should live, run `bus dev init bus-accounts [--lang go]`. The tool creates `bus-accounts/.cursor/rules`, places the initial MDC file, then runs `bus dev spec`, `bus dev work`, and `bus dev e2e` inside `bus-accounts`. It does not run any Git commands. When the workflow finishes, you can `cd bus-accounts`, run `git init`, stage with `git add .`, and run `bus dev commit` to create the first commits.

**Option: manual steps.** If you prefer to create the layout and Git repo yourself, create the module directory and Cursor rules, then run the dev workflow in order: `mkdir -p bus-accounts/.cursor/rules`; `cd bus-accounts`; `git init`; create or install the MDC at `.cursor/rules/bus-accounts.mdc`; `bus dev spec`; `bus dev work`; `bus dev e2e`; then stage and `bus dev commit`. The `--lang` flag on `init` (default `go`) controls which default MDC content is installed so you can scaffold modules for different programming languages.

Because the specs are public and machine-readable, this flow lets you regenerate or rewrite any bus module from scratch with AI, without depending on pre-packaged source. If you prefer not to build from specs yourself, we offer tested and verified bus module source code for a fee. We also offer compiled binaries for free.

### Files

`bus dev` does not read or write workspace accounting datasets (CSV, schemas, datapackage.json). It operates on the Git repository (metadata and index) and, when running the agent, on the repository working tree (source files, `.cursor/rules/*.mdc`). No bus-dev-specific config file is required; configuration is via flags and environment only.

### Exit status and errors

- **0** — Success. For `bus dev commit`, “nothing to commit” is success.
- **1** — Execution failure: Git command failed, hook failed, agent failed or timed out, or agent runtime not found.
- **2** — Invalid usage: unknown subcommand, invalid flag (including invalid `--agent` runtime name), or precondition not met (e.g. not in a Git repository, MDC file missing for `bus dev spec`, or target directory already exists for `bus dev init`).

Error messages are always on stderr. If you are not in a Git repository when a subcommand requires one, the tool exits with code 2 and a clear message. If the selected agent runtime is missing or cannot be executed, the tool exits with code 1 and directs you to the canonical installation URL for that runtime.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bfl">bus-bfl</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK — installation and overview](https://busdk.com/)
- [Module SDD: bus-dev](../sdd/bus-dev)
- [CLI: Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Implementation: Module repository structure and dependency rules](../implementation/module-repository-structure)
- [Gemini CLI — install](https://geminicli.com/)
- [Cursor CLI — overview and install](https://cursor.com/docs/cli/overview)
- [Claude Code — get started / install](https://github.com/anthropics/claude-code?tab=readme-ov-file#get-started)
- [Codex CLI — install](https://developers.openai.com/codex/cli/)
