---
title: bus — top-level CLI dispatcher
description: The bus command is the single entrypoint that invokes bus-<command> executables; run bus &lt;command&gt; [args...] to use any module.
---

## bus

### Name

`bus` — top-level CLI dispatcher for BusDK.

### Synopsis

`bus [<command> [args...]]`

With no arguments, `bus` prints usage and available commands to stderr and exits with code 2. With one or more arguments, the first argument is the **command** (subcommand); the dispatcher runs the executable `bus-<command>` from PATH and passes any remaining arguments to it. Standard input, output, and error and the environment are passed through unchanged. The exit code of the child process is the exit code of `bus`.

### Description

Command names follow [CLI command naming](../cli/command-naming). The `bus` binary does not implement domain logic. It delegates every invocation to a module binary: `bus init` runs `bus-init`, `bus accounts add` runs `bus-accounts add`, and so on. All modules are invoked the same way: ensure the `bus` and `bus-<module>` binaries are on your PATH (for example by running `make install` in the BusDK superproject and adding the install directory to PATH), then run `bus <module> [subcommand] [args...]`.

When you run `bus` with no arguments, the dispatcher prints a short usage line and a list of available commands (discovered by scanning PATH for `bus-*` executables) and exits with code 2. When you run `bus <command>` and `bus-<command>` is not found on PATH, the dispatcher prints an error that includes the expected executable name and the same usage and command list, then exits with code 127. For successful invocations, the dispatcher does not consume or modify stdout or stderr; all output comes from the module binary.

There are no global flags consumed by the dispatcher itself. Flags and arguments are passed through to the module; see each module’s page (e.g. [bus init](./bus-init), [bus config](./bus-config)) for the flags and subcommands that module supports.

### Commands

The first argument to `bus` is always the command (module) name. The set of available commands is determined at runtime by the executables named `bus-<command>` found on PATH. Typical commands include `init`, `config`, `accounts`, `journal`, `vat`, `reports`, and others; run `bus` with no arguments to see the full list for your installation.

### Exit status

- **0** — The invoked module completed successfully (child exit 0).
- **1** — The invoked module failed or the dispatcher could not run it (e.g. execution error).
- **2** — Invalid usage: no arguments (no subcommand supplied). Usage and available commands are printed to stderr.
- **127** — Missing subcommand: the requested `bus-<command>` executable was not found on PATH. An error message, usage, and available commands are printed to stderr.

Any other non-zero exit code is the exit code returned by the module binary (e.g. 2 for usage errors in the module).

### Development state

**Value:** Single entrypoint that delegates to `bus-<module>` binaries so users can run one command (`bus <module> …`) to set up or use any module without knowing individual binary names.

**Completeness:** 50% (Primary journey) — no-args and missing-subcommand behavior are verified by unit tests; successful dispatch and exit-code pass-through are tested. The planned behavior when the first argument is `help` and `bus-help` is not on PATH (show usage and exit 2) is not yet implemented.

**Current:** With no arguments the dispatcher prints usage and available commands and exits 2 (`internal/dispatch/run_test.go`). When the subcommand is missing or not on PATH it exits 127 and reports the missing command. Successful delegation and exit-code pass-through are covered by the same tests. PATH order (first matching directory wins) is tested.

**Planned next:** When the first argument is `help` and `bus-help` is not on PATH, show usage and available commands then exit 2; add e2e tests for no-args, missing subcommand, and successful dispatch; add CONTRIBUTING.md or update README.

**Blockers:** None known.

**Depends on:** None.

**Used by:** Every [module](./index) is invoked through it when users run `bus <module> …` (e.g. `bus init`, `bus accounts add`).

See [Development status](../implementation/development-status).

---

<!-- busdk-docs-nav start -->
<p class="busdk-prev-next">
  <span class="busdk-prev-next-item busdk-prev">&larr; <a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-index"><a href="./index">Module CLI reference</a></span>
  <span class="busdk-prev-next-item busdk-next"><a href="./bus-init">bus-init</a> &rarr;</span>
</p>
<!-- busdk-docs-nav end -->

### Sources

- [Module SDD: bus (dispatcher)](../sdd/bus)
- [CLI command structure](../cli/command-structure)
- [Standard global flags](../cli/global-flags)
- [Development status](../implementation/development-status)
