## bus-dev

### Introduction and Overview

Bus Dev is a developer-only companion module that centralizes the workflow logic currently duplicated under `scripts/` in each BusDK module repository. It provides a single entry point for commit workflows, agent-runner workflows, MDC rule refinement, and end-to-end test scaffolding, so module repositories can rely on `bus dev` instead of copying and maintaining per-repo scripts.

The problem it solves is duplication and drift: each BusDK module today may ship its own `scripts/commit.sh`, `scripts/work.sh`, `scripts/refine-mdc-spec.sh`, and `scripts/e2e.sh` (or equivalents), with slightly different behavior and prompts. Bus Dev consolidates that logic into one binary, `bus-dev`, invoked through the dispatcher as `bus dev …`, with embedded prompts and deterministic behavior.

Scope and boundaries are unambiguous. Bus Dev operates on source code repositories and developer workflows only. It does not operate on accounting datasets, workspace CSV, or schemas. It is not part of the end-user bookkeeping command surface. End users running `bus accounts`, `bus journal`, or `bus validate` never need `bus dev`; it exists for contributors and automation that work inside BusDK module Git repositories.

This module is an explicit exception to the BusDK-wide non-goal NG-001: "BusDK does not execute Git commands or commit changes." That non-goal applies to the accounting and workspace toolchain. Bus Dev is isolated to developer tooling and enforces strict safety constraints: no remote Git operations (no push, pull, fetch, clone, or submodule update that contacts a remote), no history rewriting (no amend, rebase, or squash), deterministic behavior, and clear diagnostics. The exception is justified by isolating Git use to a single, well-defined developer-only module and by making the constraints normative in this SDD.

The intended users are developers and automation (including AI agents) working inside a BusDK module repository. The document’s purpose is to serve as the single source of truth for implementation and review; the audience includes human reviewers and implementation agents.

Out of scope for this SDD: implementing accounting logic, modifying workspace datasets, providing end-user CLI commands for bookkeeping, and any workflow that pushes to or pulls from a remote.

### Goals

G-DEV-001 Centralize developer workflow logic. Replace per-repo scripts with a single `bus dev` command set so behavior and prompts are consistent and maintainable in one place.

G-DEV-002 Developer-only, repository-scoped operations. All operations run in the context of the current working directory as a Git repository and affect only source code, Cursor rules, and developer artifacts — never workspace datasets or end-user data.

G-DEV-003 Safety and determinism. No remote Git operations, no history rewriting, and deterministic output and exit codes so scripts and CI can rely on `bus dev` behavior.

G-DEV-004 Agent-friendly integration. Subcommands that invoke an external agent runtime (e.g. cursor-agent) use embedded prompts, consistent defaults for model and timeout, and a well-defined contract for stdout/stderr and exit codes.

G-DEV-005 One-command module scaffold. A single subcommand (`bus dev init bus-NAME`) MUST create the directory and Cursor rules layout for a new module and run the spec → work → e2e sequence there, without performing any Git operations, so contributors can scaffold and implement a module from BusDK specs in one go; language selection (e.g. `--lang go`) controls which default MDC content is installed for future multi-language support.

### Non-goals

NG-DEV-001 Bus Dev does not perform remote Git operations. Push, pull, fetch, clone, submodule update/init that contacts a remote, or any operation that could contact a remote is out of scope and must never be implemented.

NG-DEV-002 Bus Dev does not rewrite history. Amend, rebase, squash, or any operation that changes existing commit SHAs is out of scope.

NG-DEV-003 Bus Dev does not operate on workspace accounting datasets. Reading or writing workspace CSV, schemas, or datapackage.json for bookkeeping purposes is out of scope; that remains the domain of other BusDK modules.

NG-DEV-004 Bus Dev does not replace the bus dispatcher or module discovery. It is one module among many; the dispatcher continues to route `bus dev …` to the `bus-dev` binary.

### Requirements

FR-DEV-001 CLI integration and naming. The binary MUST be named `bus-dev` and MUST be invoked through the dispatcher as `bus dev <subcommand> [args]`. Acceptance criteria: the dispatcher routes `bus dev init`, `bus dev commit`, `bus dev work`, `bus dev spec`, and `bus dev e2e` to the same binary with the subcommand as the first positional argument.

FR-DEV-002 Repository discovery. The tool MUST determine the current working repository from the effective working directory (after applying `-C`/`--chdir` if present). It MUST NOT require configuration files or environment variables to locate the repo. Acceptance criteria: when run from inside a Git repository root or any subdirectory, the tool uses that repository as the scope for all operations; when the effective working directory is not a Git repository, the tool exits with a clear diagnostic and a non-zero exit code.

FR-DEV-003 Module identity for spec and e2e. When a subcommand needs the current module name (e.g. for MDC path or docs URLs), the tool MUST derive it deterministically from the repository (e.g. the directory name of the repo root or a single canonical file). Acceptance criteria: the same repo always yields the same module name; the SDD or implementation defines the exact derivation rule so behavior is consistent across repos.

FR-DEV-004 Embedded prompts. All prompts used to drive agent runs MUST be embedded as Go string constants or templates inside the bus-dev binary. The tool MUST NOT load prompts from external prompt files on disk. Acceptance criteria: a fresh clone of the bus-dev repo builds a binary that runs all subcommands without requiring any external prompt files; prompts may still be overridden or extended by flags or environment variables when explicitly documented.

FR-DEV-005 Agent runner abstraction. The implementation MUST provide a small internal "agent runner" abstraction that invokes the external agent runtime (e.g. cursor-agent) with consistent defaults for model selection, output format, and timeouts. Acceptance criteria: model, output format, and timeout are configurable via flags or environment variables; defaults are documented and deterministic; the runner is testable in isolation (e.g. by stubbing the executable in PATH).

FR-DEV-006 Commit subcommand behavior. The `bus dev commit` subcommand MUST implement behavior equivalent to the normative commit workflow specified in the Command Surface section below, including: do nothing and exit success when there is nothing staged (or working tree clean in the staged-set sense); operate strictly on the Git index; no file modification, no staging, no amend/rebase, no remote operations; depth-first submodule commits when submodules have staged changes; clear report and stop when a submodule commit causes an unstaged gitlink in the superproject; and enforce the commit message quality rules, atomicity guidance, and failure/hook handling rules as normative requirements. Acceptance criteria: the SDD defines these rules; the implementation enforces them; tests verify behavior with a fixture repo (including submodules when applicable).

FR-DEV-007 Work subcommand behavior. The `bus dev work` subcommand MUST implement the canonical "do the work in this repo now" agent-runner workflow equivalent to the provided work script: operate only inside the current module repository, follow the module’s Cursor rules and design docs, implement concrete code changes, add tests, run the Makefile checks, and update README.md before finishing. The agent MUST be allowed to read the repository’s own docs and Cursor rules as the authoritative specs for that repo. Acceptance criteria: the workflow is driven by an embedded prompt template; no external prompt file is required; behavior is documented and testable via a stubbed agent.

FR-DEV-008 Spec subcommand behavior. The `bus dev spec` subcommand MUST refine only the current repository’s Cursor MDC rule file and nothing else, equivalent to the provided refine-mdc-spec script. The tool MUST locate the current module’s MDC file deterministically (e.g. `.cursor/rules/<module>.mdc`), MUST fail with a clear non-zero error if that file does not exist, and MUST run an embedded refinement prompt that instructs the agent to update only that MDC file and to align it with the latest BusDK specs. Acceptance criteria: no refinement of source code, tests, or README; the MDC path is derived from module identity; missing MDC exits non-zero with a clear message.

FR-DEV-009 E2E subcommand behavior. The `bus dev e2e` subcommand MUST provide a guided workflow to detect missing end-to-end tests for the current module repository and scaffold them in a hermetic way, consistent with BusDK testing conventions and the module’s SDD/CLI reference. The SDD MUST define the minimum intended behavior, acceptance criteria, safety constraints, and a deterministic interface; if implementation details are not yet decided, the SDD MUST identify dependencies and open design questions without blocking the document. Acceptance criteria: at minimum, the command has a defined purpose, preconditions, and what it must not do; extension path for fuller implementation is documented.

FR-DEV-010 Init subcommand behavior. The `bus dev init bus-NAME [--lang go]` subcommand MUST scaffold a new module directory and run the full build-from-spec workflow without performing any Git operations. Behavior MUST be equivalent to: (1) create `bus-NAME/.cursor/rules`; (2) create or install the MDC file at `bus-NAME/.cursor/rules/bus-NAME.mdc` (content or defaults MAY depend on `--lang`); (3) set the effective working directory to `bus-NAME` and run `bus dev spec`, then `bus dev work`, then `bus dev e2e` in that order. The `--lang` flag MUST default to `go` and MUST control which kind of MDC defaults or content the tool installs so that modules for different programming languages can be scaffolded. If the target directory `bus-NAME` already exists, the tool MUST exit with a clear error (exit 2). If any of the steps (mkdir, touch/install MDC, spec, work, e2e) fails, the tool MUST exit with a non-zero code and a clear diagnostic. Acceptance criteria: no Git commands are executed; the same sequence as the manual from-scratch flow is performed except Git; `--lang` is documented and affects installed MDC content; tests verify scaffold layout and optional stub of downstream subcommands.

NFR-DEV-001 Determinism. Output and exit codes MUST be deterministic for the same inputs and repository state. Acceptance criteria: repeated runs with the same staged set and same repo state yield the same exit code and consistent diagnostics.

NFR-DEV-002 No remote operations. The implementation MUST NOT perform any Git operation that contacts a remote. Acceptance criteria: no code path may call push, pull, fetch, clone, or submodule update/init in a way that touches a remote; tests and code review can verify this.

NFR-DEV-003 Hermetic tests. Tests MUST be hermetic: no network, no real external services, no reliance on a real cursor-agent or remote. Acceptance criteria: unit tests and fixture-based tests run in CI without network; agent invocation is tested by stubbing the agent binary in PATH and feeding deterministic NDJSON or output to exercise parsing, filtering, and error handling.

NFR-DEV-004 Cross-platform. Behavior and tests MUST be defined so they can run on Linux and macOS in line with the project’s CI. Acceptance criteria: no OS-specific assumptions are left unspecified; where behavior differs by platform, it is documented.

### System Architecture

Bus Dev is a thin CLI that delegates to testable packages. The main entrypoint is `Run(args, workdir, stdout, stderr) int`; the `main` package calls it and exits with its return value. No `os.Exit` is used outside `main`, so behavior is testable without process exit.

High-level components:

- **CLI layer.** Parses global flags (including BusDK-standard `-C`, `-o`, `-v`, `-q`, `--help`, `--version`) and the `bus dev` subcommand, resolves the effective working directory, and delegates to the appropriate subcommand handler.

- **Repository and module resolution.** A small package (or internal function set) that, given a workdir, detects whether it is inside a Git repository, finds the repository root, and derives the module name when needed (e.g. for `bus dev spec` and `bus dev e2e`). This layer does not perform any Git write operations; it only reads repository metadata.

- **Agent runner.** An internal abstraction that builds the command line for the external agent (e.g. cursor-agent), sets environment variables, applies timeout, and optionally pipes the agent’s stdout through a log formatter (e.g. NDJSON-to-text). The runner is configured by flags or environment (model, output format, timeout) and is designed so tests can substitute a stub binary that writes deterministic NDJSON to stdout and exits with a chosen code.

- **Subcommand handlers.** One logical component per subcommand: init, commit, work, spec, e2e. Each handler receives parsed flags, the resolved workdir (and repo root and module name when relevant), and stdout/stderr writers, and returns an exit code. Init creates the module directory and MDC, then invokes spec, work, and e2e in sequence without performing Git operations. Commit may use Git only for read operations plus `git commit` with already-staged content; it must not stage, amend, or touch remotes.

- **Embedded prompts.** Prompts for commit, work, spec, and (when applicable) e2e are compiled into the binary as string constants or templates. Template variables (e.g. module name, MDC path) are filled at runtime from the repository resolution layer. No prompts are loaded from the filesystem.

- **Log formatting (optional).** The NDJSON-to-text style formatter (equivalent to the provided format-cursor-log / ndjson-to-text behavior) may be implemented as an internal library used by the agent runner to convert agent NDJSON output to human-readable text on stderr. The SDD treats this as the desired direction; whether it is a separate subcommand or only internal is left as an implementation detail, with the initial scope kept minimal and deterministic.

Data flow: user invokes `bus dev <subcommand>`; dispatcher runs `bus-dev <subcommand> [args]`; CLI parses args and workdir; repo resolution checks Git repo and optionally module name; subcommand handler runs (either Git + agent for commit, or agent-only for work/spec, or scaffold/detect for e2e); agent runner, when used, invokes external binary with embedded prompt and pipes output through formatter; all diagnostics to stderr, deterministic result/exit code.

### Key Decisions

KD-DEV-001 Git exception scoped to bus-dev. BusDK’s NG-001 (no Git execution) is relaxed only for the bus-dev module, and only for local, non-remote, non-rewriting operations, to support developer workflows without embedding Git logic in every other module.

KD-DEV-002 Prompts embedded in binary. Prompts are not loaded from the repository or from external files so that behavior is versioned with the binary and consistent across all module repos that use the same bus-dev version.

KD-DEV-003 Agent runtime is external. The tool invokes an external agent (e.g. cursor-agent) rather than embedding an LLM client; this keeps the binary small and allows the same workflow to work with different agent runtimes via configuration.

KD-DEV-004 Thin CLI, testable core. The CLI parses arguments and delegates to packages that take workdir and I/O writers; `Run(...) int` allows full unit and integration tests without spawning processes or calling `os.Exit`.

### Component Design and Interfaces

Interface IF-DEV-001 (dispatcher). The `bus` dispatcher invokes the `bus-dev` binary with the first argument after `dev` as the subcommand (e.g. `init`, `commit`, `work`, `spec`, `e2e`). For `init`, the second positional argument is the module name (e.g. `bus-accounts`). Standard global flags (`-C`, `-o`, `-v`, `-q`, `--help`, `--version`, etc.) follow BusDK CLI conventions; see traceability links.

Interface IF-DEV-002 (Run entrypoint). The program exposes a single entrypoint `Run(args []string, workdir string, stdout, stderr io.Writer) int`. `main` passes `os.Args[1:]`, the effective working directory (from `-C` or current process), `os.Stdout`, and `os.Stderr`, and exits with the returned code. No other package calls `os.Exit`.

Interface IF-DEV-003 (agent runner). The agent runner abstraction accepts: prompt text (or template + variables), model, output format, timeout, and optional filter options (e.g. roles to include). It returns an exit code and optionally streams formatted output to the provided stderr. It executes the external agent binary (e.g. cursor-agent) in the given workdir with the given environment. Tests may inject a stub by changing PATH or by accepting an optional executable path for the runner.

Interface IF-DEV-004 (repo resolution). Given a directory path, the resolver returns: whether the path is inside a Git repository, the repository root path, and (when requested) the module name. Module name MUST be derived deterministically (e.g. base name of repository root directory). If not inside a repo, the resolver returns an error suitable for a clear user-facing message.

### Command Surface

**Invocation.** All subcommands are invoked as `bus dev <subcommand> [options]`. Global flags apply as per BusDK CLI conventions.

**`bus dev init bus-NAME [--lang go]`**

Intent: Scaffold a new BusDK module directory and run the spec → work → e2e workflow so the user gets a fully scaffolded and agent-implemented module without performing any Git operations. The user may run `git init` and `bus dev commit` afterward when ready to version the result.

Preconditions: Invoked from the parent directory where the new module should appear. The target path `bus-NAME` must not already exist (e.g. must not be an existing directory). The effective working directory need not be a Git repository. Agent runtime (e.g. cursor-agent) and BusDK/Go are required for the spec/work/e2e steps to succeed.

Reads: BusDK documentation and embedded prompts when running spec/work/e2e. No workspace datasets.

Writes: Creates `bus-NAME/.cursor/rules` and `bus-NAME/.cursor/rules/bus-NAME.mdc` (content or defaults determined by `--lang`; default `go`). Then, with effective working directory set to `bus-NAME`, invokes `bus dev spec`, `bus dev work`, and `bus dev e2e` in order; those subcommands write under `bus-NAME` as specified in their own command surface.

Allowed mutations: Creating the new directory tree, the initial MDC file, and whatever spec/work/e2e produce under `bus-NAME`. No mutations outside `bus-NAME`. No Git operations.

Must never do: Run any Git command (no `git init`, no add, no commit). Create or modify anything outside the new `bus-NAME` directory (except stderr and any documented stdout). If `bus-NAME` already exists, the tool MUST exit with code 2 and a clear message without creating or modifying anything.

Language flag: `--lang` defaults to `go`. It controls which default or language-specific MDC content the tool installs at `bus-NAME/.cursor/rules/bus-NAME.mdc`, so that init can be used to scaffold modules for different programming languages. The set of supported values and their exact effect on installed content is implementation-defined and MUST be documented in the CLI reference.

**`bus dev commit`**

Intent: Create one or more commits from the currently staged changes only, with high-quality messages and strict safety rules, without touching remotes or history.

Preconditions: Effective working directory is the root of a Git repository (or a subdirectory of one). Optional: repository may contain submodules.

Reads: Git index and repository metadata (e.g. `git status`, `git diff --cached`). Does not read workspace datasets or accounting files for bookkeeping.

Writes: Only new commits created from the existing staging area (via `git commit`). Does not write to working tree files, does not create or modify files outside Git’s normal commit operation.

Allowed mutations: Creating new commit(s) from already-staged content. Committing in submodules first (depth-first), then the superproject only if it has staged changes. No other mutations.

Must never do: Modify files; stage anything (`git add`); amend, rebase, or rewrite history; push, pull, fetch, clone, or any remote operation; run hooks that are not the standard Git commit hooks (the tool may run `git commit`, which may run commit-msg/pre-commit etc.; the tool must not bypass or suppress hooks).

Behavior when nothing to commit: If there is nothing staged (and no staged changes in submodules that need committing), the command does nothing and exits with code 0. No commit is created, no error.

Submodules: If the repository has submodules and a submodule has staged changes, commit inside that submodule first (recursively depth-first). After all submodules with staged changes are committed, if the superproject has staged changes (including gitlink updates), commit the superproject. If a submodule commit resulted in an unstaged gitlink change in the superproject, the tool MUST report that clearly (e.g. to stderr) and STOP without staging that gitlink; the user must stage it manually if desired.

Commit message quality (normative): For every commit, the message MUST have a concise, action-oriented subject line in the imperative mood. A body MAY follow, separated by a blank line. The message SHOULD explain what changed and why, mention user-visible impact or risk when relevant, and include traceability (issue IDs or URLs) when helpful. Vague summaries are not acceptable. Conventional prefixes (feat, fix, docs, refactor, test, chore) MAY be used when they improve clarity but MUST NOT replace a precise subject.

Atomicity: Before creating each commit, the implementation (or the agent it invokes) MUST review the staged set at a high level. If the staged set contains multiple logical changes, the implementation/agent MUST propose an atomic commit split plan. By default, the tool commits exactly what is currently staged and MUST NOT alter the staging area to perform a split unless explicitly instructed.

Failures and hooks: If a commit is rejected by hooks (e.g. pre-commit, commit-msg), the tool MUST report the exact failure reason and output and suggest the minimal correction. The tool MUST NOT retry the commit automatically unless explicitly instructed.

**`bus dev work`**

Intent: Run the canonical "do the work in this repo now" agent workflow: implement code changes, add/update tests, run Makefile checks, and update README in the current module repository, following the module’s Cursor rules and design docs.

Preconditions: Effective working directory is inside a BusDK module Git repository. The repository contains Cursor rules and design docs that the agent will read.

Reads: Repository source code, `.cursor/rules/*.mdc`, design docs (e.g. SDD, CLI reference) as referenced by the rules. The agent is allowed to read these as the authoritative specs.

Writes: Determined by the agent under the constraints of the embedded prompt (code, tests, README). The tool itself does not write repository files; it only invokes the agent with the embedded prompt.

Allowed mutations: Whatever the embedded prompt permits (code, tests, README, under the rule that the agent operates only in the current module and follows the module’s rules).

Must never do: Invoke remote Git operations; operate outside the current module repository; change workspace accounting datasets.

Implementation note: The workflow is executed via an embedded prompt template shipped inside bus-dev. The agent runtime reads the repository’s own docs and Cursor rules as part of doing the work; those are the authoritative specs for that repo.

**`bus dev spec`**

Intent: Refine only the current repository’s Cursor MDC rule file so it accurately reflects the latest BusDK specifications; no changes to source code, tests, or README.

Preconditions: Effective working directory is inside a BusDK module Git repository. The module’s MDC file must exist (e.g. `.cursor/rules/<module>.mdc`).

Reads: The current MDC file (subject of refinement), BusDK documentation (as referenced by the embedded prompt). The agent may read the spec pages to align the MDC.

Writes: Only the single MDC file at the deterministic path. No other files.

Allowed mutations: Updating the content of the MDC file only.

Must never do: Modify source code, tests, README, or any file other than the designated MDC file; perform Git operations other than those implied by the user saving the file (if the agent writes the file, the user may then commit).

Module MDC path: The tool MUST locate the MDC file deterministically. The SDD specifies the rule: e.g. `.cursor/rules/<module>.mdc` where `<module>` is the derived module name (e.g. base name of repo root). If the file does not exist, the tool MUST exit with a clear non-zero error and MUST NOT invoke the agent.

**`bus dev e2e`**

Intent (minimum): Guided workflow to detect missing end-to-end tests for the current module and scaffold them in a hermetic way, consistent with BusDK testing conventions and the module’s SDD/CLI reference.

Preconditions: Effective working directory is inside a BusDK module Git repository. Further preconditions may be defined as the feature is implemented.

Reads: Repository layout, existing tests, module SDD/CLI reference (or links thereto) to align scaffold with conventions.

Writes: New or updated test files and scaffolding only; no modification of production code beyond what is required for testability when that is part of the defined e2e workflow.

Allowed mutations: Adding or updating test artifacts and scaffolding as defined by the subcommand’s acceptance criteria.

Must never do: Remote Git operations; history rewriting; modifying workspace accounting datasets; non-hermetic or network-dependent test scaffolding.

Extension path: The SDD defines the minimal interface and safety constraints. Fuller behavior (e.g. which test framework, how "missing" is detected, exact scaffold layout) may be refined in a later revision or open questions. Dependencies (e.g. Makefile contract, test directory layout) and open design questions MUST be documented so the command remains implementable without guesswork.

### I/O Conventions

Standard output: Reserved for deterministic, machine-readable command results when a subcommand produces them. For subcommands that only invoke an agent and stream human-readable output, stdout may be unused or used for a final success message in a documented format.

Standard error: All diagnostics, progress, and human-readable agent output (e.g. NDJSON formatted to text) MUST go to stderr. This preserves the BusDK convention that stdout is for results and stderr for diagnostics.

When an external agent is invoked, the agent’s raw output (e.g. NDJSON) may be piped through an internal formatter that writes readable text to stderr. The tool MUST NOT inject color or control sequences into stdout when the output is intended to be machine-readable.

Determinism: Given the same repository state, same staged set, and same flags, the tool MUST produce the same exit code and consistent stderr output (up to timing or non-deterministic agent output when an agent is used; the tool’s own messages and exit code must still be deterministic for the "no agent" and "stub agent" cases).

### Exit Codes

- 0: Success. For `bus dev commit`, "nothing to commit" is success (0).
- 1: Execution failure (e.g. Git command failed, hook failed, agent exited with error, timeout).
- 2: Invalid usage (e.g. unknown subcommand, invalid flag, missing required argument, or precondition not met in a way that is usage-related — e.g. not in a Git repo, or MDC file missing for `bus dev spec`).

The distinction between invalid usage (2) and execution failure (1) follows BusDK CLI conventions: usage errors are 2; failures during an otherwise valid invocation are 1.

### Error Handling and Resilience

- **cursor-agent not installed or not in PATH:** The tool MUST detect failure to start the agent (e.g. exec error) and MUST exit with a clear diagnostic to stderr and a non-zero exit code (1). Message MUST indicate that the agent runtime could not be found or executed.
- **git not installed or not in PATH:** When a subcommand needs Git, the tool MUST detect failure to run `git` and MUST exit with a clear diagnostic and non-zero exit code (1).
- **Working directory not a Git repo:** For subcommands that require a Git repository (commit, work, spec, e2e when run standalone), exit with code 2 and a clear message. For `bus dev init`, the effective working directory need not be a Git repository; the target directory `bus-NAME` must not already exist (exit 2 if it does).
- **No staged changes (commit):** Exit 0 and do nothing; optionally print a short message to stderr that there was nothing to commit.
- **Hooks fail (commit):** Exit 1 and report the hook failure output; do not retry.
- **Timeouts (agent subcommands):** When the agent runner applies a timeout and the agent exceeds it, the tool MUST exit with a non-zero code (1) and MUST report that the run timed out.

All error messages MUST be written to stderr. The tool MUST NOT crash or exit with an ambiguous code when the above conditions occur; behavior MUST be as specified.

### Data Design

Bus Dev does not own or read workspace datasets (CSV, schemas, datapackage.json) for bookkeeping. It operates on:

- The Git repository (metadata and index) for the current working directory.
- The repository’s working tree (source files, `.cursor/rules/*.mdc`) when the agent is run, so the agent can read and optionally write files under the repo.
- No persistent data store beyond what Git and the filesystem provide. Configuration is via flags and environment variables only; no bus-dev-specific config file is required.

### Assumptions and Dependencies

AD-DEV-001 Git is available. The commit workflow and repository resolution depend on `git` being in PATH and the repository being a valid Git repo. If Git is missing or the directory is not a repo, the tool fails with a clear error.

AD-DEV-002 Agent runtime availability. Subcommands that invoke an agent (commit, work, spec, and possibly e2e) require the configured agent binary (e.g. cursor-agent) to be installed and in PATH when those subcommands are run. If the agent is missing, the tool reports that and exits non-zero; it does not fall back to a different implementation.

AD-DEV-003 Repository layout. For `bus dev spec`, the module’s MDC file is assumed to live at `.cursor/rules/<module>.mdc` where `<module>` is derived from the repo (e.g. base name of repo root). If the project adopts a different convention, this assumption will be updated in the SDD.

AD-DEV-004 Operating environment. Same as BusDK: Linux and macOS. Tests and behavior are defined for these environments; Windows is out of scope unless otherwise stated.

### Testing Strategy

- **Unit tests.** All library-style code (repo resolution, argument parsing, prompt template expansion, agent runner with stub) MUST have unit tests. Tests MUST be hermetic: no network, no real Git remotes, no real agent.

- **Fixture repository.** At least one end-to-end style test MUST use a fixture Git repository in a temporary directory (e.g. a repo with a few commits and optionally a submodule) to verify commit behavior: nothing to commit exits 0, staged change leads to commit with message, submodule ordering, unstaged gitlink handling, etc. This test MUST not push or pull; it may run `git commit` only.

- **Agent runner tests.** When the agent is involved, the test strategy MUST stub the agent binary in PATH (or inject a fake path). The stub MUST feed deterministic NDJSON (or plain output) to stdout and exit with a chosen code so that parsing, filtering, and error handling are exercised without calling a real agent or network.

- **Definition of Done.** For any implementation of this SDD, the following are required: unit tests for the new or touched code paths, at least one end-to-end style test using a fixture repo as above, and README updates that document the subcommands and link to this SDD and the canonical BusDK design spec where relevant.

### Traceability to BusDK Spec

This module intentionally deviates from the following BusDK design spec elements, and is constrained by the following:

- **NG-001 (BusDK does not execute Git commands).** Bus Dev is the defined exception: it may run local Git commands (status, diff, commit) under the strict constraints in this SDD (no remote, no history rewrite, no staging). Rationale: developer workflow centralization without putting Git into every module.

- **CLI conventions.** Bus Dev follows the same global CLI conventions as other modules (e.g. [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics), [Command structure and discoverability](../cli/command-structure)) for flags, stdout/stderr, and exit codes. Where it invokes an external agent, it still obeys the convention that machine-readable output (if any) is on stdout and diagnostics on stderr.

- **Module structure.** Bus Dev is implemented as a library-first, thin-CLI module consistent with [Module repository structure and dependency rules](../implementation/module-repository-structure) and [Independent modules](../architecture/independent-modules); it does not call other `bus-*` CLIs as internal APIs.

- **Testing.** The testing strategy aligns with the BusDK [Testing strategy](../testing/testing-strategy): hermetic, no network, deterministic, and with command-level or fixture-based tests where appropriate.

The most relevant BusDK spec pages for implementors are: the [BusDK Software Design Document (SDD)](../sdd) (goals and non-goals, especially NG-001), [CLI tooling and workflow](../cli/index), [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics), [Module repository structure and dependency rules](../implementation/module-repository-structure), and [Testing strategy](../testing/testing-strategy).

### Glossary and Terminology

- **Staging area / Git index:** The set of changes that have been `git add`ed and will be included in the next `git commit`. Bus Dev commit operates only on this set; it does not add or remove from it.
- **Gitlink:** The Git submodule pointer (commit SHA) stored in the superproject tree for a submodule. When you commit inside a submodule, the superproject’s view of that submodule becomes an unstaged gitlink change until the user stages it.
- **MDC file:** A Cursor rule file in Markdown with optional frontmatter (e.g. `.cursor/rules/<name>.mdc`). Bus Dev spec refines exactly one such file per run. Init creates an initial MDC file whose default content may depend on `--lang`.
- **Agent runner:** The internal abstraction that invokes the external agent binary (e.g. cursor-agent) with a prompt, timeout, and output formatting.
- **Embedded prompt:** A prompt string or template compiled into the bus-dev binary, not loaded from the filesystem.

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./bus-data">bus-data</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">SDD index</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-bfl">bus-bfl</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [BusDK Software Design Document (SDD)](../sdd)
- [CLI tooling and workflow](../cli/index)
- [Error handling, dry-run, and diagnostics](../cli/error-handling-dry-run-diagnostics)
- [Module repository structure and dependency rules](../implementation/module-repository-structure)
- [Testing strategy](../testing/testing-strategy)
- [End user documentation: bus-dev CLI reference](../modules/bus-dev)

### Document control

Title: bus-dev module SDD  
Project: BusDK  
Document ID: `BUSDK-MOD-DEV`  
Version: 2026-02-11  
Status: Draft  
Last updated: 2026-02-11  
Owner: BusDK development team  
Changelog: 2026-02-11 — Added `bus dev init bus-NAME [--lang go]` (goal G-DEV-005, requirement FR-DEV-010, command surface, architecture, error handling, glossary).  
