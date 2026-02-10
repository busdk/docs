## bus-dev

### Name

`bus dev` — developer workflows for BusDK module repositories.

### Synopsis

`bus dev <subcommand> [options]`

`bus dev commit` — commit staged changes with high-quality messages (no remote, no history rewrite).  
`bus dev work` — run the “do the work in this repo” agent workflow (code, tests, README).  
`bus dev spec` — refine only the current module’s Cursor MDC rule file to align with BusDK specs.  
`bus dev e2e` — guided workflow to detect and scaffold missing end-to-end tests.

### Description

`bus dev` is a developer-only companion. It centralizes workflow logic that module repositories would otherwise duplicate in `scripts/`: commit workflows, agent-runner workflows, MDC refinement, and e2e test scaffolding. It operates on the **current Git repository** (source code and Cursor rules), not on workspace accounting datasets. End users running `bus accounts`, `bus journal`, or `bus validate` do not need `bus dev`; it is for contributors and automation working inside a BusDK module repo.

All paths and the working directory are resolved relative to the current directory unless you set `-C` / `--chdir`. The tool discovers the repository root from the effective working directory and does not require a config file. Subcommands that need a “module name” (e.g. for the MDC path) derive it from the repo (typically the base name of the repository root directory).

**Safety.** `bus dev` never runs remote Git operations (no push, pull, fetch, clone) and never rewrites history (no amend, rebase, squash). It may run local `git commit` only on already-staged content. Diagnostics and progress go to stderr; stdout is used for deterministic results when a subcommand produces them.

### Commands

**`commit`** — Create one or more commits from the **currently staged** changes only. If there is nothing staged (and no submodules with staged changes to commit), the command does nothing and exits 0. The tool does not modify files, does not stage anything, and does not amend or rebase. If the repo has submodules, it commits inside submodules first (depth-first), then the superproject only if it has staged changes. If a submodule commit leaves an unstaged gitlink in the superproject, the tool reports that and stops without staging it. Commit messages follow the usual BusDK conventions: concise, imperative subject; optional body; traceability when helpful. If a hook (e.g. pre-commit, commit-msg) fails, the tool reports the failure and exits non-zero; it does not retry.

**`work`** — Run the canonical “do the work in this repo now” workflow. An external agent (e.g. cursor-agent) is invoked with an embedded prompt that tells it to operate only inside the current module repo: make concrete code changes, add or update tests, run the Makefile checks, and update README before finishing. The agent is allowed to read the repo’s Cursor rules and design docs as the authoritative specs. You can configure model, output format, and timeout via flags or environment variables (see below). This subcommand does not perform any Git remote operations.

**`spec`** — Refine only the current module’s Cursor MDC rule file (e.g. `.cursor/rules/<module>.mdc`) so it accurately reflects the latest BusDK specifications. No source code, tests, or README are changed. The tool locates the MDC file deterministically from the repo’s module name; if that file does not exist, the command exits with a clear error (exit 2) and does not invoke the agent. The refinement is driven by an embedded prompt inside `bus-dev`; the agent may read BusDK docs to align the MDC.

**`e2e`** — Guided workflow to detect missing end-to-end tests for the current module and scaffold them in a hermetic way, consistent with BusDK testing conventions and the module’s SDD/CLI reference. Exact behavior may be extended in later versions; the command does not perform remote Git operations or modify workspace accounting data.

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

Command results are written to stdout when a subcommand produces them. Diagnostics, progress, and human-readable agent output are written to stderr.

### Agent-related options (work, spec, commit)

When a subcommand invokes an external agent (e.g. cursor-agent), you can override defaults with environment variables or (if supported) flags. Typical knobs:

- **Model** — e.g. `CURSOR_AGENT_MODEL=auto` (default) or another model name.
- **Output format** — e.g. `CURSOR_AGENT_OUTPUT_FORMAT=stream-json`.
- **Timeout** — e.g. `CURSOR_AGENT_TIMEOUT=60m` for long runs.

If the agent binary is not installed or not in `PATH`, the tool reports that on stderr and exits with code 1. It does not push, pull, or perform any remote Git operations.

### Example: building a module from scratch with AI

BusDK specifications are openly readable. You can point an AI assistant (for example the [Cursor CLI](https://cursor.com/docs/cli/overview) with cursor-agent) at those specs and have it build a bus module from scratch in a new repository, then refine, test, and commit using `bus dev`. Prerequisites: install cursor-agent, BusDK at least v0.0.15, and Go. Create the module directory and `.cursor/rules`, initialize a Git repository and an empty Cursor rule file so the module name is known, then run the dev workflow in order.

1. Install cursor-agent (so `bus dev work` and `bus dev spec` can invoke it).
2. [Install BusDK](https://busdk.com/).
3. [Install Go](https://go.dev/doc/install).
4. `mkdir -p bus-accounts/.cursor/rules`
5. `cd bus-accounts`
6. `git init`
7. `touch .cursor/rules/bus-accounts.mdc`
8. `bus dev spec` — refine the MDC rule from BusDK specs.
9. `bus dev work` — have the agent implement the module (code, tests, README).
10. `bus dev e2e` — scaffold and run end-to-end tests.
11. `git add .` to stage changes.
12. `bus dev commit` to create commits with good messages.

Because the specs are public and machine-readable, this flow lets you regenerate or rewrite any bus module from scratch with AI, without depending on pre-packaged source. If you prefer not to build from specs yourself, we offer tested and verified bus module source code for a fee. We also offer compiled binaries for free.

### Files

`bus dev` does not read or write workspace accounting datasets (CSV, schemas, datapackage.json). It operates on the Git repository (metadata and index) and, when running the agent, on the repository working tree (source files, `.cursor/rules/*.mdc`). No bus-dev-specific config file is required; configuration is via flags and environment only.

### Exit status and errors

- **0** — Success. For `bus dev commit`, “nothing to commit” is success.
- **1** — Execution failure: Git command failed, hook failed, agent failed or timed out, or agent runtime not found.
- **2** — Invalid usage: unknown subcommand, invalid flag, or precondition not met (e.g. not in a Git repository, or MDC file missing for `bus dev spec`).

Error messages are always on stderr. If you are not in a Git repository when a subcommand requires one, the tool exits with code 2 and a clear message. If the agent runtime (e.g. cursor-agent) is missing, it exits with code 1.

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
